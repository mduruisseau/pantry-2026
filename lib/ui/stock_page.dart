import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pantry/data/stock_scope.dart';
import 'package:pantry/models/product.dart';
import 'package:pantry/ui/widgets/product_list_tile.dart';
import 'package:pantry/ui/widgets/theme_mode_menu.dart';

/// Écran « mon stock » : recherche, liste, retrait par balayage.
///
/// L'écran ne reçoit plus rien. Le stock et ses deux opérations sont lus dans
/// le contexte par `StockScope.of(context)`, ce qui a fait disparaître les
/// trois paramètres que la table de routage devait faire descendre.
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _searchController = TextEditingController();

  /// Terme de recherche courant, en minuscules.
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Produits retenus par la recherche courante.
  ///
  /// Le filtrage est recalculé à chaque build. Sur dix-huit produits le coût
  /// est nul ; sur un stock réel il faudrait le mémoriser, ce que la séance 5
  /// obtiendra en le déplaçant dans un bloc.
  List<Product> _results(List<Product> products) {
    if (_query.isEmpty) {
      return products;
    }
    return products.where((product) {
      final name = product.name?.toLowerCase() ?? '';
      final brand = product.brand?.toLowerCase() ?? '';
      return name.contains(_query) || brand.contains(_query);
    }).toList();
  }

  Future<void> _openAddProduct(ValueChanged<Product> addProduct) async {
    // `push` renvoie la valeur passée à `pop` par l'écran suivant. Le type
    // attendu est déclaré ici : sans lui, le résultat serait un `Object?`.
    final product = await context.push<Product>('/add');
    if (product == null) {
      return;
    }
    addProduct(product);

    // `mounted` protège l'usage du `context` après un `await` : l'écran peut
    // avoir disparu entre-temps. Le lint `use_build_context_synchronously`
    // signale l'oubli, et la séance 4 revient sur ce point.
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.displayName} ajouté au stock')),
    );
  }

  void _removeProduct(Product product, ValueChanged<String> removeProduct) {
    removeProduct(product.barcode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.displayName} retiré du stock')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Un seul appel, en tête de build : l'écran dépend désormais du stock, et
    // sera reconstruit à chaque changement de liste.
    final stock = StockScope.of(context);
    final results = _results(stock.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon stock'),
        actions: const [ThemeModeMenu()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddProduct(stock.addProduct),
        tooltip: 'Ajouter un produit',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                hintText: 'Nom ou marque',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          // Expanded : sans lui, le ListView reçoit une hauteur non bornée dans
          // la Column et lève l'exception vue en séance 2.
          Expanded(
            child: results.isEmpty
                ? _EmptyResults(query: _query)
                : ListView.builder(
                    // `.builder` ne crée que les widgets visibles. La
                    // forme `ListView(children: [...])` créerait les
                    // dix-huit objets d'un coup, sans construire plus
                    // de lignes.
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return Dismissible(
                        // La clé porte l'identité de la ligne. Sans elle, la
                        // liste réutilise l'Element de la ligne retirée pour
                        // la suivante, et Flutter lève une exception.
                        key: ValueKey(product.barcode),
                        direction: DismissDirection.endToStart,
                        background: const _DismissBackground(),
                        onDismissed: (_) =>
                            _removeProduct(product, stock.removeProduct),
                        child: ProductListTile(
                          product: product,
                          onTap: () =>
                              context.go('/product/${product.barcode}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Fond révélé pendant le balayage d'une ligne.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.errorContainer,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}

/// Liste vide : le stock est vide, ou la recherche ne renvoie rien.
///
/// Un écran vide sans texte laisse croire à un défaut d'affichage.
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          query.isEmpty
              ? 'Le stock est vide. Ajouter un produit avec le bouton +.'
              : 'Aucun produit ne correspond à « $query ».',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
