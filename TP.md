# Séance 2 · TP : fiche produit et formulaire

Deux exercices : placement de widgets sous contrainte, puis saisie validée. À l'issue du TP,
l'application affiche une fiche produit conforme à une maquette et permet d'ajouter un produit
manuellement.

**L'exercice 1 est la priorité de la séance.** L'exercice 2 peut être terminé en dehors, et c'est
le cas prévu : le temps de classe ne suffit pas aux deux pour la plupart des binômes.

> Le TP 1 de la séance (« Devine le rendu ») se fait en cours, sans le projet.

## Démarrer

```bash
git switch session-02-start
flutter pub get
flutter run -d chrome
```

`flutter pub get` télécharge environ 330 Mo au premier appel. Les changements de branche
ultérieurs ne déclenchent aucun téléchargement : le `pubspec.yaml` est identique sur toutes les
branches.

Travaillez sur votre propre branche :

```bash
git switch -c tp02-<votrenom>
```

## Ce qui est fourni

| Fichier | Rôle |
|---|---|
| `lib/models/product.dart` | le modèle, en Dart pur · `freezed` arrive en séance 4 |
| `lib/data/mock_products.dart` | six produits réels, **inégalement renseignés** |
| `lib/ui/widgets/product_image_placeholder.dart` | la vignette, déjà écrite, à placer seulement |
| `lib/main.dart` | la coquille à deux onglets, avec son `setState` |
| `lib/ui/add_product_page.dart` | uniquement le contrat : `onSubmitted` et un `Scaffold` vide |
| `design/fiche-produit.svg` | **la maquette**, à ouvrir dans un navigateur |

Aucune image n'est chargée en séance 2, ni depuis le réseau ni depuis les assets. Les photos des
produits sont introduites en séance 4.

---

## Exercice 1 · la fiche produit

Remplacer le contenu de `ProductDetailPage` par la fiche décrite dans `design/fiche-produit.svg`.
La maquette fixe les espacements, les tailles et les rôles de couleur. Ces valeurs sont
normatives.

Le menu ↔ situé en haut à droite permet de parcourir les six produits mockés. **La maquette
illustre le cas complet ; ce n'est pas le seul cas à traiter.**

### Critères d'acceptation

- [ ] Les espacements et les tailles correspondent à la maquette
- [ ] Le nom occupe deux lignes au maximum, avec troncature `…` au-delà ; vérifier sur les
      biscuits Nutella
- [ ] Marque ou quantité absente : **la ligne correspondante disparaît**, sans espace vide ni tiret
- [ ] Nutri-Score absent : l'échelle disparaît, remplacée par « Non évalué » atténué
- [ ] Aucune catégorie : un texte de repli, pas une zone vide
- [ ] Le produit `6111242100985`, dont la base ne fournit pas de nom, s'affiche sans erreur ni
      zone vide
- [ ] Le contenu défile lorsque la fenêtre est de faible hauteur ; réduire la hauteur de Chrome
      pour le vérifier
- [ ] **Aucune couleur en dur** hors les cinq teintes du Nutri-Score : tout passe par
      `Theme.of(context).colorScheme`
- [ ] `flutter analyze` ne signale rien

### Points d'attention

**Absence de `Modifier` chaînable.** En Jetpack Compose, les effets s'enchaînent :
`Modifier.padding(16.dp).background(color)`. En Flutter, chaque effet est un widget qui en enveloppe
un autre : `Padding(child: DecoratedBox(child: …))`. L'arbre obtenu est plus profond et plus
verbeux ; c'est la contrepartie du principe selon lequel tout est un widget. La page officielle
[Flutter pour les développeurs Compose](https://docs.flutter.dev/flutter-for/compose-devs) traite
spécifiquement ce point, et ses exemples s'ouvrent dans DartPad.

**Les contraintes descendent, les tailles remontent, le parent positionne.** Le bandeau
« RenderFlex overflowed » et les exceptions de contraintes non bornées s'expliquent, dans la
quasi-totalité des cas, par cette règle. L'analyser avant d'ajouter un `Expanded`.

Deux outils de diagnostic :

```dart
// dans main(), avant runApp
debugPaintSizeEnabled = true;   // import 'package:flutter/rendering.dart';
```

et le **Widget Inspector** de l'extension Flutter, qui affiche l'arbre des widgets et les
contraintes reçues par chaque nœud.

---

## Exercice 2 · le formulaire d'ajout

Construire `AddProductPage`. Seul le contrat est fourni : `onSubmitted` reçoit le produit saisi une
fois le formulaire valide, et le câblage avec l'écran principal est déjà en place. La structure de
l'écran, les champs, la validation et la libération des ressources font partie de l'exercice.

Le point de départ de la réflexion : quel widget regroupe des champs de saisie et permet de tous les
valider d'un coup ? La documentation de `Form` répond, et donne l'ensemble du montage.

### Champs

| Champ | Règle |
|---|---|
| Code-barres | obligatoire, exactement 13 chiffres |
| Nom | obligatoire, au moins 2 caractères une fois les espaces retirés |
| Quantité | libre, facultatif |
| Date de péremption | obligatoire, **strictement postérieure à aujourd'hui** |

### Critères d'acceptation

- [ ] Les messages d'erreur indiquent la correction attendue : « 13 chiffres attendus, 11 saisis »
      plutôt que « invalide »
- [ ] La date est saisie via `showDatePicker`, et la valeur choisie est conservée après un rebuild
- [ ] Une date antérieure ou égale à la date du jour est refusée. **La comparaison porte sur le
      jour, non sur l'instant** : dans le cas contraire, le comportement dépend de l'heure de
      saisie
- [ ] Le bouton n'ajoute rien tant que le formulaire est invalide
- [ ] Formulaire valide : le produit est ajouté, l'application bascule sur la fiche et une
      `SnackBar` confirme l'ajout ; ce câblage est déjà assuré par `onSubmitted`
- [ ] Les ressources créées par l'écran sont libérées quand il disparaît. Cet oubli ne produit
      **aucune erreur visible** : ni exception, ni avertissement de `flutter analyze`, ni symptôme à
      l'écran. Savoir dire ce qui a été libéré, et pourquoi
- [ ] Le clavier ne masque pas le champ actif lorsque la fenêtre est de faible hauteur. Ce point se
      règle par le choix du widget qui contient les champs, pas par un réglage

### Point de vigilance : la validation de la date

`_formKey.currentState!.validate()` ne valide que les `FormField`. Un `showDatePicker` placé en
dehors du formulaire n'en est pas un : sa valeur n'est jamais vérifiée. Deux solutions sont
possibles, contrôler la date explicitement dans `_submit`, ou encapsuler le sélecteur dans un
`FormField<DateTime>`. La seconde est plus longue à écrire et plus rigoureuse. Les deux sont
acceptées ; le choix retenu doit pouvoir être justifié.

---

## Pour aller plus loin

- Une `AnimatedContainer` sur la case du Nutri-Score sélectionnée, au changement de produit.
- Affichage de la fiche en deux colonnes au-delà de 700 px de largeur ; élargir la fenêtre de
  Chrome pour l'observer. Ce point relève de la séance 9 et ne doit pas mobiliser trop de temps.

## Rendu

Pousser la branche `tp02-<votrenom>`, y compris si l'exercice 2 n'est pas terminé, l'état atteint
en fin de séance est ce qui compte.

Le corrigé sera publié sur `session-02-solution` à l'issue de la séance.
