import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../services/item_store.dart';
import 'item_detail_view.dart';
import 'item_edit_view.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({super.key});

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final ItemStore _store = ItemStore();
  List<GroceryItem> _displayedItems = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _showStarredOnly = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _store.load();
    _updateDisplayedItems();
  }

  void _updateDisplayedItems() {
    setState(() {
      List<GroceryItem> items = _store.items;

      if (_showStarredOnly) {
        items = items.where((item) => item.starred).toList();
      }

      if (_selectedCategory.isNotEmpty) {
        items = items.where((item) => item.category == _selectedCategory).toList();
      }

      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        items = items.where((item) {
          return item.name.toLowerCase().contains(lowerQuery) ||
              item.category.toLowerCase().contains(lowerQuery) ||
              item.notes.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      _displayedItems = items;
    });
  }

  Future<void> _toggleStar(GroceryItem item) async {
    final updated = item.copyWith(starred: !item.starred);
    await _store.update(updated);
    _updateDisplayedItems();
  }

  Future<void> _deleteItem(GroceryItem item) async {
    await _store.delete(item.id);
    _updateDisplayedItems();
  }

  void _navigateToDetail(GroceryItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailView(itemId: item.id),
      ),
    );
    _loadItems();
  }

  void _navigateToEdit([GroceryItem? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemEditView(item: item),
      ),
    );
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _store.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChefGrocer'),
        actions: [
          IconButton(
            icon: Icon(_showStarredOnly ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _showStarredOnly = !_showStarredOnly;
                _updateDisplayedItems();
              });
            },
            tooltip: 'Show starred only',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by category',
            onSelected: (category) {
              setState(() {
                _selectedCategory = category == 'All' ? '' : category;
                _updateDisplayedItems();
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'All',
                  child: Text('All Categories'),
                ),
                ...categories.map((category) => PopupMenuItem(
                      value: category,
                      child: Text(category),
                    )),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateDisplayedItems();
                });
              },
            ),
          ),
          if (_selectedCategory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Chip(
                    label: Text('Category: $_selectedCategory'),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = '';
                        _updateDisplayedItems();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _displayedItems.isEmpty
                ? Center(
                    child: Text(
                      'No items found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = _displayedItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              item.starred ? Icons.star : Icons.star_border,
                              color: item.starred ? Colors.amber : null,
                            ),
                            onPressed: () => _toggleStar(item),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity} ${item.unit}'),
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToEdit(item);
                              } else if (value == 'delete') {
                                _deleteItem(item);
                              }
                            },
                          ),
                          onTap: () => _navigateToDetail(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
