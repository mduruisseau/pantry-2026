# Séance 2 · Devine le rendu

Huit extraits de mise en page. Pour chacun : **écrire sa prédiction avant d'exécuter**, puis coller
le code dans [DartPad](https://dartpad.dev) et comparer.

L'exercice ne porte pas sur le résultat, mais sur l'écart entre le résultat et la prédiction.
Exécuter d'abord le vide de son intérêt.

Chaque extrait remplace le corps de cette page :

```dart
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
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

## G

```dart
SizedBox(
  width: 200,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 100),
    child: Container(height: 50, color: Colors.red),
  ),
)
```

Prédiction : largeur du rectangle rouge ? ______ px

Retirer ensuite le `SizedBox` en gardant le `ConstrainedBox`, et prédire de nouveau : ______ px

---

## H

```dart
SizedBox(
  width: 200,
  height: 200,
  child: Container(width: 50, height: 50, color: Colors.blue),
)
```

Prédiction : taille du carré bleu ? ______

Envelopper ensuite le `Container` dans `Align(alignment: Alignment.bottomRight, child: …)`, et
prédire de nouveau : taille et position du carré bleu ? ______

---

# Explications

*À lire après avoir exécuté les huit extraits.*

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

**Rendu partiel** : le titre s'affiche, la liste non. L'application ne s'arrête pas, l'erreur est
dans la console.

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

**Rendu d'apparence normale** : l'écran est orange. L'erreur n'est visible que dans la console.

`Expanded` ne dessine rien : il **annote** son enfant à l'intention du parent, pour lui indiquer
comment répartir l'espace. Seuls `Row` et `Column` (les `Flex`) savent lire cette annotation. Un
`Stack` positionne ses enfants tout autrement et ne sait pas quoi en faire.

Dans un `Stack`, l'équivalent est `Positioned`, qui est l'annotation que celui-ci comprend.

Le message d'erreur nomme le parent attendu. Le lire fait gagner du temps : il désigne le **parent
immédiat**, pas un ancêtre lointain. Un écran juste ne prouve pas un code juste : la console se lit
même quand le rendu semble correct.

## F · le débordement se peint sans interrompre

```
A RenderFlex overflowed by N pixels on the right.
```

Comme en B et E, **l'application continue de tourner**. Le dépassement est signalé par les rayures
jaunes et noires et par un message dans la console ; le nombre de pixels dépend de la largeur de la
fenêtre.

La `Row` transmet une largeur unbounded à ses enfants. Le `Text` demande la largeur de sa ligne
complète, sans retour à la ligne, ce qui dépasse. La correction est un `Expanded` autour du `Text` :
il reçoit alors une contrainte tight, et le texte passe à la ligne dans cette largeur.

Retenir les quatre cas :

| À l'écran | Nature | Exemple |
|---|---|---|
| rayures jaunes et noires | dépassement de place | F |
| une zone non peinte | erreur de layout, contrainte impossible | B |
| un rendu d'apparence normale | annotation sous le mauvais parent | E |
| écran rouge | exception levée pendant un `build` | un `null` déréférencé dans `build` |

Dans les quatre cas, le message est dans la console, et il nomme le widget fautif.

## G · un `ConstrainedBox` reste dans les bornes du parent

**Largeur obtenue : 200 px**, pas 100. Sans le `SizedBox` : **100 px**.

`ConstrainedBox` n'impose pas ses bornes : il les combine avec celles qu'il reçoit, et celles du
parent l'emportent (`BoxConstraints.enforce`). Sous `SizedBox(width: 200)`, la largeur reçue est
tight à 200 : le `maxWidth: 100` est ramené à 200, sans avertissement.

Sans le `SizedBox`, le `Scaffold` transmet une contrainte loose, de 0 à la largeur de la fenêtre. Le
`ConstrainedBox` la resserre de 0 à 100, et le `Container`, qui n'a ni enfant ni largeur, prend le
maximum : 100 px.

L'extrait A suit le même mécanisme : `Container(width: 300)` pose en interne un `ConstrainedBox`
(`BoxConstraints.tightFor(width: 300)`), que la contrainte tight du parent rend inopérant.

## H · `Align` relâche la contrainte

**Sans `Align` : 200 × 200**, la demande de 50 × 50 est ignorée, comme en A.

**Avec `Align` : 50 × 50, dans le coin inférieur droit** du carré de 200, décalé de 150 px sur
chaque axe. L'`Align` lui-même mesure 200 × 200.

`Align` reçoit la contrainte tight du `SizedBox` et prend toute la place permise. Il transmet à son
enfant la même contrainte relâchée (`constraints.loosen()`), de 0 à 200 sur chaque axe : le
`Container` obtient la taille qu'il demande, et `Align` le place selon `alignment`.

`Center` est un `Align` dont l'alignement vaut `Alignment.center` : c'est la contrainte loose de
l'extrait D. Pour libérer un enfant d'une contrainte tight, il faut un widget intermédiaire qui la
relâche ; aucun réglage de l'enfant n'y suffit.

---

## À retenir

> **Constraints go down. Sizes go up. Parent sets position.**
>
> Les contraintes descendent. Les tailles remontent. Le parent positionne.

- Un parent peut **imposer** une taille (contrainte `tight`, A, C et G) ou **laisser le choix**
  (contrainte `loose`, D et H).
- Un enfant choisit sa taille **dans** les bornes reçues, jamais en dehors. Un `ConstrainedBox`
  resserre les bornes sans pouvoir les élargir (G) ; `Align` et `Center` les relâchent (H).
- Une contrainte `unbounded` transmise à un widget qui en exige une bounded est une erreur, pas une
  approximation (B).
- Certains widgets ne dessinent rien : ils annotent, et n'ont de sens que sous le bon parent (E).

La page [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) de la
documentation officielle déroule 29 exemples à partir de cette seule règle, chacun exécutable. À
parcourir après ce TP.
