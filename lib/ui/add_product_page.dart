import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pantry/models/product.dart';

/// Écran « ajouter un produit ».
///
/// Quatre champs et une validation croisée sur la date de péremption.
///
/// Le sélecteur de date est encapsulé dans un `FormField<DateTime>`. C'est
/// plus long à écrire qu'un contrôle explicite dans `_submit`, mais la date
/// entre alors dans le cycle normal du formulaire : `validate()` la prend en
/// compte, l'erreur s'affiche au même endroit que les autres, et `reset()` la
/// remet à zéro comme le reste.
///
/// L'écran ne connaît plus son appelant : il **renvoie** le produit saisi par
/// `pop`, et c'est la liste qui l'ajoute au stock. Le callback `onSubmitted` de
/// la séance 2 a disparu avec la navigation par onglets.
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  DateTime? _expiresOn;

  @override
  void dispose() {
    // Qui crée un contrôleur le libère : `dispose` retire ses listeners et
    // interdit tout usage ultérieur. L'oubli ne déclenche aucune erreur.
    _barcodeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String? _validateBarcode(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Le code-barres est obligatoire';
    }
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return 'Le code-barres ne contient que des chiffres';
    }
    if (text.length != 13) {
      // Message qui dit quoi corriger, et non « invalide ».
      return '13 chiffres attendus, ${text.length} saisis';
    }
    return null;
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (text.length < 2) {
      return 'Le nom fait au moins 2 caractères';
    }
    return null;
  }

  String? _validateExpiry(DateTime? value) {
    if (value == null) {
      return 'La date de péremption est obligatoire';
    }
    // La comparaison porte sur le jour et non sur l'instant : DateUtils.dateOnly
    // ramène les deux dates à minuit. Sans cela, une date choisie aujourd'hui
    // serait acceptée ou refusée selon l'heure de la saisie.
    final today = DateUtils.dateOnly(DateTime.now());
    if (!DateUtils.dateOnly(value).isAfter(today)) {
      return "La date doit être postérieure à aujourd'hui";
    }
    return null;
  }

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: field.value ?? today.add(const Duration(days: 7)),
      // Le sélecteur interdit déjà le passé. Le validateur reste nécessaire :
      // il couvre le cas où aucune date n'a été choisie, que le sélecteur ne
      // peut pas empêcher.
      firstDate: today.add(const Duration(days: 1)),
      lastDate: DateTime(today.year + 10),
      helpText: 'Date de péremption',
    );
    // La page peut avoir été fermée pendant le choix de la date.
    if (picked == null || !mounted) {
      return;
    }
    // didChange enregistre la valeur dans le champ et notifie le Form, ce
    // qu'un simple setState ne ferait pas. validate efface aussitôt le
    // message d'une soumission précédente.
    field
      ..didChange(picked)
      ..validate();
    setState(() => _expiresOn = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final quantity = _quantityController.text.trim();
    final product = Product(
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      quantity: quantity.isEmpty ? null : quantity,
      expiresOn: _expiresOn,
    );

    // La valeur passée à `pop` est celle que reçoit le `push` de la liste.
    // L'écran disparaissant, il n'y a plus rien à remettre à zéro.
    context.pop(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      // ListView : le clavier réduit la hauteur disponible, et le champ actif
      // doit rester atteignable.
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Code-barres',
                helperText: '13 chiffres',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: _validateBarcode,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                helperText: 'Facultatif : « 400 g », « 1 L »…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              validator: _validateExpiry,
              builder: (field) => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date de péremption',
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                ),
                child: InkWell(
                  onTap: () => _pickDate(field),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.value == null
                              ? 'Choisir une date'
                              : _formatDate(field.value!),
                          style: field.value == null
                              ? TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Ajouter au stock'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
