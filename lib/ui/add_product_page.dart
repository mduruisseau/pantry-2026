import 'package:flutter/material.dart';

import 'package:pantry/models/product.dart';

/// Écran « ajouter un produit », **à construire, exercice 2 du TP 2**.
///
/// L'énoncé complet figure dans `TP.md`.
///
/// Seul le contrat avec le reste de l'application est fourni : `onSubmitted`
/// reçoit le produit saisi, une fois le formulaire valide. Tout le reste,
/// structure de l'écran, champs, validation, libération des ressources, fait
/// partie de l'exercice.
class AddProductPage extends StatefulWidget {
  const AddProductPage({required this.onSubmitted, super.key});

  /// Appelé avec le produit saisi quand le formulaire est valide.
  final ValueChanged<Product> onSubmitted;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'À construire : voir TP.md, exercice 2.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
