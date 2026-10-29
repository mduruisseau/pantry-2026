# Pantry · fil rouge du cours Flutter

Application de gestion de garde-manger, construite séance après séance pendant le module Flutter
du M2 informatique. Ce dépôt sert les **points de départ et les corrigés des TP**.

## Version du SDK · épinglée pour l'année

**Flutter 3.47.8** (Dart 3.13.7), installé par l'**archive officielle** :

```
https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.8-stable.tar.xz
```

La procédure est celle de la documentation officielle, complétée par
[docs/installation.md](https://github.com/mduruisseau/pantry-2026/blob/main/docs/installation.md) :
emplacement d'extraction, `PATH`, et ce qui diffère pour la version du cours.

Trois points importants :

- **Ne pas installer le SDK par `git clone`.** Cette méthode échoue sur les postes de la faculté :
  l'historique du dépôt est volumineux et un clone superficiel empêche la détection de version.
  Utiliser exclusivement l'archive.
- **Ne jamais lancer `flutter upgrade`.** La commande fonctionne aussi sur une installation par
  archive, et quitterait la version du cours, gelée pour que tous les postes exécutent la même.
  `flutter downgrade` y revient.
- **Le `pubspec.lock` est committé et fait autorité.** Ne pas le supprimer et ne pas exécuter
  `flutter pub upgrade`. Les versions sont figées : la chaîne de génération de code utilisée par ce
  projet n'accepte qu'une plage restreinte de versions.

## Documents

Lisibles directement sur GitHub, sans rien cloner.

Les liens pointent vers `main` : ils fonctionnent depuis n'importe quelle branche de TP.

| Document | |
|---|---|
| [Diapositives](https://github.com/mduruisseau/pantry-2026/tree/main/docs/slides) | en PDF, publiées avant chaque séance |
| [Installation](https://github.com/mduruisseau/pantry-2026/blob/main/docs/installation.md) | complément à la documentation officielle |
| [Kotlin ↔ Dart](https://github.com/mduruisseau/pantry-2026/blob/main/docs/dart-pour-devs-kotlin.md) | correspondances, pour les premières séances |
| [Exercices DartPad · séance 1](https://github.com/mduruisseau/pantry-2026/blob/main/docs/seance-01-dart-exercices.md) | |
| [Devine le rendu · séance 2](https://github.com/mduruisseau/pantry-2026/blob/main/docs/seance-02-devine-le-rendu.md) | |
| [Rendu final · cahier des charges](https://github.com/mduruisseau/pantry-2026/blob/main/docs/projet-cahier-des-charges.md) | annoncé en séance 6 |
| [Rendu final · API utilisables](https://github.com/mduruisseau/pantry-2026/blob/main/docs/projet-api-validees.md) | sans clé, CORS ouvert, limites compatibles avec la salle |
| [Rendu final · grille de notation](https://github.com/mduruisseau/pantry-2026/blob/main/docs/projet-grille-evaluation.md) | |
| [Rendu final · grille de revue croisée](https://github.com/mduruisseau/pantry-2026/blob/main/docs/projet-grille-revue-croisee.md) | séance 11 |

Les documents des séances suivantes sont ajoutés au fur et à mesure.

## Comment récupérer un TP

```bash
git clone https://github.com/mduruisseau/pantry-2026.git
cd pantry-2026
git switch session-02-start
flutter pub get
flutter run -d chrome
```

Pour passer d'une séance à l'autre ensuite :

```bash
git fetch origin
git switch session-03-start
```

Travaillez sur **votre propre branche**, pas sur celles du cours :

```bash
git switch -c tp03-<votrenom>
```

Une branche `-start` est un état initial propre. En cas de retard, de projet devenu inutilisable ou
d'absence, repartir de la branche de la séance concernée.

**Chaque branche de séance contient un fichier `TP.md`** : l'énoncé complet du TP, rédigé pour être
suivi de façon autonome.

## Rendre un TP

Ce dépôt est en lecture seule. Le rendu se pousse sur **votre fork**, créé une fois pour l'année
depuis le bouton **Fork** de cette page, puis déclaré comme second remote :

```bash
git remote add perso https://github.com/<votre-compte>/pantry-2026.git
```

En fin de séance :

```bash
git add -A
git commit -m "TP 3"
git push perso tp03-<votrenom>
```

GitHub refuse le mot de passe du compte pour un push en HTTPS : utiliser un jeton d'accès
personnel, ou une adresse SSH pour le remote `perso`.

| Règle | Détail |
|---|---|
| ce qui compte | 20 % de la note : les livrables de quatre séances, tirées au sort parmi les séances 2 à 10, après la séance 10 |
| ce qui est vérifié | les critères de l'exercice prioritaire, nommés dans la section « Rendu » du `TP.md` |
| échéance | le dernier commit poussé avant la fin de la séance |
| binôme | chacun pousse sur son fork ; un rendu commun est accepté sur demande, branche `tpNN-<nom1>-<nom2>` |
| absence | une séance tirée et manquée vaut zéro, sauf absence justifiée : une autre séance est alors tirée |

Pousser la branche de départ ou le corrigé ne valide rien. Un fork d'un dépôt public est public.

Le `pubspec.yaml` est **identique sur toutes les branches**, y compris pour des paquets utilisés
seulement dans les séances ultérieures. Ce choix est volontaire : un changement de branche ne
déclenche alors aucun téléchargement, et `flutter pub get` est immédiat.

## Les branches

| Branche | Contenu | Publiée |
|---|---|---|
| `main` | ce README, les documents de `docs/` et les diapositives en PDF | · |
| `session-NN-start` | point de départ du TP de la séance NN | avant la séance |
| `session-NN-solution` | corrigé | après la séance |
| `session-06-getit-manuel` | état intermédiaire du TP 1 de la séance 6 | séance 6 |
| `session-11-ressources` | exemples de tests de la séance 11, code des modules de la séance 12 | après la séance 11 |

Les corrigés sont poussés **après** la séance concernée. S'ils n'apparaissent pas, exécuter
`git fetch` le lendemain.

Sans cloner, l'énoncé et le corrigé d'une séance publiée se lisent à ces adresses, en remplaçant
`NN` par le numéro de la séance :

```
https://github.com/mduruisseau/pantry-2026/blob/session-NN-start/TP.md
https://github.com/mduruisseau/pantry-2026/blob/session-NN-solution/CORRIGE.md
```

## Génération de code

Plusieurs séances utilisent `freezed`, `json_serializable`, `drift` et `injectable`. Le code généré
(`*.g.dart`, `*.freezed.dart`) **n'est pas committé** : il se régénère.

```bash
dart run build_runner build
```

Une erreur inattendue après un changement de branche provient le plus souvent de code généré
obsolète : relancer la commande ci-dessus.

## Un mot sur l'API

À partir de la séance 4, l'application interroge par défaut le service du cours, un miroir
d'[Open Food Facts](https://world.openfoodfacts.org/data), et non l'API réelle. Celle-ci applique
des **limites de débit par adresse IP**, et toute la salle partage la même adresse : les énoncés de
TP précisent quand l'utiliser. Sans réseau, `--dart-define=PANTRY_OFFLINE=true` sert des données
locales. Le service exige un jeton à partir de la séance 6 : une branche antérieure se relance
alors avec ce même `PANTRY_OFFLINE=true`.
