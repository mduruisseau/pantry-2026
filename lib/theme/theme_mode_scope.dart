import 'package:flutter/material.dart';

/// Rend le mode de thème choisi (système, clair ou sombre) disponible pour
/// tout le sous-arbre.
///
/// Exercice bonus de la séance 3. Le choix est lu par `MaterialApp.router` et
/// modifié depuis la liste, un écran que construit la table de routage : il
/// vit donc au-dessus des deux, comme le stock.
///
/// Même découpage que `StockScope`, à une différence près : la propagation
/// passe par `InheritedNotifier`, la version du framework de ce que
/// `StockScope` écrit à la main. Il transporte un `Listenable` et reconstruit
/// ses dépendants chaque fois que celui-ci notifie, sans `updateShouldNotify`
/// à écrire.
class ThemeModeScope extends StatefulWidget {
  const ThemeModeScope({required this.child, super.key});

  final Widget child;

  /// Mode choisi, lu et modifié par `value`.
  ///
  /// L'appel inscrit l'`Element` appelant comme dépendant : il est reconstruit
  /// à chaque changement de mode.
  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedThemeMode>();
    assert(
      inherited != null,
      'Aucun ThemeModeScope au-dessus de ce widget. '
      "Envelopper l'application dans un ThemeModeScope.",
    );
    return inherited!.notifier!;
  }

  @override
  State<ThemeModeScope> createState() => _ThemeModeScopeState();
}

class _ThemeModeScopeState extends State<ThemeModeScope> {
  /// `system` au départ : le réglage de l'appareil décide tant que rien n'est
  /// choisi dans le menu.
  final ValueNotifier<ThemeMode> _mode = ValueNotifier(ThemeMode.system);

  /// Le `State` qui crée le `ValueNotifier` le libère, comme un contrôleur.
  @override
  void dispose() {
    _mode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedThemeMode(notifier: _mode, child: widget.child);
  }
}

class _InheritedThemeMode extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const _InheritedThemeMode({required super.notifier, required super.child});
}
