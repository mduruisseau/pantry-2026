import 'package:pantry/models/product.dart';

/// Jeu de données de la séance 2.
///
/// Les six produits existent dans Open Food Facts, et leurs champs sont ceux
/// de la base, relevés le 2026-08-28. Les catégories sont une liste courte,
/// écrite à la main depuis les catégories réelles, souvent au nombre d'une
/// dizaine par produit.
///
/// Les champs absents le sont dans la base elle-même, et c'est ce qui rend
/// l'exercice réaliste :
///
///  - `3017620422003` n'a pas de contenance ;
///  - `6111180000231` n'a ni marque, ni Nutri-Score, ni catégorie
///    consommateur, ses seuls tags étant techniques ;
///  - `6111242100985` n'a pas de nom : la base n'en porte qu'un en arabe, et
///    le champ que lit l'application est vide ;
///  - `8000500310427` porte un nom long, qui éprouve la mise en page du titre.
///
/// Une fiche qui n'affiche correctement que le premier élément de la liste est
/// incomplète.
///
/// La séance 4 remplacera cette liste par des appels réseau. La forme des
/// données restera identique.
const List<Product> mockProducts = [
  Product(
    barcode: '3017620422003',
    name: 'Nutella',
    brand: 'Ferrero',
    // Contenance absente de la base : la fiche doit s'en passer.
    nutriScore: 'e',
    categories: ['Petit-déjeuners', 'Pâtes à tartiner'],
  ),
  // Produit de la maquette : tous les champs sont renseignés.
  Product(
    barcode: '3046920022651',
    name: 'Noir Intense',
    brand: 'Lindt',
    quantity: '100 g',
    nutriScore: 'e',
    categories: ['Snacks sucrés', 'Chocolats'],
  ),
  Product(
    barcode: '3229820129488',
    name: 'Muesli raisin, figue, datte, abricot',
    brand: 'Bjorg',
    quantity: '375 g',
    nutriScore: 'a',
    categories: ['Petit-déjeuners', 'Céréales'],
  ),
  // Ni marque, ni Nutri-Score, ni catégorie.
  Product(
    barcode: '6111180000231',
    name: 'Levure pâtisserie',
    quantity: '80 g',
  ),
  // Sans nom : le libellé de repli du modèle prend le relais.
  Product(
    barcode: '6111242100985',
    brand: 'Jaouda',
    quantity: '80 g',
    nutriScore: 'a',
    categories: ['Produits laitiers', 'Fromages blancs'],
  ),
  // Nom long, sur deux lignes au maximum, tronqué au-delà.
  Product(
    barcode: '8000500310427',
    name: 'Biscuits Nutella noisettes et cacao x22',
    brand: 'Nutella',
    quantity: '304 g',
    nutriScore: 'e',
    categories: ['Snacks sucrés', 'Biscuits et gâteaux'],
  ),
];
