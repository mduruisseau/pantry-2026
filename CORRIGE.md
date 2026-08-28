# Séance 3 · corrigé

Ce document commente les décisions. L'énoncé est dans `TP.md` de `session-03-start`.

## Navigation

**Le routeur est construit une seule fois.** `createRouter` est appelé dans un champ `late final`
de `_PantryAppState`. Le reconstruire à chaque `build` remettrait la pile de navigation à zéro :
l'écran courant reviendrait à la liste au moindre ajout de produit.

**La table de routage ne reçoit plus rien.** À la fin du premier exercice, elle prenait le stock et
ses deux opérations pour les faire descendre jusqu'aux écrans. Depuis que `StockScope` les expose,
chaque écran les lit dans son contexte : le routeur cesse de connaître une donnée qui ne le
concerne pas, et `StockPage` n'a plus aucun paramètre.

Un seul endroit lit encore le stock hors d'un écran, le `pageBuilder` de `/product/:barcode`, parce
qu'il doit résoudre le code-barres avant de choisir entre la fiche et l'écran « produit
introuvable ». `ProductDetailPage` continue de recevoir un `Product` tout fait, ce qui la laisse
utilisable sans portée au-dessus d'elle.

**`/product/:barcode` est une route imbriquée sous `/`.** Le chemin complet reste
`/product/:barcode`, mais la liste figure alors dans la pile : la flèche de retour fonctionne même
quand l'URL a été ouverte directement, sans passer par la liste.

**Deux écrans d'erreur, pas un.** Un code-barres absent du stock et une URL sans route sont deux
situations distinctes : `UnknownProductPage` répond à la première, `errorBuilder` à la seconde. Le `!`
sur `state.pathParameters['barcode']` est sûr : `go_router` n'appelle ce `pageBuilder` que si le
segment existe, et `/product/` seul part dans `errorBuilder`.

**`/add` renvoie sa valeur par `pop`.** `context.push<Product>('/add')` renvoie un
`Future<Product?>`, complété par le `context.pop(product)` du formulaire. Le callback `onSubmitted`
de la séance 2 disparaît : l'écran d'ajout ne connaît plus son appelant.

Deux conséquences visibles dans `stock_page.dart` :

- le résultat est `null` quand l'utilisateur revient sans valider, cas nominal et non erreur ;
- `mounted` est testé après l'`await` avant de toucher au `context`. Le lint
  `use_build_context_synchronously` signale l'oubli. La séance 4 revient sur ce point.

**`pageBuilder` et `MaterialPage`, plutôt que `builder`.** La détection automatique du type de page
par `go_router` échoue avec la version de Flutter du cours : la bibliothèque interroge la classe
`MaterialApp` du paquet `material_ui`, l'application utilise celle de `package:flutter/material.dart`,
et les deux classes sont distinctes. Sans correspondance, `go_router` retombe sur
`NoTransitionPage` : les écrans se remplacent sans transition et les `Hero` ne volent pas, sans
qu'aucune erreur ne soit levée. Seul l'œil remarque l'absence de transition, et aucune trace ne
désigne la cause : un comportement silencieux coûte plus cher qu'une exception.

**L'URL du web comporte un `#`.** C'est la stratégie par défaut, et elle ne demande aucune
configuration de serveur. `usePathUrlStrategy()` la remplace, au prix d'une réécriture côté
serveur, ce qui relève de la séance 9.

## Liste et clés

**`ListView.builder`, et le retrait qui modifie la source.** `Dismissible` retire son enfant de
l'arbre immédiatement, avant tout rebuild de la liste. Si `onDismissed` n'enlève pas le produit du
stock, la ligne réapparaît puis lève une exception : le widget a disparu, la donnée non.

**La clé est l'identité de la ligne, pas sa position.** `ValueKey(product.barcode)`, jamais
`ValueKey(index)`. La réconciliation d'Elements associe un ancien Element à un nouveau widget quand
le type **et** la clé correspondent. Avec l'index pour clé, retirer la première ligne fait glisser
toutes les clés d'un rang : Flutter croit que chaque ligne a changé de contenu, et l'état attaché
aux lignes suit la mauvaise donnée. Sur un `Dismissible`, l'index lève une exception dès qu'une
autre ligne que la dernière est retirée. Dans un `ListView.builder`, la clé empêche la
réutilisation d'un Element sans le déplacer : l'état d'une ligne repart de zéro, ce que
`findChildIndexCallback` évite.

C'est aussi ce qui impose au stock une entrée par code-barres : `addProduct` remplace le produit
existant au lieu d'en ajouter un second, faute de quoi deux lignes porteraient la même clé.

**Le filtrage est recalculé à chaque build.** Sur dix-huit produits, le coût est nul. Sur un stock
réel il faudrait le mémoriser, ce que la séance 5 obtient en déplaçant la recherche dans un bloc,
avec le debounce et l'annulation qui vont avec.

## Thème

**Deux thèmes, une graine.** `ColorScheme.fromSeed` calcule les color roles pour la
luminosité demandée. Écrire les deux palettes à la main donnerait deux jeux de valeurs à maintenir
en parallèle, et le mode sombre finirait par diverger du clair.

**`ThemeExtension` pour ce que `ColorScheme` ne porte pas.** Les cinq teintes du Nutri-Score et les
deux couleurs de péremption ne sont pas des color roles Material : ce sont des design tokens, des
décisions propres à
l'application. `PantryTokens` les transporte dans le `ThemeData`, et `lerp` les interpole pendant
le changement de mode comme le reste du thème.

Les deux familles ne se comportent pas de la même façon : le Nutri-Score est **identique** dans les
deux modes, parce que le code couleur est normalisé et doit rester reconnaissable ; les couleurs de
péremption **changent**, parce qu'un rouge sombre sur fond sombre est illisible.

**Le défaut que le mode sombre révèle.** La version de la séance 2 fixait la couleur des lettres
non sélectionnées de l'échelle à `Color(0xFF2E332E)`. En mode clair, personne ne le remarque ; en
mode sombre, les lettres disparaissent. Le critère « aucune couleur en dur » vise
ce cas.

La lettre sélectionnée garde `Colors.white` ou `Color(0xFF2E332E)` : son fond est une teinte
Nutri-Score, identique dans les deux modes. L'exception du critère couvre aussi le texte posé sur
ces teintes.

**`sectionGap` remplace les valeurs de la maquette.** La hauteur du séparateur vaut
`tokens.sectionGap * 2 + 1` au lieu du `49` écrit en séance 2. L'espacement devient une décision
unique.

## `InheritedWidget` écrit à la main

**Le montage compte trois classes, comme dans le framework.** `Stock` porte la donnée et rien
d'autre, `StockScope` détient l'état et expose `of(context)`, `_InheritedStock` propage et reste
**privé**. C'est exactement le trio `ThemeData` / `Theme.of` / `_InheritedTheme`, et c'est la raison
de le reprendre : l'`InheritedWidget` n'a pas à être une API publique.

Un `InheritedWidget` ne peut pas porter d'état mutable, puisque c'est un widget. Le `State` vit donc
au-dessus de lui, et `StockScope` est placé au-dessus de `MaterialApp.router` : les écrans
construits par le routeur doivent voir la portée depuis leur contexte.

**`of(context)` inscrit une dépendance.** `dependOnInheritedWidgetOfExactType` ne se contente pas
de lire : il enregistre l'`Element` appelant comme dépendant. C'est cette inscription qui permettra
à `updateShouldNotify` de le reconstruire, et elle explique pourquoi un `of(context)` appelé hors
d'un `build`, dans `initState` par exemple, pose problème.

**La recherche est en `O(1)`.** Chaque `Element` conserve une table des `InheritedWidget` visibles
depuis sa position, héritée de son parent à la construction. `Theme.of(context)` ne remonte pas
l'arbre à chaque appel : c'est une lecture de table.

**`updateShouldNotify` compare l'identité de la liste.** `!identical(ancienne, nouvelle)` suffit,
parce que `addProduct` et `removeProduct` construisent chacun une **nouvelle** liste. Ce n'est
pas `updateShouldNotify` qui rend le changement observable, c'est la façon d'écrire les deux
opérations. Une liste mutée en place laisserait les deux références
identiques, donc la comparaison fausse, donc une interface figée sans aucune erreur.

Renvoyer `true` sans condition reconstruirait tous les dépendants à chaque build du parent ;
renvoyer `false` figerait l'interface, sans exception ni avertissement de `flutter analyze`.

**L'absence de portée est une erreur de programmation.** `of` lève une assertion plutôt que de
renvoyer un stock vide : un écran placé hors de toute portée afficherait une liste vide, en silence.

**La dépendance porte sur la liste entière.** `StockPage` se reconstruit à chaque changement de
stock, ce qui est correct ici puisqu'il affiche la liste. Un compteur de favoris dans la barre
supérieure se reconstruirait aussi, sans raison. `BlocSelector`, en séance 5,
limite la reconstruction à la partie lue.

**`ExpiryLabel` formate et colore au même endroit.** La comparaison porte sur des dates ramenées à
minuit par `DateUtils.dateOnly`, et le seuil est lui-même une date, `DateUtils.addDaysToDate(today, 7)`.
Soustraire deux minuits locaux donne une durée, qui vaut 169 h sur la semaine du passage à l'heure
d'hiver : comparée à `Duration(days: 7)`, elle laisserait sans couleur un produit qui périme dans
sept jours.

## Transition `Hero`

Le `tag` est `photo-<code-barres>`, construit par `ProductListTile.heroTag` pour que la liste et la
fiche ne puissent pas diverger. Deux `Hero` de même tag dans un même écran lèvent une exception ;
le code-barres étant l'identité d'un produit, l'unicité est acquise.

Flutter interpole la position et la taille : la vignette passe de 48 à 96 px pendant la transition
de route, sans qu'aucune animation ne soit écrite.

## Bonus · la jauge en `CustomPainter`

Cinq arcs de 36° et une aiguille, dessinés dans un `SizedBox` de 220 × 110. Trois points à relever :

- le repère a son origine en haut à gauche, les angles sont en **radians**, et `0` pointe à
  droite ; un demi-tour part donc de `pi` ;
- le rayon retire la moitié de l'épaisseur du trait, sinon l'arc est rogné par les bords ; le
  centre étant remonté de cette moitié, la hauteur disponible pour le rayon diminue d'autant ;
- `shouldRepaint` compare les valeurs dessinées. Renvoyer `true` sans condition repeint à chaque
  frame, cause classique de jank reprise en séance 10.

`Semantics` porte le libellé de la jauge : un dessin n'a aucun contenu pour un lecteur d'écran. Le
sujet est traité en séance 9.

## Bonus · le choix du mode

`MaterialApp.router` reçoit `themeMode: ThemeModeScope.of(context).value`. Quatre points à relever :

- le choix vit dans `ThemeModeScope`, au-dessus de `MaterialApp.router`, pour la même raison que
  le stock : le menu est dans un écran construit par la table de routage ;
- le contexte de `_PantryAppState.build` est **au-dessus** de `ThemeModeScope`, et un `of` appelé
  avec lui échoue. Le `Builder` fournit un contexte situé dessous ;
- `InheritedNotifier` est la version du framework de ce que `StockScope` écrit à la main : il
  transporte un `ValueNotifier` et reconstruit ses dépendants à chaque notification, sans
  `updateShouldNotify` à écrire. Le `State` qui crée le `ValueNotifier` le libère dans `dispose` ;
- changer de mode reconstruit `MaterialApp.router` sans réinitialiser la pile de navigation, parce
  que le routeur est construit une seule fois, dans un `late final`. Un routeur créé dans `build`
  ramènerait à la liste à chaque changement de mode.

## Limites

- Aucune donnée n'est persistée : le stock repart des mocks au rechargement, le mode revient à
  `system`. La persistance est le sujet de la séance 7.
- Les dates de péremption des mocks sont calculées depuis le lancement (`_inDays`) : le Skyr est
  toujours périmé, les biscuits Nutella périment toujours dans trois jours.

## Points à relever au débrief

- **Quelle clé pour le `Dismissible` ?** Avec l'index, retirer une autre ligne que la dernière lève
  la même exception qu'un retrait oublié : l'`Element` de la position retirée est réutilisé pour la
  ligne suivante. Avec le code-barres, aucune exception.
- **`ListView.builder` ou `ListView(children: [...])` ?** Les deux formes ne construisent que les
  lignes visibles ; `children:` crée en plus tous les objets widget à chaque build. L'écart visible
  à 10 000 éléments vient de `SingleChildScrollView` et `Column`.
- **Reste-t-il des couleurs en dur ?** Le basculement de `prefers-color-scheme` les révèle : une
  couleur écrite dans un widget ne change pas avec le mode.
- **La table de routage reçoit-elle encore le stock ?** Non : la portée l'expose à chaque écran, et
  `StockPage` n'a plus aucun paramètre.
- **Que reconstruit un compteur de favoris placé dans la barre supérieure ?** Tout ce qui lit la
  portée se reconstruit à chaque changement de stock, compteur compris. `BlocSelector`, en
  séance 5, limite la reconstruction à la partie lue.
