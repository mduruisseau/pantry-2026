# Installation de Flutter · addendum

Ce document ne remplace pas la documentation officielle, il la complète.

**La référence est [docs.flutter.dev/install/manual](https://docs.flutter.dev/install/manual)**,
avec le choix **Linux**. Les points ci-dessous sont ceux qui ne figurent pas dans cette page ou qui
sont spécifiques aux postes de la faculté.

## Deux raccourcis à éviter

- **Le *Quick start*** que propose en premier la page `docs.flutter.dev/install`. Il fait
  télécharger le SDK par l'extension VS Code, au moyen d'un `git clone` : la méthode qui échoue sur
  les postes, et une autre version que celle du cours.
- **Le bouton de téléchargement** de la page `install/manual`. Il sert la dernière version stable,
  et non la version du cours.

## Version

**Flutter 3.47.1 / Dart 3.13.1**, gelée pour toute l'année. Ne pas installer une autre version.

```
https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.1-stable.tar.xz
```

Environ 1,6 Go. Une fois l'installation faite, `flutter --version` doit afficher `Flutter 3.47.1`
et `Dart 3.13.1`. Une autre version indique une archive prise par le bouton : supprimer le dossier
extrait et recommencer avec l'URL ci-dessus.

## Prérequis

La page officielle fait installer `curl`, `git`, `unzip`, `xz-utils`, `zip` et `libglu1-mesa` par
`sudo apt-get`. Sur les postes de la salle, `sudo` n'est pas disponible : ne rien installer, et
signaler un outil manquant à l'enseignant. Sur une machine personnelle, suivre la page.

## Installation par archive et non par `git clone`

La documentation officielle propose les deux méthodes, la seconde par le *Quick start* et par
l'extension VS Code. **Utiliser l'archive.**

Le clone échoue sur les postes de la faculté : l'historique du dépôt Flutter est volumineux, et un
clone superficiel empêche le SDK de déterminer sa propre version, `flutter --version` renvoie alors
`0.0.0-unknown` et `flutter doctor` se comporte de façon incohérente.

Conséquence à connaître : **`flutter upgrade` ne fonctionne pas** avec une installation par archive.
C'est voulu. La version est gelée pour que tous les postes exécutent la même, et une mise à jour en
cours de semestre casserait la chaîne de génération de code du projet.

## Extraction et `PATH` sans droits administrateur

Les emplacements sont ceux de la page officielle : le SDK dans `~/develop/flutter`.

```bash
mkdir -p ~/develop
tar -xf ~/Téléchargements/flutter_linux_3.47.1-stable.tar.xz -C ~/develop/
export PATH="$HOME/develop/flutter/bin:$PATH"
flutter --version
```

Cette ligne `export` ne vaut que pour le terminal courant. Pour qu'elle persiste, l'ajouter à la fin
de `~/.bashrc` (`~/.zshenv` sous zsh), puis **ouvrir un nouveau terminal** :

```bash
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.bashrc
```

Ne pas écrire dans `/etc/profile.d`, `/usr/local/bin` ni `/opt` : ces emplacements demandent les
droits root, indisponibles sur les postes.

Vérification :

```bash
which flutter        # doit pointer dans votre répertoire personnel
flutter --version    # doit afficher 3.47.1
```

## Objectif de la séance : une seule commande

```bash
flutter devices      # Chrome doit apparaître
flutter create demo && cd demo && flutter run -d chrome
```

Si cette dernière commande ouvre un navigateur affichant un compteur, l'installation est terminée.
**Rien d'autre n'est requis aujourd'hui.**

## Lire la sortie de `flutter doctor`

`flutter doctor` vérifie toutes les cibles possibles, y compris celles qui ne servent pas ici. Les
lignes suivantes sont **sans conséquence** pour les séances 1 à 7 :

| Ligne | Statut |
|---|---|
| `Android toolchain` | présente sur les postes de la salle, souvent absente sur une machine personnelle · sans effet avant la séance 8 |
| `Android licenses` non acceptées | sans effet avant la séance 8 |
| `Linux toolchain` (clang, CMake, ninja, GTK) incomplète | la cible desktop est optionnelle |
| `Android Studio` absent | non utilisé, VS Code suffit |

**La seule ligne qui doit être verte est `Chrome`.** Si `flutter doctor` ne détecte pas Chrome alors
qu'il est installé, renseigner son emplacement :

```bash
export CHROME_EXECUTABLE=$(which google-chrome || which chromium)
```

## VS Code

VS Code est déjà installé sur les postes. Il faut l'extension **Flutter** (elle installe Dart
automatiquement). Après installation, redémarrer VS Code et vérifier que l'analyse démarre à
l'ouverture d'un projet.

Si l'éditeur ne trouve pas le SDK, il affiche « Could not find a Flutter SDK. Please download, or,
if already downloaded, click 'Locate SDK'. ». Choisir **Locate SDK** et désigner
`~/develop/flutter`. **Ne jamais choisir *Download SDK*** : l'extension lance alors un `git clone`
de la dernière version stable. Le réglage équivalent est `dart.flutterSdkPath`, dans les
paramètres.

## Réseau

Le téléchargement de l'archive mobilise le réseau de la salle. Deux moyens de le soulager :

- **partage de connexion** depuis un téléphone, pour ceux dont le forfait le permet ;
- **câble Ethernet** si le poste en dispose.

## Problèmes fréquents

| Symptôme | Cause | Correction |
|---|---|---|
| `flutter: command not found` après réouverture du terminal | `PATH` non persistant | ajouter la ligne `export` à `~/.bashrc` |
| `Permission denied` à l'exécution de `flutter` | répertoire monté sans droit d'exécution | extraire ailleurs, signaler à l'enseignant |
| `flutter --version` affiche `0.0.0-unknown` | installation par `git clone` | recommencer avec l'archive |
| `flutter --version` affiche une version autre que 3.47.1 | archive prise par le bouton de la page officielle | supprimer le dossier, recommencer avec l'URL de la section Version |
| Aucun appareil dans `flutter devices` | Chrome non détecté | renseigner `CHROME_EXECUTABLE` |
| `flutter pub get` se bloque | proxy sortant | signaler, la configuration proxy sera donnée en séance |
