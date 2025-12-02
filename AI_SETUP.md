# Configuration de l'IA OpenAI

## Obtenir une clé API OpenAI

1. Créez un compte sur [OpenAI Platform](https://platform.openai.com/)
2. Accédez à la section [API Keys](https://platform.openai.com/api-keys)
3. Cliquez sur "Create new secret key"
4. Copiez votre clé API

## Configuration dans l'application

1. Ouvrez le fichier `.env` à la racine du projet
2. Remplacez `your_openai_api_key_here` par votre vraie clé API :

```
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxx
```

3. Redémarrez le serveur Rails :

```bash
bin/rails server
```

## Fonctionnalités IA

Quand vous uploadez un cours (PDF ou TXT), l'IA génère automatiquement :

### 📝 Résumé du cours
- Concepts clés organisés de manière hiérarchique
- Entre 300 et 500 mots
- Structure claire avec bullet points

### 🎯 Flashcards (10 cartes)
- Questions variées (définitions, concepts, applications)
- Réponses précises et complètes
- Parfaites pour la révision active

### 📊 Quiz (10 questions QCM)
- 4 options par question
- Une seule bonne réponse
- Explication pour chaque réponse
- Difficulté progressive

## Modèle utilisé

L'application utilise **GPT-4o-mini** qui offre :
- Excellent rapport qualité/prix
- Réponses rapides
- Grande précision pour le contenu éducatif

## Coûts estimés

Avec GPT-4o-mini :
- ~$0.15 par million de tokens d'entrée
- ~$0.60 par million de tokens de sortie
- **Coût par analyse de cours** : ~$0.01 à $0.03

## Formats supportés

- ✅ PDF (`.pdf`)
- ✅ Texte (`.txt`)
- ⏳ DOCX (`.docx`) - à venir

## Dépannage

### L'IA ne génère pas de contenu

1. Vérifiez que votre clé API est correcte dans `.env`
2. Vérifiez que vous avez des crédits sur votre compte OpenAI
3. Consultez les logs : `tail -f log/development.log`

### Temps de traitement

- Le traitement est **asynchrone** (en arrière-plan)
- Rechargez la page après 10-30 secondes
- Plus le document est long, plus ça prend de temps

### Erreurs communes

**"API key not found"**
→ Ajoutez votre clé dans le fichier `.env`

**"Insufficient credits"**
→ Ajoutez des crédits sur votre compte OpenAI

**"Rate limit exceeded"**
→ Attendez quelques minutes avant de réessayer
