import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Valeurs de design propres à Pantry, que `ColorScheme` ne porte pas.
///
/// Une `ThemeExtension` est le point d'extension prévu par Material 3 : elle
/// voyage dans le `ThemeData`, se lit par `Theme.of(context).extension<T>()`,
/// et s'interpole comme le reste du thème lors d'un changement de mode.
///
/// Deux familles de valeurs cohabitent ici, et elles ne se comportent pas de
/// la même façon selon le mode :
///
///  - les cinq teintes du **Nutri-Score** sont normalisées par le dispositif.
///    Elles sont identiques en clair et en sombre, faute de quoi le code
///    couleur ne serait plus reconnaissable ;
///  - les couleurs de **péremption** dépendent du fond. Un rouge sombre sur
///    fond sombre est illisible.
@immutable
class PantryTokens extends ThemeExtension<PantryTokens> {
  const PantryTokens({
    required this.nutriA,
    required this.nutriB,
    required this.nutriC,
    required this.nutriD,
    required this.nutriE,
    required this.expirySoon,
    required this.expiryPassed,
    required this.sectionGap,
  });

  final Color nutriA;
  final Color nutriB;
  final Color nutriC;
  final Color nutriD;
  final Color nutriE;

  /// Péremption dans sept jours ou moins.
  final Color expirySoon;

  /// Date de péremption dépassée.
  final Color expiryPassed;

  /// Espacement entre deux sections de la fiche produit.
  final double sectionGap;

  /// Teinte associée à une lettre de A à E, insensible à la casse.
  ///
  /// Renvoie `null` pour une lettre inconnue plutôt qu'une couleur arbitraire :
  /// Open Food Facts renvoie parfois `not-applicable` ou une chaîne vide, et un
  /// affichage muet vaut mieux qu'une couleur fausse.
  Color? forGrade(String? grade) => switch (grade?.toLowerCase()) {
        'a' => nutriA,
        'b' => nutriB,
        'c' => nutriC,
        'd' => nutriD,
        'e' => nutriE,
        _ => null,
      };

  /// Les cinq teintes dans l'ordre de l'échelle, pour la parcourir.
  List<(String, Color)> get gradeScale => [
        ('A', nutriA),
        ('B', nutriB),
        ('C', nutriC),
        ('D', nutriD),
        ('E', nutriE),
      ];

  @override
  PantryTokens copyWith({
    Color? nutriA,
    Color? nutriB,
    Color? nutriC,
    Color? nutriD,
    Color? nutriE,
    Color? expirySoon,
    Color? expiryPassed,
    double? sectionGap,
  }) {
    return PantryTokens(
      nutriA: nutriA ?? this.nutriA,
      nutriB: nutriB ?? this.nutriB,
      nutriC: nutriC ?? this.nutriC,
      nutriD: nutriD ?? this.nutriD,
      nutriE: nutriE ?? this.nutriE,
      expirySoon: expirySoon ?? this.expirySoon,
      expiryPassed: expiryPassed ?? this.expiryPassed,
      sectionGap: sectionGap ?? this.sectionGap,
    );
  }

  /// Interpolation entre deux jeux de tokens.
  ///
  /// Appelée par Flutter pendant le changement de thème. Sans elle, les
  /// couleurs sauteraient d'un état à l'autre alors que le reste du thème
  /// s'anime.
  @override
  PantryTokens lerp(PantryTokens? other, double t) {
    if (other == null) {
      return this;
    }
    return PantryTokens(
      nutriA: Color.lerp(nutriA, other.nutriA, t)!,
      nutriB: Color.lerp(nutriB, other.nutriB, t)!,
      nutriC: Color.lerp(nutriC, other.nutriC, t)!,
      nutriD: Color.lerp(nutriD, other.nutriD, t)!,
      nutriE: Color.lerp(nutriE, other.nutriE, t)!,
      expirySoon: Color.lerp(expirySoon, other.expirySoon, t)!,
      expiryPassed: Color.lerp(expiryPassed, other.expiryPassed, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
    );
  }
}
