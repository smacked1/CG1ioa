import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../services/item_store.dart';

class ItemEditView extends StatefulWidget {
  final GroceryItem? item;

  const ItemEditView({super.key, this.item});

  @override
  State<ItemEditView> createState() => _ItemEditViewState();
}

class _ItemEditViewState extends State<ItemEditView> {
  final _formKey = GlobalKey<FormState>();
  final ItemStore _store = ItemStore();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late bool _starred;

  final List<String> _commonUnits = [
    'pcs',
    'kg',
    'g',
    'lb',
    'oz',
    'L',
    'mL',
    'cup',
    'tbsp',
    'tsp',
  ];

  final List<String> _commonCategories = [
    'Produce',
    'Dairy',
    'Meat',
    'Bakery',
    'Beverages',
    'Snacks',
    'Pantry',
    'Frozen',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _unitController = TextEditingController(text: widget.item?.unit ?? 'pcs');
    _categoryController = TextEditingController(
      text: widget.item?.category ?? 'Other',
    );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _starred = widget.item?.starred ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        final quantity = double.parse(_quantityController.text);

        if (widget.item == null) {
          final newItem = GroceryItem.create(
            name: _nameController.text.trim(),
            quantity: quantity,
            unit: _unitController.text.trim(),
            category: _categoryController.text.trim(),
            notes: _notesController.text.trim(),
            starred: _starred,
          );
          await _store.add(newItem);
        } else {
          final updatedItem = widget.item!.copyWith(
            name: _nameController.text.trim(),
            quantity: quantity,
            unit: _unitController.text.trim(),
            category: _categoryController.text.trim(),
            notes: _notesController.text.trim(),
            starred: _starred,
          );
          await _store.update(updatedItem);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final number = double.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _unitController.text.isEmpty
                        ? null
                        : (_commonUnits.contains(_unitController.text)
                            ? _unitController.text
                            : null),
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    items: _commonUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _unitController.text = value;
                      }
                    },
                    validator: (value) {
                      if (_unitController.text.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty
                  ? null
                  : (_commonCategories.contains(_categoryController.text)
                      ? _categoryController.text
                      : null),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _commonCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _categoryController.text = value;
                }
              },
              validator: (value) {
                if (_categoryController.text.trim().isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Starred'),
              subtitle: const Text('Mark as favorite'),
              secondary: Icon(
                _starred ? Icons.star : Icons.star_border,
                color: _starred ? Colors.amber : null,
              ),
              value: _starred,
              onChanged: (value) {
                setState(() {
                  _starred = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                isEditing ? 'Update Item' : 'Add Item',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
