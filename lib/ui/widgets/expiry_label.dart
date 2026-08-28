import 'package:flutter/material.dart';

import 'package:pantry/theme/pantry_tokens.dart';

/// Date de péremption, dans la couleur qui correspond à son urgence.
///
/// Un seul widget pour la liste et pour la fiche : la règle des sept jours et
/// le choix des couleurs sont écrits une fois.
class ExpiryLabel extends StatelessWidget {
  const ExpiryLabel({required this.expiresOn, this.style, super.key});

  final DateTime expiresOn;

  /// Style de base, auquel la couleur d'urgence est appliquée.
  final TextStyle? style;

  /// Nombre de jours au-delà duquel une péremption n'est plus signalée.
  static const warningDays = 7;

  /// Formatage manuel, volontairement.
  ///
  /// Le paquet `intl` formaterait la date selon la locale, sujet de la
  /// séance 10.
  static String format(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<PantryTokens>()!;

    // La comparaison porte sur des dates, pas sur une durée. Deux minuits
    // locaux sont séparés de 169 h la semaine du passage à l'heure d'hiver :
    // comparée à sept jours, la différence ferait glisser le seuil.
    final today = DateUtils.dateOnly(DateTime.now());
    final expiry = DateUtils.dateOnly(expiresOn);
    final limit = DateUtils.addDaysToDate(today, warningDays);

    final color = switch (expiry) {
      final d when d.isBefore(today) => tokens.expiryPassed,
      final d when !d.isAfter(limit) => tokens.expirySoon,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Text(
      format(expiresOn),
      style: (style ?? theme.textTheme.bodyMedium)?.copyWith(color: color),
    );
  }
}
