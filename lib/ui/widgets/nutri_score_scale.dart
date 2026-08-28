import 'package:flutter/material.dart';

import 'package:pantry/theme/pantry_tokens.dart';

/// Échelle Nutri-Score, de A à E, avec mise en avant de la lettre du produit.
///
/// Les cinq teintes viennent des tokens du thème, et non plus d'une constante
/// privée de ce fichier : elles sont désormais une décision de design, prise
/// une fois dans `lib/theme/`.
class NutriScoreScale extends StatelessWidget {
  const NutriScoreScale({required this.grade, super.key});

  /// Lettre du produit, en minuscule. `null` si le produit n'a pas été évalué.
  final String? grade;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<PantryTokens>()!;
    final selected = grade?.toLowerCase();

    return Row(
      children: [
        for (final (letter, color) in tokens.gradeScale)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _GradeBox(
              letter: letter,
              color: color,
              isSelected: letter.toLowerCase() == selected,
            ),
          ),
      ],
    );
  }
}

class _GradeBox extends StatelessWidget {
  const _GradeBox({
    required this.letter,
    required this.color,
    required this.isSelected,
  });

  final String letter;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Case sélectionnée : le fond est imposé par le dispositif Nutri-Score, la
    // couleur du texte se déduit donc de sa luminosité. Sur la case jaune, du
    // texte blanc serait illisible.
    final onSelected =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : const Color(0xFF2E332E);

    // Case atténuée : le fond est presque celui de la surface, donc la lettre
    // suit le thème. La version de la séance 2 fixait ici un gris sombre, ce
    // qui rendait les lettres illisibles en mode sombre. C'est le défaut que
    // le critère « aucune couleur en dur » fait disparaître.

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isSelected ? 44 : 36,
      height: isSelected ? 48 : 40,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(isSelected ? 7 : 6),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: isSelected ? 21 : 17,
          fontWeight: FontWeight.w700,
          color: isSelected ? onSelected : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
