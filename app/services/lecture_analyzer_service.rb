class LectureAnalyzerService
  def initialize(lecture)
    @lecture = lecture
  end

  def call
    return unless @lecture.document.attached?

    begin
      response = generate_summary
      parsed_response = parse_json_response(response)

      @lecture.update(resume: parsed_response['resume'])
    rescue => e
      Rails.logger.error "Error analyzing lecture #{@lecture.id}: #{e.message}"
      @lecture.update(resume: "Erreur lors de l'analyse du document : #{e.message}")
    end
  end

  private

  def generate_summary
    # Essayer d'abord avec le modèle préféré, puis fallback si erreur de quota
    begin
      chat = initialize_chat(preferred: true)
      ask_chat(chat)
    rescue => e
      # Si erreur de quota (429) ou autre erreur API, essayer avec le modèle de fallback
      if quota_error?(e)
        Rails.logger.warn "Quota exceeded for primary model, falling back to alternative: #{e.message}"
        chat = initialize_chat(preferred: false)
        ask_chat(chat)
      else
        raise e
      end
    end
  end

  def ask_chat(chat)
    if @lecture.document.content_type == "application/pdf"
      chat.ask("Analyse ce document et fournis un résumé détaillé.", with: { pdf: @lecture.document.url }).content
    elsif @lecture.document.image?
      chat.ask("Analyse ce document et fournis un résumé détaillé.", with: { image: @lecture.document.url }).content
    else
      # Pour les fichiers texte ou autres
      chat.ask("Analyse ce document et fournis un résumé détaillé.").content
    end
  end

  def initialize_chat(preferred: true)
    chat = if @lecture.document.content_type == "application/pdf"
             # Pour les PDF: Gemini en priorité, GPT-4o en fallback
             preferred ? RubyLLM.chat(model: "gemini-2.0-flash") : RubyLLM.chat(model: "gpt-4o")
           elsif @lecture.document.image?
             # Pour les images: toujours GPT-4o (meilleure vision)
             RubyLLM.chat(model: "gpt-4o")
           else
             # Pour les autres: modèle par défaut
             RubyLLM.chat
           end

    chat.with_instructions(instructions)
    chat
  end

  def quota_error?(error)
    # Détecte les erreurs de quota (429, "Resource exhausted", etc.)
    error.message.include?("429") ||
    error.message.include?("Resource exhausted") ||
    error.message.include?("quota") ||
    error.message.include?("rate limit")
  end

  def instructions
    "Tu es un assistant chargé d'analyser des fichiers téléchargés par l'utilisateur
    (PDF, DOCX, TXT). Tu dois :

    1. Lire intégralement le fichier fourni.
    2. Produire un résumé clair, concis, fidèle et sans fioritures.
    3. Structurer le résumé avec des retours à la ligne (<br>) entre chaque point ou thème abordé pour plus de clarté.
    4. Mettre en évidence les éléments importants du résumé en utilisant
      exclusivement les balises HTML <strong> et <em>.
    5. Ne jamais inventer d'informations absentes du fichier.
      Si un élément attendu n'apparaît pas dans le document, tu dois écrire :
      'Information absente du fichier'.

    CONTRAINTES ABSOLUES :
    - Tu ne modifies jamais le sens du contenu.
    - Tu n'ajoutes aucune interprétation ou opinion personnelle.
    - Tu ne réalises aucune action non explicitement demandée.
    - Tu renvoies uniquement le JSON demandé, sans texte avant ou après.
    - Tu utilises des <br> pour séparer les différents points/thèmes pour améliorer la lisibilité.
    - IMPORTANT : Utilise UNIQUEMENT des guillemets doubles (\") dans le JSON, jamais de guillemets simples (').

    FORMAT DE SORTIE STRICT (UTILISER DES GUILLEMETS DOUBLES) :
    {
      \"title\": \"Titre extrait du document ou titre le plus proche\",
      \"resume\": \"Résumé clair et structuré avec des <br> entre les points. Utilise <strong> et <em> pour les éléments importants.\"
    }

    EXEMPLE DE RÉSUMÉ :
    {
      \"title\": \"Concepts clés du document\",
      \"resume\": \"Ce document traite de <strong>trois concepts clés</strong> :<br><br><strong>Concept 1 :</strong> Description du premier concept avec détails pertinents.<br><br><strong>Concept 2 :</strong> Explication du deuxième point avec les <em>éléments importants</em>.<br><br><strong>Concept 3 :</strong> Présentation du troisième thème.\"
    }

    Si le fichier ne peut pas être lu ou est vide, renvoie un JSON valide avec un titre vide
    et un résumé indiquant l'erreur rencontrée."
  end

  def parse_json_response(response)
    # Nettoyer la réponse si elle contient du texte avant/après le JSON
    json_match = response.match(/\{.*\}/m)
    json_string = json_match ? json_match[0] : response

    # Remplacer les guillemets simples par des doubles pour la compatibilité JSON
    # Gère les clés et valeurs avec guillemets simples
    json_string = json_string.gsub(/'([^']*)'(\s*:)/, '"\1"\2')  # Clés: 'key': -> "key":
    json_string = json_string.gsub(/:\s*'([^']*)'(\s*[,}])/, ': "\1"\2')  # Valeurs simples: : 'value', -> : "value",

    # Gère les valeurs longues avec guillemets simples (multilignes avec balises HTML)
    json_string = json_string.gsub(/:\s*'((?:[^']|'(?=[^:,}]))*)'(\s*[,}])/m, ': "\1"\2')

    JSON.parse(json_string)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse JSON response: #{response}"
    Rails.logger.error "JSON Parser Error: #{e.message}"

    # Fallback : tenter d'extraire le résumé même si le JSON est cassé
    extract_resume_fallback(response)
  end

  def extract_resume_fallback(response)
    # Tenter d'extraire le résumé avec différentes patterns
    # Pattern 1 : Guillemets doubles
    resume_match = response.match(/"resume"\s*:\s*"((?:[^"\\]|\\.)*)"/m)
    resume = resume_match[1] if resume_match

    # Pattern 2 : Guillemets simples si pattern 1 échoue
    unless resume
      resume_match = response.match(/'resume'\s*:\s*'((?:[^'\\]|\\.)*)'/m)
      resume = resume_match[1] if resume_match
    end

    # Pattern 3 : Extraire tout après "resume": jusqu'à la fin
    unless resume
      resume_match = response.match(/["']resume["']\s*:\s*["'](.*)["']\s*[,}]/m)
      resume = resume_match[1] if resume_match
    end

    resume ||= 'Erreur lors du parsing de la réponse AI. Impossible d\'extraire le résumé.'

    Rails.logger.info "Fallback extraction successful, resume length: #{resume.length}"
    { 'title' => '', 'resume' => resume }
  end
end
