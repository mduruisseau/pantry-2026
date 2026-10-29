# Rendu final · cahier des charges

Le rendu final reprend ce qui a été vu sur Pantry, sur une **autre API** et avec des maquettes
libres : une transposition, pas un copier-coller. Il vaut **80 %** de la note du module. Il se
travaille en équipe de deux ou trois, principalement pendant les séances 11 et 12.

Le rendu comporte deux pièces, dans un même dépôt Git : **l'application**, et un **rapport** de
trois à quatre pages, `RAPPORT.md`.

## Calendrier

| Moment | Étape |
|---|---|
| séance 6 | annonce du rendu et remise de la liste des API ; l'équipe et l'API se choisissent d'ici la séance 10 |
| séance 10 | lancement : équipe définitive, API retenue, dépôt Git créé, enseignant et équipe relectrice ajoutés comme collaborateurs, premier commit avec le projet, le `pubspec.yaml` et le `pubspec.lock` |
| avant la séance 11 | validation d'une API hors de la liste par l'enseignant, si l'équipe en choisit une |
| séance 11 | atelier, revue de code croisée ; en fin de séance, une application qui compile et un écran relié à ses données |
| séance 12 | atelier, point technique sur un sujet choisi en séance 11 |
| fin février 2027 | dépôt de l'application et du rapport |

Les deux séances d'atelier comptent huit heures, dont cinq heures et demie de travail en équipe ;
le reste va aux tests, à la revue croisée, au point technique et au bilan. Les semaines qui suivent
la séance 12, jusqu'au dépôt, servent à finir et à rédiger le rapport.

## Application

### Exigences

| Exigence | Précision |
|---|---|
| une API distante autre qu'Open Food Facts | prise dans la [liste des API](projet-api-validees.md), ou validée avant la séance 11 |
| les quatre états d'interface | chargement, données, erreur, vide, sur chaque écran qui attend une donnée |
| persistance locale | au minimum des préférences et un cache |
| gestion d'état avec BLoC | aucune requête ni règle métier dans un `build` |
| architecture en couches | seule la couche de données connaît le client HTTP et le JSON |
| `get_it` et `injectable` | aucun appel au conteneur dans les widgets |
| navigation avec `go_router` | plusieurs écrans |
| deux plateformes | Android et web |
| robustesse | l'application ne casse ni sur réseau coupé, ni sur permission refusée, ni sur réponse vide |
| soin de l'interface | un mode sombre sans couleur en dur, une accessibilité de base : un libellé sur chaque bouton à icône ; noté sur un point |

### Périmètre

**Trois à cinq écrans.** Trois écrans terminés valent mieux que huit à moitié faits : la cohérence
du périmètre fait partie de la grille.

Libres : le sujet, l'API dans la liste, les maquettes, l'identité visuelle.

### Bonus valorisés

- une capacité native abstraite proprement, avec une implémentation par plateforme ;
- une interface adaptée aux grands écrans ;
- l'internationalisation ;
- les liens profonds ;
- l'accessibilité au-delà de la base : navigation au clavier, parcours complet au lecteur d'écran ;
- des tests ;
- une cible desktop.

Les bonus compensent au plus deux points perdus sur la grille de notation ; la note reste
plafonnée à 20.

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

Les API de la [liste](projet-api-validees.md) n'exigent aucune clé, acceptent les requêtes depuis
Chrome, et ont des limites de débit compatibles avec une salle entière derrière une seule adresse
IP.

Ce dernier point est le plus important. Une API qui compte ses limites par adresse IP traite toute
la salle comme un seul client : une équipe qui la sollicite fort bloque les autres.

Une API hors de la liste est possible. Elle doit être validée par l'enseignant **avant la séance
11**, après les cinq vérifications décrites à la fin de la [liste](projet-api-validees.md).

## Évaluation

| Poids | Modalité |
|---|---|
| **80 %** | le rendu final, application et rapport, noté selon la [grille de notation](projet-grille-evaluation.md) |
| **20 %** | le contrôle continu : les livrables de TP de quatre séances tirées au sort après la séance 10, validés si les critères de l'exercice prioritaire sont atteints (section « Rendu » de chaque `TP.md`) |

La note du rendu est une note d'équipe, la même pour chacun de ses membres.

La revue de code croisée de la séance 11 suit la
[grille de revue croisée](projet-grille-revue-croisee.md). Ses critères sont ceux de la grille de
notation : elle montre à chaque équipe ce que la correction regardera.

## Points d'attention

**L'adresse IP unique de la salle.** Un appel réseau dans un `build`, ou une boucle de nouvelles
tentatives sans délai, multiplie les requêtes de toute l'équipe, et de la salle avec elle.

**La seconde plateforme se vérifie tôt.** Un paquet sans implémentation web, ou une permission non
déclarée sur Android, se découvre au lancement sur la plateforme concernée, pas avant.

**Les versions des paquets.** Reprendre, pour les seuls paquets utilisés, les versions du
`pubspec.yaml` de Pantry : elles sont compatibles entre elles et avec le Flutter des postes.
Committer le `pubspec.lock`. Un `dependency_overrides` ne règle rien : il reporte le conflit sur
chaque poste qui clone le dépôt.

**Les réglages qu'un paquet apporte.** Certains plugins exigent un réglage de plateforme, que
Pantry porte déjà : `compileSdk = 37` et le desugaring dans `android/app/build.gradle.kts`, les
récepteurs de notifications dans `AndroidManifest.xml`, `drift_worker.js` et `sqlite3.wasm` dans
`web/` pour Drift. Les commentaires des fichiers Android disent quel paquet les demande.

**`flutter analyze` sans avertissement.** Un dépôt propre se relit plus vite, en revue croisée
comme à la correction.
