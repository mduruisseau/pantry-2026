import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pantry/data/stock_scope.dart';
import 'package:pantry/router.dart';
import 'package:pantry/theme/pantry_theme.dart';
import 'package:pantry/theme/theme_mode_scope.dart';

void main() => runApp(const PantryApp());

/// Racine de l'application.
///
/// Trois enveloppes, et rien d'autre : `StockScope` porte le stock et le rend
/// lisible depuis n'importe quel écran, `ThemeModeScope` porte le mode choisi
/// (exercice bonus), `MaterialApp.router` porte les thèmes et la table de
/// routage.
///
/// L'ordre compte. Les deux portées sont **au-dessus** de
/// `MaterialApp.router` : les écrans construits par le routeur doivent les
/// voir depuis leur contexte.
///
/// Aucune donnée n'est persistée : le stock repart des produits mockés à
/// chaque rechargement. La persistance est le sujet de la séance 7.
class PantryApp extends StatefulWidget {
  const PantryApp({super.key});

  @override
  State<PantryApp> createState() => _PantryAppState();
}

class _PantryAppState extends State<PantryApp> {
  /// Le routeur est construit **une seule fois**.
  ///
  /// Le reconstruire à chaque build réinitialiserait la pile de navigation :
  /// l'écran courant reviendrait à la liste au moindre changement de stock.
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return StockScope(
      child: ThemeModeScope(
        // `Builder` fournit un contexte situé sous `ThemeModeScope` : celui de
        // cette méthode est au-dessus, et n'y verrait aucune portée.
        child: Builder(
          builder: (context) => MaterialApp.router(
            title: 'Pantry',
            debugShowCheckedModeBanner: false,
            theme: PantryTheme.light,
            darkTheme: PantryTheme.dark,
            // `ThemeMode.system` tant que rien n'est choisi dans le menu : le
            // réglage de l'appareil décide. Rien d'autre à écrire, puisque les
            // widgets ne citent aucune couleur et lisent des color roles.
            themeMode: ThemeModeScope.of(context).value,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
