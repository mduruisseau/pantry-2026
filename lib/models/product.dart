/// Un produit alimentaire, tel que Pantry le manipule.
///
/// Modèle en Dart pur pour la séance 2 : ni `freezed`, ni `json_serializable`.
/// La génération de code est introduite en séance 4, lors du branchement sur
/// l'API réelle.
///
/// La plupart des champs sont nullables. Open Food Facts est alimenté par ses
/// contributeurs : un produit peut ne comporter ni nom, ni image, ni
/// Nutri-Score. Une interface qui suppose ces champs présents échoue dès le
/// premier produit incomplet. Les données de `data/mock_products.dart`
/// reproduisent ces cas.
class Product {
  const Product({
    required this.barcode,
    this.name,
    this.brand,
    this.quantity,
    this.nutriScore,
    this.categories = const [],
    this.expiresOn,
  });

  /// Code-barres (EAN-13 le plus souvent). Seul champ toujours présent :
  /// c'est la clé du produit.
  final String barcode;

  final String? name;
  final String? brand;

  /// Contenance telle qu'écrite sur l'emballage : « 400 g », « 1 L »…
  /// Texte libre et non numérique : ne pas le parser.
  final String? quantity;

  /// Lettre de A à E, en minuscule dans les données. `null` quand le produit
  /// n'a pas été évalué.
  final String? nutriScore;

  final List<String> categories;

  /// Date de péremption. Elle ne caractérise pas le produit mais l'exemplaire
  /// détenu, et elle est saisie par l'utilisateur.
  final DateTime? expiresOn;

  /// Libellé d'affichage, jamais nul.
  ///
  /// La valeur de repli est définie une fois par le modèle, et non répétée
  /// dans chaque widget sous la forme `?? 'Sans nom'`.
  String get displayName => name?.trim().isNotEmpty ?? false
      ? name!.trim()
      : 'Produit sans nom';

  /// Initiale utilisée par la vignette de remplacement.
  String get initial =>
      displayName.isEmpty ? '?' : displayName[0].toUpperCase();
}
