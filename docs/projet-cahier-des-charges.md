# Rendu final · cahier des charges

Le rendu final reprend ce qui a été construit sur Pantry, sur une **autre API** et avec des
maquettes libres. Il vaut **80 %** de la note du module. Il se travaille en équipe de deux ou
trois, principalement pendant les séances 11 et 12.

Le rendu comporte deux pièces, dans un même dépôt Git : **l'application**, et un **rapport** de
trois à quatre pages, `RAPPORT.md`.

## Calendrier

| Moment | Étape |
|---|---|
| séance 6 | annonce du rendu, choix de l'équipe et de l'API |
| avant la séance 11 | validation d'une API hors de la liste, si l'équipe en choisit une |
| séance 11 | atelier, revue de code croisée ; en fin de séance, une application qui compile et un écran relié à ses données |
| séance 12 | atelier, point technique sur un sujet choisi en séance 11 |
| fin février 2027 | dépôt de l'application et du rapport |

Les deux séances d'atelier comptent huit heures. Une équipe qui travaille régulièrement pendant
ces séances aboutit dans ce temps ; les jours qui suivent servent à finir et à rédiger le rapport.

## Application

### Exigences

| Exigence | Précision |
|---|---|
| une API distante autre qu'Open Food Facts | prise dans `docs/projet-api-validees.md`, ou validée avant la séance 11 |
| les quatre états d'interface | chargement, données, erreur, vide, sur chaque écran qui attend une donnée |
| persistance locale | au minimum des préférences et un cache |
| gestion d'état avec BLoC | aucune requête ni règle métier dans un `build` |
| architecture en couches | seule la couche de données connaît le client HTTP et le JSON |
| `get_it` et `injectable` | aucun appel au conteneur dans les widgets |
| navigation avec `go_router` | plusieurs écrans |
| deux plateformes | Android et web |
| robustesse | l'application ne casse ni sur réseau coupé, ni sur permission refusée, ni sur réponse vide |

### Périmètre

**Trois à cinq écrans.** Trois écrans terminés valent mieux que huit à moitié faits : la cohérence
du périmètre fait partie de la grille.

Libres : le sujet, l'API dans la liste, les maquettes, l'identité visuelle.

### Bonus valorisés

- une capacité native abstraite proprement, avec une implémentation par plateforme ;
- une interface adaptée aux grands écrans ;
- l'internationalisation ;
- les liens profonds ;
- l'accessibilité ;
- des tests ;
- une cible desktop.

## Rapport

Trois à quatre pages, en Markdown, versionnées à la racine du dépôt sous le nom `RAPPORT.md`.

1. **L'architecture retenue.** Le découpage en couches, le rôle de chaque dossier, le trajet d'une
   donnée depuis l'API jusqu'au widget. Un schéma est le bienvenu.
2. **Les paquets utilisés, et la raison de chaque choix.** Pour chacun : le problème qu'il résout,
   les solutions comparées, ce qui a fait pencher. Les critères sont ceux du cours de la séance 8 :
   dernière publication, éditeur, plateformes, score, issues ouvertes, contraintes imposées.
3. **Deux ou trois problèmes rencontrés, et leur solution.** Un problème réel, ce qui a été tenté,
   ce qui a fonctionné. Un rapport qui ne rapporte aucune difficulté est incomplet.

## Choix de l'API

Les API de `docs/projet-api-validees.md` n'exigent aucune clé, acceptent les requêtes depuis
Chrome, et ont des limites de débit compatibles avec une salle entière derrière une seule adresse
IP.

Ce dernier point est le plus important. Une API qui compte ses limites par adresse IP traite toute
la salle comme un seul client : une équipe qui la sollicite fort bloque les autres.

Une API hors de la liste est possible. Elle doit être validée **avant la séance 11**, sur les mêmes
trois critères.

## Évaluation

| Poids | Modalité |
|---|---|
| **80 %** | le rendu final, application et rapport, noté selon `docs/projet-grille-evaluation.md` |
| **20 %** | le contrôle continu : les livrables de TP de quatre séances tirées au sort, notés sur le fait qu'ils fonctionnent |

La note du rendu est une note d'équipe, la même pour chacun de ses membres.

La revue de code croisée de la séance 11 suit `docs/projet-grille-revue-croisee.md`. Ses critères
sont ceux de la grille de notation : elle montre à chaque équipe ce que la correction regardera.

## Points d'attention

**L'adresse IP unique de la salle.** Un appel réseau dans un `build`, ou une boucle de nouvelles
tentatives sans délai, multiplie les requêtes de toute l'équipe, et de la salle avec elle.

**La seconde plateforme se vérifie tôt.** Un paquet sans implémentation web, ou une permission non
déclarée sur Android, se découvre au lancement sur la plateforme concernée, pas avant.

**`flutter analyze` sans avertissement.** Un dépôt propre se relit plus vite, en revue croisée
comme à la correction.
