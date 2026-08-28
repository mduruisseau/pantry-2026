import 'package:flutter/material.dart';

import 'package:pantry/models/product.dart';
import 'package:pantry/theme/pantry_tokens.dart';
import 'package:pantry/ui/widgets/detail_section.dart';
import 'package:pantry/ui/widgets/expiry_label.dart';
import 'package:pantry/ui/widgets/nutri_score_gauge.dart';
import 'package:pantry/ui/widgets/nutri_score_scale.dart';
import 'package:pantry/ui/widgets/product_image_placeholder.dart';
import 'package:pantry/ui/widgets/product_list_tile.dart';

/// Écran « fiche produit », conforme à `design/fiche-produit.svg`.
///
/// La fiche est atteinte depuis la liste, avec le code-barres pour paramètre
/// de route. Trois ajouts par rapport à la séance 2 : la vignette est
/// l'arrivée d'une transition `Hero`, la date de péremption passe par
/// [ExpiryLabel], et les espacements viennent des tokens du thème.
///
/// Le point structurant de cet écran n'est pas la mise en page mais le
/// traitement des champs absents : chaque bloc décide de s'afficher, de se
/// remplacer par un texte de repli, ou de disparaître.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<PantryTokens>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche produit')),
      // ListView plutôt que Column : la fiche doit défiler dès que la fenêtre
      // est basse. Une Column déborderait et afficherait le bandeau rayé.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(product: product),
          const _SectionDivider(),
          DetailSection(
            title: 'Nutri-Score',
            child: product.nutriScore == null
                ? const MissingValue('Non évalué')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutriScoreScale(grade: product.nutriScore),
                      const SizedBox(height: 16),
                      NutriScoreGauge(grade: product.nutriScore!),
                    ],
                  ),
          ),
          const _SectionDivider(),
          DetailSection(
            title: 'Catégories',
            child: product.categories.isEmpty
                ? const MissingValue('Aucune catégorie renseignée')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in product.categories) Chip(label: Text(c)),
                    ],
                  ),
          ),
          const _SectionDivider(),
          DetailSection(
            title: 'Code-barres',
            child: Text(
              product.barcode,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          SizedBox(height: tokens.sectionGap),
          DetailSection(
            title: 'Péremption',
            child: product.expiresOn == null
                ? const MissingValue('Non renseignée')
                : ExpiryLabel(expiresOn: product.expiresOn!),
          ),
          SizedBox(height: tokens.sectionGap),
        ],
      ),
    );
  }

}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Départ et arrivée de la transition partagent le même tag. Flutter
        // interpole la position et la taille entre les deux écrans ; ici, la
        // vignette passe de 48 à 96 px.
        Hero(
          tag: ProductListTile.heroTag(product.barcode),
          child: ProductImagePlaceholder(initial: product.initial),
        ),
        const SizedBox(width: 16),
        // Expanded est indispensable : sans lui, la Column reçoit une
        // contrainte de largeur non bornée et le nom long déborde au lieu
        // d'être tronqué. C'est le cas d'école du modèle de contraintes.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.displayName,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Les champs absents ne laissent pas de ligne vide : le widget
              // n'est pas construit du tout.
              if (product.brand != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.brand!,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              if (product.quantity != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.quantity!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Séparateur de section, avec l'espacement du thème de part et d'autre.
///
/// La hauteur totale vaut deux espacements plus l'épaisseur du trait : la
/// valeur de la maquette n'est plus écrite ici, elle vient du token.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<PantryTokens>()!;
    return Divider(
      height: tokens.sectionGap * 2 + 1,
      thickness: 1,
      color: theme.colorScheme.outlineVariant,
    );
  }
}
