# Séance 2 · Devine le rendu

Six extraits de mise en page. Pour chacun : **écrire sa prédiction avant d'exécuter**, puis coller
le code dans [DartPad](https://dartpad.dev) et comparer.

L'exercice ne porte pas sur le résultat, mais sur l'écart entre le résultat et la prédiction.
Exécuter d'abord le vide de son intérêt.

Chaque extrait remplace le corps de cette page :

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      home: Scaffold(body: /* extrait ici */),
    ));
```

Trois questions à se poser dans l'ordre, pour chaque extrait :

1. quelles **contraintes** le parent transmet-il à son enfant ?
2. quelle **taille** l'enfant renvoie-t-il ?
3. **où** le parent le place-t-il ?

---

## A

```dart
SizedBox(
  width: 100,
  child: Container(width: 300, height: 50, color: Colors.red),
)
```

Prédiction : largeur du rectangle rouge ? ______ px

---

## B

```dart
Column(
  children: [
    const Text('Titre'),
    ListView(
      children: const [Text('a'), Text('b'), Text('c')],
    ),
  ],
)
```

Prédiction : rendu normal, rendu partiel, ou erreur ? ______

---

## C

```dart
Row(
  children: [
    Expanded(
      child: Container(height: 50, color: Colors.red),
    ),
    Expanded(
      flex: 2,
      child: Container(height: 50, color: Colors.blue),
    ),
  ],
)
```

Prédiction : largeur de chaque rectangle, sur une fenêtre de 900 px ? ______ / ______

---

## D

```dart
Center(
  child: Container(
    color: Colors.green,
    child: Column(
      children: const [Text('un'), Text('deux')],
    ),
  ),
)
```

Prédiction : hauteur de la zone verte ? ______

Ajouter ensuite `mainAxisSize: MainAxisSize.min` à la `Column`, et prédire de nouveau : ______

---

## E

```dart
Stack(
  children: [
    Expanded(
      child: Container(color: Colors.orange),
    ),
  ],
)
```

Prédiction : rendu normal, rendu partiel, ou erreur ? ______

---

## F

```dart
Row(
  children: const [
    Icon(Icons.star),
    Text('Préparation pour gâteau au chocolat noir intense et éclats de '
        'noisettes torréfiées'),
  ],
)
```

Prédiction : rendu normal, rendu partiel, ou erreur ? ______

---

# Explications

*À lire après avoir exécuté les six extraits.*

## A · la contrainte du parent l'emporte

**Largeur obtenue : 100 px**, pas 300.

`SizedBox(width: 100)` transmet une contrainte **tight** : largeur minimale et maximale égales à
100. Le `Container` demande 300, mais une contrainte tight ne laisse aucun choix. Sa demande est
ignorée sans le moindre avertissement.

C'est la première moitié de la règle : *les contraintes descendent*. Un enfant ne peut jamais sortir
des bornes que son parent lui impose.

## B · viewport de hauteur unbounded

```
Vertical viewport was given unbounded height.
```

Une `Column` transmet à ses enfants une hauteur **unbounded** : chacun prend la place qu'il veut,
la `Column` additionne ensuite. Un `ListView` fait l'inverse : il veut occuper toute la hauteur
disponible, et a donc besoin d'une borne. Les deux exigences sont incompatibles.

Trois solutions, par ordre de préférence :

| Solution | Effet |
|---|---|
| `Expanded` autour du `ListView` | lui donne la hauteur restante · le cas courant |
| `SizedBox(height: …)` | hauteur fixe, quand elle est connue |
| `shrinkWrap: true` | le `ListView` se dimensionne à son contenu, **en construisant tous ses enfants** : il perd son intérêt sur une longue liste |

## C · `flex` répartit l'espace restant

**300 px et 600 px** sur une fenêtre de 900.

`Expanded` impose à son enfant une contrainte tight calculée par la `Row` : l'espace disponible est
réparti au prorata des `flex`, ici 1 et 2. La largeur demandée par les enfants n'entre pas en compte.

`Flexible` fait la même répartition mais avec une contrainte **loose** : l'enfant peut prendre moins.

## D · `mainAxisSize` vaut `max` par défaut

**Hauteur obtenue : celle de l'écran**, alors que la `Column` ne contient que deux lignes de texte.

`Center` transmet une contrainte loose : de zéro à la hauteur disponible. La `Column`, dont
`mainAxisSize` vaut `max` par défaut, prend tout ce qu'on lui accorde.

Avec `mainAxisSize: MainAxisSize.min`, la hauteur tombe à **40 px**, la somme de ses enfants.

C'est la seconde moitié de la règle : *les tailles remontent*. La `Column` choisit sa taille dans
les bornes reçues, et ce choix dépend d'un paramètre qu'on oublie de lire.

## E · `Expanded` n'a de sens que dans un `Flex`

```
Incorrect use of ParentDataWidget.
```

`Expanded` ne dessine rien : il **annote** son enfant à l'intention du parent, pour lui indiquer
comment répartir l'espace. Seuls `Row` et `Column` (les `Flex`) savent lire cette annotation. Un
`Stack` positionne ses enfants tout autrement et ne sait pas quoi en faire.

Dans un `Stack`, l'équivalent est `Positioned`, qui est l'annotation que celui-ci comprend.

Le message d'erreur nomme le parent attendu. Le lire fait gagner du temps : il désigne le **parent
immédiat**, pas un ancêtre lointain.

## F · le débordement se peint sans interrompre

```
A RenderFlex overflowed by 393 pixels on the right.
```

Différence avec B et E : **l'application continue de tourner**. Le débordement est signalé par les
rayures jaunes et noires et par un message dans la console, mais rien ne s'arrête.

La `Row` transmet une largeur unbounded à ses enfants. Le `Text` demande la largeur de sa ligne
complète, sans retour à la ligne, ce qui dépasse. La correction est un `Expanded` autour du `Text` :
il reçoit alors une contrainte tight, et le texte passe à la ligne dans cette largeur.

Retenir la distinction :

| Symptôme | Nature |
|---|---|
| rayures jaunes et noires | dépassement · l'application tourne, la mise en page est fausse |
| écran rouge, exception | contrainte impossible · le rendu s'arrête |

---

## À retenir

> **Constraints go down. Sizes go up. Parent sets position.**
>
> Les contraintes descendent. Les tailles remontent. Le parent positionne.

- Un parent peut **imposer** une taille (contrainte `tight`, A et C) ou **laisser le choix**
  (contrainte `loose`, D).
- Un enfant choisit sa taille **dans** les bornes reçues, jamais en dehors.
- Une contrainte `unbounded` transmise à un widget qui en exige une bounded est une erreur, pas une
  approximation (B).
- Certains widgets ne dessinent rien : ils annotent, et n'ont de sens que sous le bon parent (E).

La page [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) de la
documentation officielle déroule 29 exemples à partir de cette seule règle, chacun exécutable. À
parcourir après ce TP.
