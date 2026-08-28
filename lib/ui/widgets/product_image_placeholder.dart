import 'package:flutter/material.dart';

/// Vignette de remplacement affichée à la place de la photo du produit.
///
/// Widget fourni ; il n'est pas l'objet du TP. Aucune image n'est chargée en
/// séance 2, ni depuis le réseau ni depuis les assets. Les photos des produits
/// sont introduites en séance 4 avec l'API, leur mise en cache en séance 7.
///
/// Son placement et son dimensionnement selon la maquette font partie du
/// travail ; sa modification n'est pas nécessaire.
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    required this.initial,
    this.size = 96,
    super.key,
  });

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
