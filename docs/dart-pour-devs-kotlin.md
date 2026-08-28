# Dart pour développeurs Kotlin

Table de correspondance à garder ouverte pendant les premières séances. Elle couvre ce qui sert
dans le cours, pas l'intégralité du langage. La référence complète est
[dart.dev/language](https://dart.dev/language).

Tous les exemples s'exécutent tels quels dans [DartPad](https://dartpad.dev).

---

## Ce qui se transpose sans effort

| Kotlin | Dart |
|---|---|
| `val x = 1` | `final x = 1` |
| `var x = 1` | `var x = 1` |
| `fun f(a: Int): String` | `String f(int a)` |
| `"texte $x"` | `'texte $x'` |
| `if / for / while` | identique |
| `listOf`, `mapOf`, `setOf` | `[…]`, `{clé: valeur}`, `{…}` |
| `data class` | `class` + `freezed` (séance 4) |
| `?.` et `?:` | `?.` et `??` |
| `is` / `as` | `is` / `as` |
| `when` (expression) | `switch` (expression, Dart 3) |

Le type se place **avant** le nom en Dart, comme en Java. C'est l'inversion la plus déroutante au
début.

---

## Null safety

Même modèle qu'en Kotlin, avec un opérateur supplémentaire.

```dart
String nom = 'Dart';        // non nullable
String? surnom;             // nullable, vaut null
int longueur = surnom!.length;  // ! : assertion, lève une erreur si null
```

| Kotlin | Dart | Remarque |
|---|---|---|
| `String?` | `String?` | identique |
| `x!!` | `x!` | un seul point d'exclamation |
| `x?.y` | `x?.y` | identique |
| `x ?: y` | `x ?? y` | `??` et non `?:` |
| `lateinit var x` | `late String x` | fonctionne aussi pour les `final` |

`late` a une capacité que `lateinit` n'a pas : l'initialisation lazy.

```dart
late final String valeur = calculCouteux();  // calculCouteux() n'est appelé
                                             // qu'au premier accès
```

**Type promotion.** Comme Kotlin, Dart promeut après un test, mais uniquement sur les variables
locales, jamais sur les champs d'instance.

```dart
void afficher(String? texte) {
  if (texte == null) return;
  print(texte.length);   // texte est promu en String ici
}
```

---

## `final` et `const`

Distinction absente de Kotlin, et centrale en Flutter.

| Mot-clé | Signification |
|---|---|
| `final` | assigné une fois, valeur calculée à l'exécution |
| `const` | valeur connue **à la compilation**, objet unique en mémoire |

```dart
final maintenant = DateTime.now();  // ok : calculé à l'exécution
const pi = 3.14159;                 // ok : littéral
// const maintenant = DateTime.now(); // erreur de compilation
```

Les objets `const` identiques sont **partagés**, pas dupliqués :

```dart
const a = [1, 2, 3];
const b = [1, 2, 3];
print(identical(a, b));   // true
```

C'est ce qui rend `const` important en Flutter : un widget `const` n'est pas reconstruit.

---

## Asynchrone

Dart n'a pas de coroutines. Il a une event loop et un seul thread par isolate.

| Kotlin | Dart |
|---|---|
| `suspend fun` | `Future<T>` + `async` |
| `.await()` | `await` |
| `Flow<T>` | `Stream<T>` |
| `collect { }` | `await for` ou `.listen()` |
| `launch { }` | appel d'une fonction `async` sans `await` |
| `Dispatchers.IO` | pas d'équivalent : voir `Isolate` |

```dart
Future<String> charger() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'chargé';
}

void main() async {
  print(await charger());
}
```

**Une fonction `async` renvoie toujours un `Future`**, même si son corps ne contient aucun `await`.
Oublier le `await` à l'appel ne provoque pas d'erreur : la fonction s'exécute, mais le résultat est
un `Future` non attendu. C'est la source d'erreur la plus fréquente.

```dart
Stream<int> compter() async* {
  for (var i = 0; i < 3; i++) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

await for (final n in compter()) {
  print(n);
}
```

Il n'y a **pas de structured concurrency** comme dans les coroutines : rien n'annule
automatiquement un `Future` en cours. L'annulation est explicite, et c'est un vrai sujet en
séance 4.

---

## Collections

```dart
final nombres = [1, 2, 3];
final carres = nombres.map((n) => n * n).toList();
final pairs = nombres.where((n) => n.isEven).toList();
final somme = nombres.fold(0, (a, b) => a + b);
```

`map` et `where` renvoient un `Iterable` **lazy**. Sans `.toList()`, rien n'est calculé, et la
valeur est recalculée à chaque parcours. Kotlin fait l'inverse : ses opérateurs sont eager, sauf
sur les `Sequence`.

**Collection-if et spread**, très utilisés dans les arbres de widgets :

```dart
final afficherTitre = true;
final widgets = [
  const Entete(),
  if (afficherTitre) const Titre(),        // collection-if
  ...autresWidgets,                        // spread
  ...?peutEtreNul,                         // null-aware spread
  for (final p in produits) Ligne(p),      // boucle dans un littéral
];
```

Cette syntaxe remplace les `if` et les boucles dans la construction d'interface. Elle est
omniprésente à partir de la séance 2.

---

## Classes

```dart
class Produit {
  const Produit({required this.code, this.nom});

  final String code;
  final String? nom;
}
```

- `required` remplace l'absence de valeur par défaut : le paramètre nommé devient obligatoire.
- `this.code` en paramètre affecte directement le champ. Pas de corps de constructeur nécessaire.
- Les paramètres **nommés** sont entre accolades, les **positionnels optionnels** entre crochets.
- Pas de `new`.

**Constructeurs nommés et `factory`**, Kotlin utilise des fonctions de compagnon, Dart les intègre :

```dart
class Produit {
  const Produit(this.code);
  const Produit.inconnu() : code = '0000000000000';   // constructeur nommé

  factory Produit.depuisJson(Map<String, dynamic> j) => Produit(j['code'] as String);

  final String code;
}
```

Un `factory` n'est pas obligé de créer une nouvelle instance : il peut renvoyer un objet en cache ou
une sous-classe. C'est ce qui le distingue d'un constructeur nommé.

---

## Sealed classes et pattern matching (Dart 3)

L'équivalent direct des `sealed class` de Kotlin, avec un `switch` qui vérifie l'exhaustivité.

```dart
sealed class Resultat {}

class Succes extends Resultat {
  Succes(this.donnees);
  final String donnees;
}

class Echec extends Resultat {
  Echec(this.message);
  final String message;
}

String decrire(Resultat r) => switch (r) {
  Succes(:final donnees) => 'ok : $donnees',
  Echec(:final message) => 'erreur : $message',
};
```

Le compilateur signale une erreur si un cas manque. **C'est la structure qui servira à modéliser
les quatre états d'interface** (chargement, données, erreur, vide) à partir de la séance 4.

`Succes(:final donnees)` déstructure au passage : équivalent de `is Succes -> r.donnees` en Kotlin,
en plus court.

---

## Records (Dart 3)

Types anonymes à plusieurs valeurs, sans déclarer de classe. Kotlin n'a que `Pair` et `Triple`.

```dart
(int, String) minEtNom() => (3, 'trois');

final (nombre, nom) = minEtNom();

// avec des champs nommés
({double lat, double lon}) position() => (lat: 48.85, lon: 2.35);
final p = position();
print(p.lat);
```

Utile pour un retour multiple ponctuel. Pour une donnée qui circule dans l'application, une classe
reste préférable : un record n'a pas de nom, donc pas de sens métier.

---

## Extensions

```dart
extension StringUtils on String {
  bool get estVide => trim().isEmpty;
}

'  '.estVide;   // true
```

Même principe qu'en Kotlin. Différence : en Dart, l'extension doit être **importée** pour être
visible, et deux extensions en conflit produisent une erreur qu'il faut lever explicitement.

---

## Ce qui n'existe pas en Dart

Utile à savoir pour arrêter de le chercher.

| Kotlin | Dart |
|---|---|
| scope functions (`let`, `apply`, `run`, `also`) | rien d'équivalent ; la cascade `..` couvre une partie des usages |
| `data class` | classe ordinaire, ou `freezed` (séance 4) |
| `object` (singleton) | variable de premier niveau, ou `static final` |
| `companion object` | membres `static` |
| surcharge d'opérateurs arbitraires | seulement une liste fixe d'opérateurs |
| coroutines, structured concurrency | `Future` / `Stream`, sans annulation automatique |
| `internal` | rien ; `_` en préfixe rend privé **au fichier**, pas à la classe |

La **cascade** `..` remplace en partie `apply` :

```dart
final liste = []
  ..add(1)
  ..add(2)
  ..add(3);
```

Chaque `..` renvoie l'objet lui-même, et non le résultat de l'appel.

**La visibilité est au niveau du fichier**, pas de la classe : un membre préfixé par `_` est
accessible depuis tout le fichier, y compris par d'autres classes. C'est ce qui permet aux classes
`_XxxState` de Flutter d'accéder aux champs privés voisins.
