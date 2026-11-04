# Séance 1 · corrigés des exercices Dart

Solutions des exercices de [exercices-dart.md](exercices-dart.md). D'autres écritures sont
correctes dès lors qu'elles produisent la sortie attendue.

---

## 1. Null safety

```dart
List<String> nettoyer(List<String?> entrees) {
  final valides = [
    for (final e in entrees)
      if (e != null && e.trim().isNotEmpty) e,
  ];
  final manquants = entrees.length - valides.length;
  return [...valides, ...List.filled(manquants, '(sans nom)')];
}
```

Sortie : `[Nutella, Lentilles, (sans nom), (sans nom), (sans nom)]`

**À retenir**

- `e ?? '(sans nom)'` ne suffit pas : `''` et `'  '` ne sont pas `null`.
- Après le test `e != null`, `e` est promu en `String` : `e.trim()` s'écrit sans `!`.
- Un `map` qui remplace chaque entrée sur place conserve l'ordre d'origine, alors que l'énoncé
  demande les noms utilisables d'abord.
- Écriture équivalente : `where(...).toList()`, puis `addAll`.

---

## 2. Ordre d'exécution

Sortie : **`1 6 3 4 5 2`**

| Ligne | File | Motif |
|---|---|---|
| `print('1')`, `print('6')` | aucune | code synchrone, exécuté d'abord et jusqu'au bout |
| `Future.microtask(… '3')` | microtasks | première microtask planifiée |
| `scheduleMicrotask(… '4')` | microtasks | même file, après 3 |
| `Future.value().then(… '5')` | microtasks | `.then` sur un `Future` déjà complété |
| `Future(… '2')` | événements | traité une fois la file de microtasks vide |

**Erreurs fréquentes**

- `1 2 3 4 5 6` : lecture du code de haut en bas, comme s'il était entièrement synchrone.
- 5 avant 3 : `Future.value()` est déjà complété, mais son `.then` passe par la file de
  microtasks, derrière celles déjà planifiées.

---

## 3. `Future` et `async`

```dart
Future<String> fiche(String nom) async {
  final code = await chercherCode(nom);
  final calories = await chercherCalories(code);
  return '$nom : $calories kcal';
}
```

Sortie : `Nutella : 539 kcal`, après environ 800 ms.

Sans le `await` devant `fiche('Nutella')`, DartPad affiche :

```
Instance of '_Future<String>'
```

La VM, en ligne de commande, affiche `Instance of 'Future<String>'`. Aucune erreur n'est levée :
`print` accepte un `Object?`.

**À retenir**

- Les deux appels sont séquentiels, le second a besoin du résultat du premier. `Future.wait`
  sert à attendre ensemble des appels indépendants, lancés en même temps.
- Le `return` renvoie un `String` alors que le type déclaré est `Future<String>` : une fonction
  `async` enveloppe sa valeur de retour.
- Les lints `unawaited_futures` et `discarded_futures` signalent un `Future` oublié. Ils sont
  actifs dans Pantry par `very_good_analysis`.

---

## 4. `Stream`

```dart
void main() async {
  await for (final v in mesures()) {
    if (v > 40) print(v);
  }
  print('terminé');
}
```

Écriture équivalente :

```dart
  await for (final v in mesures().where((v) => v > 40)) {
    print(v);
  }
```

Sortie :

```
45
78
91
terminé
```

**À retenir**

- `await for` attend la fermeture du `Stream` : `terminé` s'affiche en dernier.
- Avec `mesures().listen(...)` suivi de `print('terminé')`, `terminé` s'affiche en premier :
  `listen` s'abonne et rend la main aussitôt.
- `async*` et `yield` correspondent au builder `flow { emit() }` de Kotlin.

---

## 5. Collection-if et spread

```dart
final menu = <String>[
  'Accueil',
  ...raccourcis,
  ...?extras,
  if (estAdmin) 'Administration',
  if (estConnecte) 'Profil',
];
```

Sortie : `[Accueil, Favoris, Historique, Profil]`

**À retenir**

- `...extras` sans `?` ne compile pas : « A nullable expression can't be used in a spread. »
- La ligne `estAdmin` est facultative : elle montre qu'un `if` faux n'ajoute rien.
- `if (estConnecte) ...[...]` combine les deux constructions, pour un groupe de widgets
  conditionnel (séance 2).

---

## 6. Sealed class et `switch` exhaustif

```dart
String decrire(Etat etat) => switch (etat) {
  Chargement() => 'chargement…',
  Donnees(:final produits) => '${produits.length} produits',
  Vide() => 'aucun résultat',
  Erreur(:final message) => 'erreur : $message',
};
```

Sortie :

```
chargement…
3 produits
aucun résultat
erreur : 502
```

Après retrait du cas `Vide` :

```
The type 'Etat' isn't exhaustively matched by the switch cases since it doesn't match the
pattern 'Vide()'. Try adding a wildcard pattern or cases that match 'Vide()'.
```

**À retenir**

- `Chargement()`, avec parenthèses, est un motif d'objet qui teste le type. Sans parenthèses,
  `Chargement` est une constante de type `Type`, comparée à la valeur : avertissement
  `constant_pattern_never_matches_value_type`, puis erreur d'exhaustivité.
- **Anti-pattern : garder le joker `_`** après les quatre cas. L'analyseur ne donne qu'un
  avertissement `unreachable_switch_case` ; une fois `Vide` retiré, plus rien n'est signalé et le
  programme affiche une ligne vide. Un joker sur une `sealed class` désactive le contrôle
  d'exhaustivité.
- Équivalent Kotlin : `sealed class` et `when` sans `else`.

---

## Pour aller plus loin

### `final` et `const`

`a`, `b`, `c` et `e` compilent ; `d` non :

```
Const variables must be initialized with a constant value.
The constructor being called isn't a const constructor.
```

`identical(c, e)` affiche **`true`** : deux littéraux `const` identiques sont un seul objet. Avec
`final` à la place de `const` sur `c` et `e`, le résultat est `false`.

### Record

```dart
(int, int, double) statistiques(List<int> valeurs) {
  var min = valeurs.first;
  var max = valeurs.first;
  var somme = 0;
  for (final v in valeurs) {
    if (v < min) min = v;
    if (v > max) max = v;
    somme += v;
  }
  return (min, max, somme / valeurs.length);
}

void main() {
  final (min, max, moyenne) = statistiques([12, 45, 3, 78, 30, 91]);
  print('min $min, max $max, moyenne $moyenne');
}
```

Sortie : `min 3, max 91, moyenne 43.166666666666664`

Variante à champs nommés : `({int min, int max, double moyenne})`, lus par `r.min`. Une liste vide
lève une `StateError` sur `first`.

### Extension

```dart
extension CodeBarres on String {
  bool get estCodeBarres => RegExp(r'^\d{13}$').hasMatch(this);
}
```

`'3017620422003'` → `true`, `'301762042200'` (12 chiffres) → `false`, `'30176204220ab'` → `false`.

### Constructeur `factory`

```dart
class Produit {
  Produit(this.nom);

  factory Produit.depuisJson(Map<String, dynamic> json) {
    final nom = json['product_name'] as String?;
    return Produit(nom ?? 'Produit sans nom');
  }

  final String nom;
}
```

`{'product_name': 'Nutella'}` → `Nutella`, `{'code': '3017620422003'}` → `Produit sans nom`.

`as String`, sans `?`, lève sur le champ absent : « type 'Null' is not a subtype of type 'String'
in type cast ». La séance 4 remplace ce code écrit à la main par `json_serializable`.
