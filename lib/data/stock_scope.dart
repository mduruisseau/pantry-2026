import 'package:flutter/material.dart';

import 'package:pantry/data/mock_products.dart';
import 'package:pantry/models/product.dart';

/// Ce qu'un écran voit du stock : la liste, et les deux opérations.
///
/// Classe immuable, distincte du widget qui la transporte. C'est la même
/// séparation que `ThemeData` et `Theme` : la donnée d'un côté, sa propagation
/// de l'autre.
@immutable
class Stock {
  const Stock({
    required this.products,
    required this.addProduct,
    required this.removeProduct,
  });

  /// Stock complet, dans l'ordre d'ajout. Filtrer relève de l'écran.
  final List<Product> products;

  /// Ajoute un produit, ou remplace celui qui porte le même code-barres.
  final ValueChanged<Product> addProduct;

  /// Retire du stock le produit portant ce code-barres.
  final ValueChanged<String> removeProduct;
}

/// Rend le stock disponible pour tout le sous-arbre.
///
/// Trois classes coopèrent, comme dans le framework :
///
///  - [Stock] porte la donnée, et rien d'autre ;
///  - [StockScope] détient l'état et expose le point d'entrée `of(context)` ;
///  - `_InheritedStock` propage la donnée, et reste **privé**.
///
/// `Theme` procède exactement ainsi avec `ThemeData` et `_InheritedTheme` :
/// l'`InheritedWidget` n'est pas une API publique, la méthode statique l'est.
///
/// Un `InheritedWidget` ne peut pas porter d'état mutable, puisque c'est un
/// widget. Le `State` vit donc au-dessus de lui et le reconstruit à chaque
/// modification.
class StockScope extends StatefulWidget {
  const StockScope({required this.child, super.key});

  final Widget child;

  /// Stock visible depuis [context].
  ///
  /// L'appel inscrit l'`Element` appelant dans la liste des dépendants : il
  /// sera reconstruit à chaque changement de stock. C'est le comportement
  /// attendu, et c'est aussi sa limite, reprise en séance 5 : la dépendance
  /// porte sur la liste entière, pas sur ce que l'écran en affiche.
  ///
  /// L'absence de portée est traitée comme une erreur de programmation plutôt
  /// que comme un stock vide : un écran sans `StockScope` au-dessus de lui
  /// afficherait une liste vide sans que rien ne le signale.
  static Stock of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedStock>();
    assert(
      inherited != null,
      'Aucun StockScope au-dessus de ce widget. '
      "Envelopper l'application dans un StockScope.",
    );
    return inherited!.stock;
  }

  @override
  State<StockScope> createState() => _StockScopeState();
}

class _StockScopeState extends State<StockScope> {
  late List<Product> _products = List.of(mockProducts);

  /// Ajoute un produit, ou remplace celui qui porte le même code-barres.
  ///
  /// Le code-barres est l'identité d'un produit : deux exemplaires du même
  /// article ne forment qu'une entrée. Cette règle est ce qui autorise
  /// `ValueKey(product.barcode)` dans la liste.
  ///
  /// Une **nouvelle liste** est construite à chaque fois, au lieu d'ajouter à
  /// l'ancienne. C'est ce qui rend le changement détectable par
  /// `updateShouldNotify`.
  void _addProduct(Product product) {
    setState(() {
      final index = _products.indexWhere((p) => p.barcode == product.barcode);
      _products = index == -1
          ? [..._products, product]
          : [
              ..._products.sublist(0, index),
              product,
              ..._products.sublist(index + 1),
            ];
    });
  }

  void _removeProduct(String barcode) {
    setState(() {
      _products = _products.where((p) => p.barcode != barcode).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStock(
      stock: Stock(
        products: _products,
        addProduct: _addProduct,
        removeProduct: _removeProduct,
      ),
      child: widget.child,
    );
  }
}

class _InheritedStock extends InheritedWidget {
  const _InheritedStock({required this.stock, required super.child});

  final Stock stock;

  /// Reconstruit les dépendants quand la liste **change d'identité**.
  ///
  /// `identical` suffit parce que chaque opération construit une nouvelle
  /// liste. Muter la liste existante à la place laisserait cette comparaison
  /// vraie à chaque fois : l'interface ne se mettrait jamais à jour, sans
  /// qu'aucune erreur ne soit levée. L'immuabilité n'est pas une coquetterie,
  /// c'est ce qui rend le changement observable.
  ///
  /// Renvoyer `true` sans condition reconstruirait tous les dépendants à
  /// chaque build du parent ; renvoyer `false` figerait l'interface.
  @override
  bool updateShouldNotify(_InheritedStock oldWidget) =>
      !identical(oldWidget.stock.products, stock.products);
}
