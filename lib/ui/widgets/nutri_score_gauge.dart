import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pantry/theme/pantry_tokens.dart';

/// Jauge Nutri-Score : un demi-cercle gradué de A à E, aiguille sur la note.
///
/// Exercice bonus de la séance 3. Un `CustomPainter` sert quand le dessin ne se
/// compose pas de widgets existants : ici, cinq arcs et une aiguille.
///
/// Deux méthodes à écrire :
///
///  - `paint`, qui dessine dans le repère du widget : origine en haut à gauche,
///    angles en radians, zéro à droite et sens horaire ;
///  - `shouldRepaint`, qui décide si le repeint est nécessaire. Renvoyer `true`
///    sans condition repeint à chaque frame ; c'est un cas classique de jank,
///    et le sujet de la séance 10.
class NutriScoreGauge extends StatelessWidget {
  const NutriScoreGauge({required this.grade, super.key});

  /// Lettre de A à E, en minuscule dans les données.
  final String grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<PantryTokens>()!;

    return Semantics(
      label: 'Nutri-Score ${grade.toUpperCase()} sur une échelle de A à E',
      child: SizedBox(
        height: 110,
        width: 220,
        child: CustomPaint(
          painter: _GaugePainter(
            colors: [for (final (_, color) in tokens.gradeScale) color],
            index: _indexOf(grade),
            needleColor: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// Position de la lettre sur l'échelle, ou `-1` si elle est inconnue.
  static int _indexOf(String grade) =>
      const ['a', 'b', 'c', 'd', 'e'].indexOf(grade.toLowerCase());
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.colors,
    required this.index,
    required this.needleColor,
  });

  final List<Color> colors;
  final int index;
  final Color needleColor;

  @override
  void paint(Canvas canvas, Size size) {
    // L'arc occupe un demi-disque : son centre est en bas du widget, remonté
    // de la moitié de l'épaisseur du trait. Le rayon tient dans la largeur et
    // dans la hauteur restante, moins cette même moitié et une marge de 2 px :
    // aucun bord ne rogne le trait.
    const strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height - strokeWidth / 2);
    final maxRadius = math.min(size.width / 2, size.height - strokeWidth / 2);
    final radius = maxRadius - strokeWidth / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Cinq secteurs de 36°, de la gauche vers la droite : un demi-tour fait
    // pi radians, réparti sur cinq notes.
    const sweep = math.pi / 5;
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        rect,
        math.pi + i * sweep,
        // Un léger retrait sépare les secteurs sans dessiner de trait.
        sweep - 0.02,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
    }

    if (index < 0) {
      return;
    }

    // L'aiguille pointe au milieu du secteur de la note.
    final angle = math.pi + (index + 0.5) * sweep;
    final tip = center +
        Offset(math.cos(angle), math.sin(angle)) * (radius - strokeWidth);

    canvas
      ..drawLine(
        center,
        tip,
        Paint()
          ..color = needleColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(center, 5, Paint()..color = needleColor);
  }

  /// Le repeint n'a lieu que si une valeur dessinée a changé.
  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.index != index ||
      oldDelegate.needleColor != needleColor ||
      !listEquals(oldDelegate.colors, colors);
}
