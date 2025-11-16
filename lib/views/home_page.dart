import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/item_store.dart';
import '../services/meal_store.dart';
import '../models/grocery_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemStore _itemStore = ItemStore();
  final MealStore _mealStore = MealStore();
  bool _monsterMode = false;
  List<GroceryItem> _recentItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _itemStore.load();
    await _mealStore.load();
    _loadRecentItems();
    setState(() {});
  }

  void _loadRecentItems() {
    final allItems = _itemStore.items.toList();
    allItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _recentItems = allItems.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _itemStore.items.length;
    final starredItems = _itemStore.items.where((item) => item.starred).length;
    final totalMeals = _mealStore.meals.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Monster Mode Toggle
          Tooltip(
            message: 'Monster Mode: Show only starred items across all pages',
            child: Row(
              children: [
                const Icon(Icons.star, size: 20),
                const SizedBox(width: 4),
                Switch(
                  value: _monsterMode,
                  onChanged: (value) {
                    setState(() {
                      _monsterMode = value;
                    });
                    // TODO: Implement global filter state
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_cart, size: 32, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            '$totalItems',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('Items'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.star, size: 32, color: Colors.amber),
                          const SizedBox(height: 8),
                          Text(
                            '$starredItems',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('Starred'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant_menu, size: 32, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            '$totalMeals',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('Meals'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Starred vs Total Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starred vs Total Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: totalItems > 0
                          ? PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: starredItems.toDouble(),
                                    title: 'Starred\n$starredItems',
                                    color: Colors.amber,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (totalItems - starredItems).toDouble(),
                                    title: 'Other\n${totalItems - starredItems}',
                                    color: Colors.green,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                              ),
                            )
                          : const Center(
                              child: Text('No items yet'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Edits
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Edits',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_recentItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No recent items')),
                      )
                    else
                      ..._recentItems.map((item) => ListTile(
                            leading: Icon(
                              item.starred ? Icons.star : Icons.shopping_bag,
                              color: item.starred ? Colors.amber : null,
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              'Updated ${_formatRelativeTime(item.updatedAt)}',
                            ),
                            trailing: Text(
                              '${item.quantity} ${item.unit}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
