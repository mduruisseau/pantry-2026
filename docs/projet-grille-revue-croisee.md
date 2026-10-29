# Rendu final · grille de revue croisée

Revue de code de la séance 11, 45 minutes. Chaque équipe relit le dépôt d'une autre équipe et
remplit cette grille.

La revue est un **constat**, pas une note. Chaque ligne reçoit « fait », « partiel » ou
« absent », avec une remarque qui permet à l'équipe relue de retrouver ce qui a été observé : un
fichier, un écran, une commande. Les critères reprennent ceux de la grille de notation : la grille
remplie montre à l'équipe relue ce que la correction regardera.

## Déroulement

1. Cloner le dépôt de l'équipe relue, `flutter pub get`,
   `dart run build_runner build --delete-conflicting-outputs`, puis lancer l'application dans
   Chrome, avec les options que donne le `README.md` du dépôt relu. Un dépôt qui ne versionne pas
   ses fichiers générés, comme Pantry, ne compile pas sans `build_runner` : un `*.config.dart` ou
   un `*.freezed.dart` est introuvable.
2. Passer chaque critère par la vérification indiquée, dans l'ordre du tableau. Le lancement sur
   Android se fait à la ligne « Seconde plateforme ».
3. Ajouter la grille remplie en `REVUE.md`, à la racine, sur une branche `revue` poussée sur le
   dépôt relu, et ouvrir une pull request avant la fin de la séance. L'équipe relue la fusionne.
   L'accès en écriture d'un collaborateur ne dispense pas de la pull request : rien ne se pousse
   sur `main`.

## Grille

Équipe relue : ______ · Équipe qui relit : ______

| Critère | Vérification | Constat | Remarque |
|---|---|---|---|
| Lancement | après les commandes de l'étape 1, l'application se lance dans Chrome sans erreur ; au moins un écran affiche des données de l'API | | |
| Injection | `grep -rnE "getIt|GetIt" lib/ui` ne renvoie rien | | |
| BLoC | aucune requête ni règle métier dans un `build` ; les écrans émettent des événements | | |
| Couches | seule la couche `data` importe le client HTTP et lit du JSON | | |
| Quatre états d'interface | chaque écran montre chargement, erreur, liste vide et données ; l'erreur provoquée par le mode hors ligne des DevTools de Chrome ou le mode avion | | |
| Robustesse | réseau coupé (mode avion, ou hors ligne dans les DevTools), permission refusée si l'application en demande une, réponse vide (une recherche ou une requête sans résultat) : l'application ne casse pas | | |
| Seconde plateforme | l'application se lance sur le web **et** sur Android | | |
| Lisibilité | nommage explicite, aucun code mort, `flutter analyze` sans avertissement | | |

## Remarque générale

Le point le plus solide du dépôt relu, et le point à reprendre en premier.

-
-
