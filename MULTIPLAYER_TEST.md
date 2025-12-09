# Guide de Test du Mode Multijoueur

## Configuration vérifiée ✅

1. **ActionCable** : Configuré avec `solid_cable` (utilise la base de données)
2. **Consumer** : Disponible globalement via `App.cable`
3. **Channel** : `QuizRoomChannel` créé et fonctionnel
4. **Broadcast** : Implémenté côté serveur après sauvegarde des scores

## Comment tester le mode multijoueur

### Étape 1 : Démarrer le serveur
```bash
bin/rails server
```

### Étape 2 : Ouvrir deux navigateurs/onglets
1. Ouvrir le navigateur principal (ex: Chrome)
2. Ouvrir un navigateur en navigation privée (ou Firefox)
3. Se connecter avec deux utilisateurs différents

### Étape 3 : Créer une room
1. Utilisateur 1 : Aller sur `/real_time_quizzes/new`
2. Créer une room avec :
   - Nom : "Test Multiplayer"
   - Catégorie : au choix
   - Difficulté : au choix
   - Max joueurs : 2

### Étape 4 : Rejoindre la room
1. Utilisateur 2 : Aller sur `/real_time_quizzes`
2. Cliquer sur "Rejoindre" pour la room créée
3. Vérifier que les deux joueurs apparaissent dans la liste

### Étape 5 : Lancer le quiz
1. Utilisateur 1 (hôte) : Cliquer sur "Lancer le Quiz"
2. Les deux navigateurs devraient démarrer le quiz

### Étape 6 : Vérifier la synchronisation
1. Ouvrir la console développeur (F12) dans les deux navigateurs
2. Chercher les logs :
   - "Initializing QuizRoomChannel for room X"
   - "Connected to QuizRoomChannel"
   - "Received data from QuizRoomChannel"
   - "Updating leaderboard with X participants"

### Étape 7 : Tester les scores en temps réel
1. Répondre à une question sur l'un des navigateurs
2. Vérifier que le leaderboard se met à jour **dans les deux navigateurs**
3. Les scores doivent être synchronisés instantanément

## Points à vérifier

### ✅ Fonctionnalités implémentées
- [x] Création de room avec catégorie et difficulté
- [x] Seul l'owner peut lancer le quiz
- [x] Badge "Hôte" pour identifier le créateur
- [x] Logos de ligue affichés (28x28px)
- [x] Mode sombre fonctionnel
- [x] Questions différentes selon catégorie/difficulté
- [x] Broadcast ActionCable après sauvegarde du score
- [x] Mise à jour en temps réel du leaderboard

### 🔍 À tester
- [ ] Les deux joueurs voient les mêmes questions
- [ ] Les scores se mettent à jour en temps réel
- [ ] Le timer est synchronisé
- [ ] Le classement final est correct
- [ ] Les LP sont attribués correctement au gagnant

## Résolution de problèmes

### Si les scores ne se mettent pas à jour :
1. Vérifier dans la console développeur que "Connected to QuizRoomChannel" apparaît
2. Vérifier que "Received data from QuizRoomChannel" apparaît après avoir répondu
3. Vérifier les logs Rails pour voir si le broadcast est envoyé

### Si ActionCable ne se connecte pas :
```bash
# Vérifier que solid_cable est bien installé
bin/rails solid_cable:install

# Redémarrer le serveur
bin/rails server
```

### Commandes utiles pour déboguer :
```bash
# Voir les logs en temps réel
tail -f log/development.log

# Vérifier les connexions ActionCable dans Rails console
bin/rails console
> ActionCable.server.connections
```

## Architecture du système

```
Client 1 (Browser)                 Server (Rails)                Client 2 (Browser)
      |                                 |                                |
      |------ Submit Answer ----------->|                                |
      |                                 |                                |
      |                          Save Score to DB                        |
      |                                 |                                |
      |                          Broadcast via                           |
      |                          QuizRoomChannel                         |
      |                                 |                                |
      |<-------- Score Update ----------|--------- Score Update -------->|
      |                                 |                                |
   Update UI                                                        Update UI
```

## Logs attendus

Dans la console navigateur :
```
Initializing QuizRoomChannel for room 1
Connected to QuizRoomChannel
Received data from QuizRoomChannel: {type: "score_update", leaderboard: [...]}
Updating leaderboard with 2 participants
```

Dans les logs Rails :
```
QuizRoomChannel is transmitting the subscription confirmation
QuizRoomChannel is streaming from quiz_room_1
QuizRoomChannel broadcasting to quiz_room_1: {:type=>"score_update", :leaderboard=>[...]}
```
