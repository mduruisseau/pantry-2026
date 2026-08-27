# Séance 1 — Dart sur DartPad

Six exercices courts, à faire dans l'ordre sur [dartpad.dev](https://dartpad.dev). Rien à installer :
DartPad tourne dans le navigateur, et fonctionne donc même si l'installation de Flutter n'est pas
terminée.

Compter cinq à dix minutes par exercice. Les correspondances Kotlin ↔ Dart sont dans
`dart-pour-devs-kotlin.md`, à garder ouvert dans un onglet.

Les exercices non terminés pendant le bloc peuvent l'être ensuite : le codelab qui suit est
auto-rythmé. **L'exercice 6 est celui à ne pas sauter** — sa structure sert de la séance 4 jusqu'à
la fin du cours.

Pour chaque exercice : le squelette est fourni, la sortie attendue est donnée. Remplacer les `TODO`.

---

## 1. Null safety

Une source de données renvoie des noms parfois absents, parfois vides. Produire une liste
d'affichage sans jamais lever d'exception.

```dart
final entrees = <String?>['Nutella', null, '  ', 'Lentilles', ''];

// TODO : produire ['Nutella', 'Lentilles', '(sans nom)', '(sans nom)', '(sans nom)']
//        dans cet ordre : les noms utilisables d'abord, les autres ensuite.
List<String> nettoyer(List<String?> entrees) {
  return [];
}

void main() => print(nettoyer(entrees));
```

**Sortie attendue**

```
[Nutella, Lentilles, (sans nom), (sans nom), (sans nom)]
```

**Points d'attention.** Une chaîne vide et une chaîne d'espaces ne sont pas `null` : `?? ` ne les
attrape pas. Le tri demandé impose de séparer avant de concaténer.

---

## 2. Ordre d'exécution

Dart a **un seul thread** et **deux files d'attente**. Prédire l'ordre d'affichage avant d'exécuter.

```dart
import 'dart:async';

void main() {
  print('1');
  Future(() => print('2'));
  Future.microtask(() => print('3'));
  scheduleMicrotask(() => print('4'));
  Future.value().then((_) => print('5'));
  print('6');
}
```

Prédiction : ______ ______ ______ ______ ______ ______

**Points d'attention.** Le code synchrone s'exécute jusqu'au bout avant toute chose. Ensuite la file
de **microtasks** est vidée **entièrement**, puis une seule entrée de la file d'**événements** est
traitée par tour. `Future(...)` alimente la file d'événements ; `.then` sur un `Future` déjà
complété alimente celle des microtasks.

Conséquence pratique : une microtask qui en planifie une autre indéfiniment bloque la file
d'événements, donc l'interface. Ce n'est pas théorique — c'est une cause de gel d'application.

---

## 3. `Future` et `async`

Deux appels réseau simulés, le second dépendant du premier.

```dart
Future<String> chercherCode(String nom) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return '3017620422003';
}

Future<int> chercherCalories(String code) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return 539;
}

// TODO : renvoyer 'Nutella : 539 kcal'
Future<String> fiche(String nom) async {
  return '';
}

void main() async {
  print(await fiche('Nutella'));
}
```

Ensuite, retirer le `await` devant `fiche('Nutella')` et observer ce qui s'affiche. **Aucune erreur
n'est levée.** C'est précisément ce qui rend cet oubli difficile à repérer.

**Points d'attention.** Une fonction `async` renvoie toujours un `Future`, même sans `await` dans
son corps. Un `await` sur un `Future` déjà complété rend lui aussi la main : la suite passe par la
file de microtasks, elle ne s'exécute pas immédiatement.

---

## 4. `Stream`

Consommer un flux de valeurs et n'en retenir qu'une partie.

```dart
Stream<int> mesures() async* {
  for (final v in [12, 45, 3, 78, 30, 91]) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield v;
  }
}

// TODO : afficher uniquement les valeurs supérieures à 40,
//        puis « terminé » à la fin du flux.
void main() async {
}
```

**Sortie attendue**

```
45
78
91
terminé
```

**Points d'attention.** Deux écritures possibles : `await for` avec un `if`, ou `.where(...)` suivi
d'un `await for`. Les deux sont correctes ; savoir laquelle vous avez utilisée.

---

## 5. Collection-if et spread

La syntaxe utilisée en permanence dans les arbres de widgets.

```dart
const estConnecte = true;
const estAdmin = false;
const raccourcis = ['Favoris', 'Historique'];
const List<String>? extras = null;

// TODO : produire ['Accueil', 'Favoris', 'Historique', 'Profil']
//        sans utiliser add(), addAll(), ni de if en dehors du littéral.
final menu = <String>[
  'Accueil',
];

void main() => print(menu);
```

**Sortie attendue**

```
[Accueil, Favoris, Historique, Profil]
```

**Points d'attention.** Trois constructions suffisent : le collection-if, le spread `...`, et le
spread null-aware `...?`. L'entrée « Profil » ne doit apparaître que si `estConnecte` est vrai.

---

## 6. Sealed class et `switch` exhaustif

La structure qui servira à modéliser les états d'interface à partir de la séance 4.

```dart
sealed class Etat {}

class Chargement extends Etat {}

class Donnees extends Etat {
  Donnees(this.produits);
  final List<String> produits;
}

class Vide extends Etat {}

class Erreur extends Etat {
  Erreur(this.message);
  final String message;
}

// TODO : renvoyer, selon le cas :
//   Chargement -> 'chargement…'
//   Donnees    -> '3 produits'   (le nombre réel)
//   Vide       -> 'aucun résultat'
//   Erreur     -> 'erreur : <message>'
String decrire(Etat etat) => switch (etat) {
  _ => '',
};

void main() {
  for (final e in [Chargement(), Donnees(['a', 'b', 'c']), Vide(), Erreur('502')]) {
    print(decrire(e));
  }
}
```

**Sortie attendue**

```
chargement…
3 produits
aucun résultat
erreur : 502
```

Une fois que cela fonctionne, **retirer le cas `Vide`** et lire l'erreur de compilation. C'est la
propriété la plus utile de cette construction : un état ajouté au modèle ne peut pas être oublié
dans l'interface.

**Points d'attention.** Le motif `Donnees(:final produits)` déstructure directement — équivalent
d'un `is` suivi d'un accès au champ, en plus court.

---

## Pour aller plus loin

Si les six exercices sont terminés avant la fin du bloc.

**`final` et `const`.** Prédire lesquelles de ces déclarations compilent, puis vérifier.

```dart
final a = DateTime.now();
const b = 3.14;
const c = [1, 2, 3];
// const d = DateTime.now();

const e = [1, 2, 3];
print(identical(c, e));   // prédire avant d'exécuter
```

`identical` compare les références. Le résultat explique pourquoi `const` compte en Flutter : deux
widgets `const` identiques sont un seul objet, et un widget `const` n'est pas reconstruit.

**Record.** Écrire une fonction renvoyant à la fois le minimum, le maximum et la moyenne d'une
`List<int>`, sans déclarer de classe.

**Extension.** Ajouter à `String` une propriété `estCodeBarres` qui vérifie 13 caractères, tous
numériques. Elle resservira en séance 2.

**Constructeur `factory`.** Écrire `Produit.depuisJson(Map<String, dynamic>)` qui tolère un champ
`product_name` absent et retombe sur `'Produit sans nom'`.
