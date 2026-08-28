import 'package:flutter/material.dart';

import 'package:pantry/theme/theme_mode_scope.dart';

/// Menu de la barre supérieure : système, clair ou sombre.
///
/// Exercice bonus de la séance 3. Un widget à part : l'écran qui le place n'a
/// pas à connaître `ThemeModeScope`, et une seule ligne suffit à l'ajouter à
/// une autre barre.
class ThemeModeMenu extends StatelessWidget {
  const ThemeModeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = ThemeModeScope.of(context);

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Thème',
      icon: const Icon(Icons.brightness_6_outlined),
      onSelected: (selected) => mode.value = selected,
      itemBuilder: (context) => [
        for (final (value, label) in const [
          (ThemeMode.system, 'Système'),
          (ThemeMode.light, 'Clair'),
          (ThemeMode.dark, 'Sombre'),
        ])
          CheckedPopupMenuItem(
            value: value,
            checked: value == mode.value,
            child: Text(label),
          ),
      ],
    );
  }
}
