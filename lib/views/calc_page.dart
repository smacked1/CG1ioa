import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/budget_store.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BudgetStore _budgetStore = BudgetStore();

  // Price Comparison Controllers
  final _itemNameController = TextEditingController();
  final _bulkPriceController = TextEditingController();
  final _bulkQuantityController = TextEditingController();
  final _singlePriceController = TextEditingController();
  final _singleQuantityController = TextEditingController();
  String _selectedUnit = 'pcs';

  // Recipe Scaling Controllers
  final _originalServingsController = TextEditingController(text: '4');
  final _desiredServingsController = TextEditingController(text: '6');
  final List<Map<String, dynamic>> _ingredients = [];

  PriceCalculation? _currentComparison;

  final List<String> _commonUnits = [
    'pcs',
    'kg',
    'g',
    'lb',
    'oz',
    'L',
    'mL',
    'cup',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemNameController.dispose();
    _bulkPriceController.dispose();
    _bulkQuantityController.dispose();
    _singlePriceController.dispose();
    _singleQuantityController.dispose();
    _originalServingsController.dispose();
    _desiredServingsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _budgetStore.load();
    setState(() {});
  }

  void _calculatePriceComparison() {
    final bulkPrice = double.tryParse(_bulkPriceController.text);
    final bulkQty = double.tryParse(_bulkQuantityController.text);
    final singlePrice = double.tryParse(_singlePriceController.text);
    final singleQty = double.tryParse(_singleQuantityController.text);

    if (bulkPrice != null &&
        bulkQty != null &&
        singlePrice != null &&
        singleQty != null &&
        _itemNameController.text.isNotEmpty) {
      final calc = PriceCalculation.create(
        itemName: _itemNameController.text,
        bulkPrice: bulkPrice,
        bulkQuantity: bulkQty,
        singlePrice: singlePrice,
        singleQuantity: singleQty,
        unit: _selectedUnit,
      );

      setState(() {
        _currentComparison = calc;
      });

      _budgetStore.addCalculation(calc);
    }
  }

  void _clearPriceComparison() {
    setState(() {
      _itemNameController.clear();
      _bulkPriceController.clear();
      _bulkQuantityController.clear();
      _singlePriceController.clear();
      _singleQuantityController.clear();
      _currentComparison = null;
    });
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': '',
        'quantity': 1.0,
      });
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  double _getScaledQuantity(double originalQty) {
    final originalServings = double.tryParse(_originalServingsController.text) ?? 4;
    final desiredServings = double.tryParse(_desiredServingsController.text) ?? 6;
    return originalQty * (desiredServings / originalServings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Price Compare', icon: Icon(Icons.compare_arrows)),
            Tab(text: 'Recipe Scale', icon: Icon(Icons.scale)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPriceCompareTab(),
          _buildRecipeScaleTab(),
        ],
      ),
    );
  }

  Widget _buildPriceCompareTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk vs Single Price',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bulkPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Bulk Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _bulkQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Bulk Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _singlePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Single Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _singleQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Single Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _commonUnits.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value ?? 'pcs';
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculatePriceComparison,
                        child: const Text('Calculate'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _clearPriceComparison,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_currentComparison != null) ...[
          const SizedBox(height: 16),
          Card(
            color: _currentComparison!.savings > 0
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results for ${_currentComparison!.itemName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bulk Unit Price:'),
                      Text(
                        '\$${_currentComparison!.bulkUnitPrice.toStringAsFixed(4)}/${_currentComparison!.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Single Unit Price:'),
                      Text(
                        '\$${_currentComparison!.singleUnitPrice.toStringAsFixed(4)}/${_currentComparison!.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_currentComparison!.savings > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Savings:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${_currentComparison!.savings.toStringAsFixed(4)}/${_currentComparison!.unit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Percentage:'),
                        Text(
                          '${_currentComparison!.savingsPercentage.toStringAsFixed(1)}% cheaper',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      'Single purchase is cheaper!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (_budgetStore.calculations.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Calculations',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () async {
                          await _budgetStore.clearCalculations();
                          _loadData();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  ..._budgetStore.calculations.take(5).map((calc) => ListTile(
                        title: Text(calc.itemName),
                        subtitle: Text(
                          'Bulk: \$${calc.bulkUnitPrice.toStringAsFixed(4)} vs Single: \$${calc.singleUnitPrice.toStringAsFixed(4)}',
                        ),
                        trailing: calc.savings > 0
                            ? Text(
                                '${calc.savingsPercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(Icons.info, color: Colors.orange),
                        onTap: () {
                          setState(() {
                            _itemNameController.text = calc.itemName;
                            _bulkPriceController.text = calc.bulkPrice.toString();
                            _bulkQuantityController.text = calc.bulkQuantity.toString();
                            _singlePriceController.text = calc.singlePrice.toString();
                            _singleQuantityController.text = calc.singleQuantity.toString();
                            _selectedUnit = calc.unit;
                            _currentComparison = calc;
                          });
                        },
                      )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipeScaleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipe Scaling',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _originalServingsController,
                        decoration: const InputDecoration(
                          labelText: 'Original Servings',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.arrow_forward),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _desiredServingsController,
                        decoration: const InputDecoration(
                          labelText: 'Desired Servings',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                ),
              ],
            ),
          ),
        ),
        if (_ingredients.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  ..._ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    final scaledQty = _getScaledQuantity(ingredient['quantity'] as double);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index]['name'] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index]['quantity'] = double.tryParse(value) ?? 1.0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '→ ${scaledQty.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeIngredient(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
