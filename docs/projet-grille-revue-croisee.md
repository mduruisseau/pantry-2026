# Rendu final · grille de revue croisée

Revue de code de la séance 11, 45 minutes. Chaque équipe relit le dépôt d'une autre équipe et
remplit cette grille.

La revue est un **constat**, pas une note. Chaque ligne reçoit « fait », « partiel » ou
« absent », avec une remarque qui permet à l'équipe relue de retrouver ce qui a été observé : un
fichier, un écran, une commande. Les critères reprennent ceux de la grille de notation : la grille
remplie montre à l'équipe relue ce que la correction regardera.

## Déroulement

1. Cloner le dépôt de l'équipe relue, `flutter pub get`, puis lancer l'application dans Chrome et
   sur Android.
2. Passer chaque critère par la vérification indiquée, dans l'ordre du tableau.
3. Rendre la grille remplie à l'équipe relue avant la fin de la séance.

## Grille

Équipe relue : ______ · Équipe qui relit : ______

| Critère | Vérification | Constat | Remarque |
|---|---|---|---|
| Injection | `grep -rn "getIt" lib/ui` ne renvoie rien | | |
| BLoC | aucune requête ni règle métier dans un `build` ; les écrans émettent des événements | | |
| Couches | seule la couche `data` importe le client HTTP et lit du JSON | | |
| Quatre états d'interface | chaque écran montre chargement, erreur, liste vide et données, panne provoquée comprise | | |
| Robustesse | réseau coupé (mode avion, ou hors ligne dans les DevTools), permission refusée, réponse vide : l'application ne casse pas | | |
| Seconde plateforme | l'application se lance sur le web **et** sur Android | | |
| Lisibilité | nommage explicite, aucun code mort, `flutter analyze` sans avertissement | | |

## Remarque générale

Le point le plus solide du dépôt relu, et le point à reprendre en premier.

-
-
