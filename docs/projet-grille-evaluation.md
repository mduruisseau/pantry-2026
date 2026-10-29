# Rendu final · grille de notation

Le rendu est noté sur 20. Il vaut 80 % de la note du module. La note est une note d'équipe.

Chaque critère se vérifie sur le dépôt rendu, par la manipulation ou la lecture indiquée.

| Critère | Points | Vérification |
|---|---|---|
| L'application tourne sans crash sur un appareil réel | 3 | lancement sur un appareil Android, parcours de chaque écran |
| Fonctionnalités livrées et cohérence du périmètre | 2 | trois à cinq écrans terminés, sans écran commencé puis abandonné |
| Architecture en couches et injection de dépendances | 3 | seule la couche de données importe le client HTTP et lit du JSON ; `grep -rnE "getIt|GetIt" lib/ui` ne renvoie rien |
| BLoC utilisé correctement | 2 | aucune requête ni règle métier dans un `build` ; les écrans émettent des événements ou appellent des méthodes de cubit |
| Les quatre états traités partout | 2 | chargement, erreur, vide et données sur chaque écran qui attend une donnée ; l'erreur provoquée par le mode hors ligne des DevTools de Chrome ou le mode avion |
| Seconde plateforme | 2 | l'application se lance et fonctionne sur le web **et** sur Android |
| Robustesse | 2 | réseau coupé (mode avion, ou hors ligne dans les DevTools), permission refusée si l'application en demande une, réponse vide (une recherche ou une requête sans résultat) : l'application ne casse pas |
| Rapport | 3 | architecture, justification des paquets choisis par l'équipe (pas ceux qu'impose le cahier des charges), problèmes rencontrés ; trois à quatre pages, `RAPPORT.md` |
| Soin de l'interface | 1 | thème du système passé en sombre : aucun texte illisible ; chaque bouton à icône a un libellé, infobulle ou `Semantics` |
| **Total** | **20** | |

Les bonus du cahier des charges compensent au plus deux points perdus ; la note reste plafonnée
à 20.
