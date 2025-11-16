import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_item.dart';
import '../services/item_store.dart';
import '../services/budget_store.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final ItemStore _itemStore = ItemStore();
  final BudgetStore _budgetStore = BudgetStore();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _itemStore.load();
    await _budgetStore.load();
    setState(() {});
  }

  void _showEditCostDialog(GroceryItem item) {
    final currentCost = _budgetStore.getItemCost(item.id);
    final controller = TextEditingController(
      text: currentCost > 0 ? currentCost.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Cost for ${item.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Cost (\$)',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cost = double.tryParse(controller.text);
              if (cost != null && cost >= 0) {
                await _budgetStore.updateItemCost(item.id, cost);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final item in _itemStore.items) {
      final cost = _budgetStore.getItemCost(item.id);
      final totalCost = cost * item.quantity;
      totals[item.category] = (totals[item.category] ?? 0) + totalCost;
    }
    return totals;
  }

  double _getTotalCost() {
    double total = 0;
    for (final item in _itemStore.items) {
      final cost = _budgetStore.getItemCost(item.id);
      total += cost * item.quantity;
    }
    return total;
  }

  Future<void> _exportSummary() async {
    final buffer = StringBuffer();
    buffer.writeln('ChefGrocer Budget Summary');
    buffer.writeln('========================\n');
    
    final categoryTotals = _getCategoryTotals();
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    buffer.writeln('By Category:');
    for (final entry in sortedCategories) {
      buffer.writeln('${entry.key}: \$${entry.value.toStringAsFixed(2)}');
    }
    
    buffer.writeln('\nTotal: \$${_getTotalCost().toStringAsFixed(2)}');
    
    await Share.share(buffer.toString(), subject: 'ChefGrocer Budget Summary');
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _getCategoryTotals();
    final totalCost = _getTotalCost();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportSummary,
            tooltip: 'Export Summary',
          ),
        ],
      ),
      body: _itemStore.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items to budget',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Total Cost Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Total Budget',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${totalCost.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Breakdown Chart
                  if (categoryTotals.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: categoryTotals.entries.map((entry) {
                                    final percentage = (entry.value / totalCost) * 100;
                                    final colorIndex = categoryTotals.keys.toList().indexOf(entry.key);
                                    return PieChartSectionData(
                                      value: entry.value,
                                      title: '${percentage.toStringAsFixed(1)}%',
                                      color: Colors.primaries[colorIndex % Colors.primaries.length],
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: categoryTotals.entries.map((entry) {
                                final colorIndex = categoryTotals.keys.toList().indexOf(entry.key);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: Colors.primaries[colorIndex % Colors.primaries.length],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Items List
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          ..._itemStore.items.map((item) {
                            final cost = _budgetStore.getItemCost(item.id);
                            final totalItemCost = cost * item.quantity;
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.quantity} ${item.unit} × \$${cost.toStringAsFixed(2)}',
                              ),
                              trailing: Text(
                                '\$${totalItemCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () => _showEditCostDialog(item),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
