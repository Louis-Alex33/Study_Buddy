# Comment tester le mode multijoueur avec deux utilisateurs

## ❌ Ce qui ne fonctionne PAS

**Deux onglets du même navigateur** = Même session = Même utilisateur
- Onglet 1 : localhost:3000 (User A)
- Onglet 2 : localhost:3000 (User A aussi !)
- ❌ Les deux onglets partagent les cookies de session

## ✅ Solutions qui fonctionnent

### Option 1 : Deux navigateurs différents (RECOMMANDÉ)

1. **Chrome** : Ouvre `http://localhost:3000`
   - Connecte-toi avec User A
   - Crée une room

2. **Firefox** : Ouvre `http://localhost:3000`
   - Connecte-toi avec User B
   - Rejoins la room

### Option 2 : Mode navigation privée

1. **Chrome normal** : Ouvre `http://localhost:3000`
   - Connecte-toi avec User A
   - Crée une room

2. **Chrome navigation privée** : Cmd+Shift+N (Mac) ou Ctrl+Shift+N (Windows)
   - Ouvre `http://localhost:3000`
   - Connecte-toi avec User B
   - Rejoins la room

### Option 3 : Profils Chrome séparés

1. **Profil 1** : Clique sur l'icône de profil en haut à droite
   - Créer un nouveau profil "User A"
   - Connecte-toi avec User A

2. **Profil 2** : Créer un autre profil "User B"
   - Connecte-toi avec User B

### Option 4 : Utiliser ngrok (pour tester avec une autre personne)

```bash
# Installer ngrok (si pas déjà fait)
brew install ngrok

# Exposer ton serveur local
ngrok http 3000
```

Partage l'URL ngrok (ex: `https://abc123.ngrok.io`) avec un ami qui peut tester avec toi !

## 🧪 Procédure de test complète

### 1. Créer deux utilisateurs (si pas déjà fait)

```bash
bin/rails console
```

```ruby
# Créer User A
user_a = User.create!(
  email: 'user_a@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Alice',
  last_name: 'Test'
)

# Créer User B
user_b = User.create!(
  email: 'user_b@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Bob',
  last_name: 'Test'
)

# Créer leurs leagues
UserLeague.create!(user: user_a, rank: 'gold', division: 2, league_points: 50)
UserLeague.create!(user: user_b, rank: 'silver', division: 3, league_points: 30)
```

### 2. Démarrer le serveur

```bash
bin/rails server
```

### 3. Navigateur 1 (Chrome) - User A

1. Ouvrir `http://localhost:3000`
2. Se connecter avec `user_a@test.com` / `password123`
3. Aller sur Multijoueur > Quiz en Temps Réel
4. Créer une room :
   - Nom : "Test Multi"
   - Catégorie : Culture Générale
   - Difficulté : Facile
   - Max joueurs : 2
5. **Attendre dans le lobby**

### 4. Navigateur 2 (Firefox ou Chrome Privé) - User B

1. Ouvrir `http://localhost:3000`
2. Se connecter avec `user_b@test.com` / `password123`
3. Aller sur Multijoueur > Quiz en Temps Réel
4. Rejoindre la room "Test Multi"
5. **Attendre que User A lance le quiz**

### 5. Vérifier que tout fonctionne

**Dans le lobby :**
- ✅ Les deux joueurs doivent apparaître dans la liste
- ✅ User A doit avoir le badge "Hôte"
- ✅ Seul User A doit voir le bouton "Lancer le Quiz"
- ✅ User B doit voir "En attente que Alice lance le quiz..."

**User A lance le quiz :**
- Cliquer sur "Lancer le Quiz"

**Pendant le quiz :**
- ✅ Les deux navigateurs doivent afficher le même quiz
- ✅ Les deux doivent voir l'animation de chargement
- ✅ Les questions doivent s'afficher en même temps

**Ouvrir la console développeur (F12) dans les deux navigateurs :**
```
Navigateur 1 (User A) :
> Initializing QuizRoomChannel for room 1
> Connected to QuizRoomChannel
> Received data from QuizRoomChannel: {type: "score_update", ...}
> Updating leaderboard with 2 participants

Navigateur 2 (User B) :
> Initializing QuizRoomChannel for room 1
> Connected to QuizRoomChannel
> Received data from QuizRoomChannel: {type: "score_update", ...}
> Updating leaderboard with 2 participants
```

**Test des scores en temps réel :**
1. User A répond à une question
2. ✅ Le score de User A doit se mettre à jour dans **les deux navigateurs**
3. User B répond à une question
4. ✅ Le score de User B doit se mettre à jour dans **les deux navigateurs**
5. ✅ Le classement doit se réorganiser automatiquement

## 🐛 Débogage

### Si User B voit toujours User A :

**Vérifier les cookies :**
1. F12 > Application > Cookies
2. Supprimer tous les cookies de localhost:3000
3. Rafraîchir la page
4. Se reconnecter

### Si "Connected to QuizRoomChannel" n'apparaît pas :

```bash
# Redémarrer le serveur
# Ctrl+C puis
bin/rails server
```

### Si les scores ne se synchronisent pas :

**Vérifier dans les logs Rails :**
```bash
tail -f log/development.log
```

Chercher :
```
QuizRoomChannel is streaming from quiz_room_1
QuizRoomChannel broadcasting to quiz_room_1: {:type=>"score_update", ...}
```

## 📊 Ce qui doit fonctionner

- ✅ Deux utilisateurs distincts peuvent rejoindre la même room
- ✅ Seul l'hôte peut lancer le quiz
- ✅ Les scores se mettent à jour en temps réel pour tous les joueurs
- ✅ Le classement se réorganise automatiquement
- ✅ Les logos de ligue s'affichent à côté des noms
- ✅ Le mode sombre fonctionne correctement
- ✅ À la fin, le gagnant reçoit +20 LP, les autres -10 LP

## 💡 Astuce

Si tu veux vraiment tester en local facilement, voici la méthode la plus simple :

1. **Chrome normal** : User A
2. **Chrome navigation privée (Cmd+Shift+N)** : User B

Les deux auront des sessions complètement séparées !
