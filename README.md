# Pantry — fil rouge du cours Flutter

Application de gestion de garde-manger, construite séance après séance pendant le module Flutter
du M2 informatique. Ce dépôt sert les **points de départ et les corrigés des TP**.

## Version du SDK — épinglée pour l'année

**Flutter 3.47.1** (Dart 3.13.1). Installation par l'**archive officielle**, en suivant
[docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install), chemin de
votre système puis cible **web**.

```
https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.1-stable.tar.xz
```

Environ 1,6 Go. Extraction dans un répertoire du compte utilisateur, puis ajout de
`<répertoire>/flutter/bin` au `PATH` :

```bash
tar -xf flutter_linux_3.47.1-stable.tar.xz
export PATH="$PWD/flutter/bin:$PATH"
```

Cette ligne `export` ne vaut que pour le terminal courant. Pour qu'elle persiste, l'ajouter au
fichier de configuration du shell (`~/.bashrc` ou `~/.zshrc`), puis ouvrir un nouveau terminal.

Trois points importants :

- **Ne pas installer le SDK par `git clone`.** Cette méthode échoue sur les postes de la faculté :
  l'historique du dépôt est volumineux et un clone superficiel empêche la détection de version.
  Utiliser exclusivement l'archive.
- **`flutter upgrade` n'est pas utilisable** avec une installation par archive. C'est sans
  conséquence : la version est gelée pour l'année, afin que tous les postes exécutent la même.
- **Le `pubspec.lock` est committé et fait autorité.** Ne pas le supprimer et ne pas exécuter
  `flutter pub upgrade`. Les versions sont figées : la chaîne de génération de code utilisée par ce
  projet n'accepte qu'une plage restreinte de versions.

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
git switch -c mon-tp-03
```

Une branche `-start` est un état initial propre. En cas de retard, de projet devenu inutilisable ou
d'absence, repartir de la branche de la séance concernée.

**Chaque branche de séance contient un fichier `TP.md`** : l'énoncé complet du TP, rédigé pour être
suivi de façon autonome.

Le `pubspec.yaml` est **identique sur toutes les branches**, y compris pour des paquets utilisés
seulement dans les séances ultérieures. Ce choix est volontaire : un changement de branche ne
déclenche alors aucun téléchargement, et `flutter pub get` est immédiat.

## Les branches

| Branche | Contenu | Publiée |
|---|---|---|
| `main` | ce README, rien d'autre | — |
| `session-NN-start` | point de départ du TP de la séance NN | avant la séance |
| `session-NN-solution` | corrigé | après la séance |
| `session-06-getit-manuel` | état intermédiaire du TP 1 de la séance 6 | séance 6 |
| `session-10-jank` | branche avec quatre problèmes de performance à trouver | séance 10 |

Les corrigés sont poussés **après** la séance concernée. S'ils n'apparaissent pas, exécuter
`git fetch` le lendemain.

## Génération de code

Plusieurs séances utilisent `freezed`, `json_serializable`, `drift` et `injectable`. Le code généré
(`*.g.dart`, `*.freezed.dart`) **n'est pas committé** : il se régénère.

```bash
dart run build_runner build --delete-conflicting-outputs
```

Une erreur inattendue après un changement de branche provient le plus souvent de code généré
obsolète : relancer la commande ci-dessus.

## Un mot sur l'API

L'application consomme [Open Food Facts](https://world.openfoodfacts.org/data), gratuite et sans
clé d'API. Elle applique en revanche des **limites de débit par adresse IP**, et l'ensemble de la salle
partage la même adresse. Les énoncés de TP précisent quand utiliser les données locales plutôt que
l'API réelle. Ces consignes sont impératives : un dépassement entraîne le bannissement de l'adresse
IP de l'université.
