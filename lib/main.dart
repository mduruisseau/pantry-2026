import 'package:flutter/material.dart';

import 'package:pantry/data/mock_products.dart';
import 'package:pantry/models/product.dart';
import 'package:pantry/ui/add_product_page.dart';
import 'package:pantry/ui/product_detail_page.dart';

void main() => runApp(const PantryApp());

class PantryApp extends StatelessWidget {
  const PantryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F7D58)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

/// Coquille de l'application pour la séance 2.
///
/// Deux onglets, un index conservé dans l'état, `setState` pour en changer.
/// Volontairement minimal : la navigation par `Navigator` et `go_router` est
/// le sujet de la séance 3, le déport de cet état dans un bloc celui de la
/// séance 5. Cette classe illustre ce que `setState` permet.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  /// Produits mockés, plus ceux que l'utilisateur ajoute pendant la session.
  ///
  /// Aucune donnée n'est persistée : tout est perdu au rechargement de la
  /// page. La persistance est introduite en séance 7.
  late List<Product> _products = List.of(mockProducts);

  late Product _selected = _products.first;

  void _addProduct(Product product) {
    setState(() {
      _products = [..._products, product];
      _selected = product;
      _tabIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.displayName} ajouté au stock')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          ProductDetailPage(
            product: _selected,
            availableProducts: _products,
            onProductRequested: (p) => setState(() => _selected = p),
          ),
          AddProductPage(onSubmitted: _addProduct),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Fiche',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Ajouter',
          ),
        ],
      ),
    );
  }
}
