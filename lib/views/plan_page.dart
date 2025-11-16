import 'package:flutter/material.dart';
import '../models/weekly_plan.dart';
import '../models/meal.dart';
import '../services/plan_store.dart';
import '../services/meal_store.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final PlanStore _planStore = PlanStore();
  final MealStore _mealStore = MealStore();

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _planStore.load();
    await _mealStore.load();
    setState(() {});
  }

  Meal? _getMeal(String mealId) {
    return _mealStore.getById(mealId);
  }

  void _showAddMealDialog(String day) {
    if (_mealStore.meals.isEmpty) {
      // No meals available, add a placeholder
      _addPlaceholderMeal(day);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Meal to $day'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _mealStore.meals.length,
            itemBuilder: (context, index) {
              final meal = _mealStore.meals[index];
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(meal.name),
                subtitle: Text('${meal.servings} servings'),
                onTap: () async {
                  await _planStore.addMealToDay(day, meal.id);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${meal.name} added to $day'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _addPlaceholderMeal(String day) async {
    // Create a placeholder meal
    final placeholderMeal = Meal.create(
      name: 'Sample Meal',
      description: 'A placeholder meal for $day',
      servings: 4,
      notes: 'Created as placeholder. Edit in Chef page.',
    );
    
    await _mealStore.add(placeholderMeal);
    await _planStore.addMealToDay(day, placeholderMeal.id);
    _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📝 Placeholder meal added to $day. Edit in Chef page.'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _planStore.currentPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final mealIds = plan.mealsByDay[day] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _showAddMealDialog(day),
                              tooltip: 'Add meal',
                            ),
                          ],
                        ),
                      ),
                      if (mealIds.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No meals planned',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ...mealIds.map((mealId) {
                          final meal = _getMeal(mealId);
                          if (meal == null) {
                            return const SizedBox.shrink();
                          }
                          return Dismissible(
                            key: Key('$day-$mealId'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              await _planStore.removeMealFromDay(day, mealId);
                              _loadData();
                            },
                            child: ListTile(
                              leading: const Icon(Icons.restaurant_menu),
                              title: Text(meal.name),
                              subtitle: meal.description.isNotEmpty
                                  ? Text(meal.description)
                                  : null,
                              trailing: Text(
                                '${meal.servings} servings',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
