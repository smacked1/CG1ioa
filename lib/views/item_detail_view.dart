import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';
import '../services/item_store.dart';
import 'item_edit_view.dart';

class ItemDetailView extends StatefulWidget {
  final String itemId;

  const ItemDetailView({super.key, required this.itemId});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final ItemStore _store = ItemStore();
  GroceryItem? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() {
    setState(() {
      _item = _store.getById(widget.itemId);
    });
  }

  Future<void> _toggleStar() async {
    if (_item != null) {
      final updated = _item!.copyWith(starred: !_item!.starred);
      await _store.update(updated);
      _loadItem();
    }
  }

  Future<void> _deleteItem() async {
    if (_item != null) {
      await _store.delete(_item!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemEditView(item: _item),
      ),
    );
    _loadItem();
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
        ),
        body: const Center(
          child: Text('Item not found'),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, y \'at\' h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            icon: Icon(
              _item!.starred ? Icons.star : Icons.star_border,
              color: _item!.starred ? Colors.amber : null,
            ),
            onPressed: _toggleStar,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Item'),
                  content: Text('Are you sure you want to delete "${_item!.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteItem();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _item!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              context,
              'Quantity',
              '${_item!.quantity} ${_item!.unit}',
              Icons.shopping_cart,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Category',
              _item!.category,
              Icons.category,
            ),
            if (_item!.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailSection(
                context,
                'Notes',
                _item!.notes,
                Icons.note,
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Created',
              dateFormat.format(_item!.createdAt),
              Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Last Updated',
              dateFormat.format(_item!.updatedAt),
              Icons.update,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
