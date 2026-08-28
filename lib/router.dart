import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pantry/data/stock_scope.dart';
import 'package:pantry/ui/add_product_page.dart';
import 'package:pantry/ui/product_detail_page.dart';
import 'package:pantry/ui/stock_page.dart';

/// Table de routage de l'application.
///
/// Une fiche ouverte par `go` a sa propre URL, ce que `push`
/// ne donne pas : c'est ce qui distingue `go_router` du `Navigator`
/// impératif. Sur le web, l'URL de la barre d'adresse devient la
/// source de vérité : coller `/product/3017620422003` ouvre la fiche, et le
/// bouton « Retour » du navigateur fonctionne sans code supplémentaire.
///
/// **La table ne reçoit plus rien.** Dans l'état obtenu à la fin du premier
/// exercice, elle prenait le stock et ses deux opérations en paramètres, pour
/// les faire descendre jusqu'aux écrans. Depuis que `StockScope` les expose,
/// chaque écran les lit dans son contexte, et le routeur cesse de connaître
/// une donnée qui ne le concerne pas.
///
/// **Les routes déclarent `pageBuilder` et non `builder`.** Avec `builder`,
/// `go_router` choisit le type de page en cherchant un `MaterialApp` au-dessus
/// de lui. Cette détection échoue avec la version de Flutter du cours :
/// `go_router 18` interroge la classe `MaterialApp` du paquet `material_ui`,
/// tandis que l'application utilise celle de `package:flutter/material.dart`.
/// Faute de correspondance, chaque route devient une `NoTransitionPage` : les
/// écrans apparaissent sans transition, et les `Hero` ne volent pas. Aucune
/// erreur n'est levée. Déclarer `MaterialPage` explicitement lève l'ambiguïté,
/// et c'est de toute façon le point d'accroche des transitions personnalisées.
GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(
          name: 'stock',
          child: StockPage(),
        ),
        routes: [
          // Route imbriquée : son chemin complet est `/product/:barcode`, et
          // un retour depuis la fiche revient sur la liste même lorsque l'URL
          // a été ouverte directement.
          GoRoute(
            path: 'product/:barcode',
            pageBuilder: (context, state) {
              // Le paramètre existe dès que la route correspond : `/product/`
              // seul part dans `errorBuilder`. Rien ne garantit en revanche
              // qu'il désigne un produit du stock.
              final barcode = state.pathParameters['barcode']!;
              final products = StockScope.of(context).products;
              final matches = products.where((p) => p.barcode == barcode);

              return MaterialPage(
                name: 'product',
                child: matches.isEmpty
                    ? UnknownProductPage(barcode: barcode)
                    : ProductDetailPage(product: matches.first),
              );
            },
          ),
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) => const MaterialPage(
              name: 'add',
              child: AddProductPage(),
            ),
          ),
        ],
      ),
    ],
    // Route inconnue : une URL mal tapée affiche un écran, jamais l'écran
    // rouge de debug.
    errorBuilder: (context, state) =>
        UnknownRoutePage(location: state.uri.path),
  );
}

/// Fiche demandée pour un code-barres absent du stock.
class UnknownProductPage extends StatelessWidget {
  const UnknownProductPage({required this.barcode, super.key});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche produit')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun produit du stock ne porte le code-barres $barcode.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Revenir au stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// URL qui ne correspond à aucune route.
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aucun écran ne correspond à $location.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Revenir au stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
