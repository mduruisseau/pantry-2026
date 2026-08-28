import 'package:flutter/material.dart';

import 'package:pantry/models/product.dart';
import 'package:pantry/ui/widgets/expiry_label.dart';
import 'package:pantry/ui/widgets/product_image_placeholder.dart';

/// Une ligne de la liste de stock.
///
/// La vignette est enveloppée dans un `Hero` dont le `tag` est le code-barres :
/// le même tag figure sur la fiche, et Flutter anime le passage de l'une à
/// l'autre. Le tag doit être unique dans un écran donné, ce que le code-barres
/// garantit puisqu'il est l'identité d'un produit.
class ProductListTile extends StatelessWidget {
  const ProductListTile({
    required this.product,
    required this.onTap,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;

  /// Tag partagé par la vignette de la liste et celle de la fiche.
  static String heroTag(String barcode) => 'photo-$barcode';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Hero(
        tag: heroTag(product.barcode),
        child: ProductImagePlaceholder(initial: product.initial, size: 48),
      ),
      title: Text(
        product.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          // La marque disparaît quand elle est absente, comme dans la fiche.
          if (product.brand != null)
            Flexible(
              child: Text(
                product.brand!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          if (product.brand != null && product.expiresOn != null)
            Text(
              ' · ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          if (product.expiresOn != null)
            ExpiryLabel(
              expiresOn: product.expiresOn!,
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
