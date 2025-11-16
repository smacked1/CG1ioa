class Meal {
  final String id;
  String name;
  String description;
  List<String> ingredients; // List of GroceryItem IDs
  int servings;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;

  Meal({
    required this.id,
    required this.name,
    this.description = '',
    required this.ingredients,
    this.servings = 4,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meal.create({
    required String name,
    String description = '',
    List<String> ingredients = const [],
    int servings = 4,
    String notes = '',
  }) {
    final now = DateTime.now();
    return Meal(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      ingredients: ingredients,
      servings: servings,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      servings: json['servings'] as int? ?? 4,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'servings': servings,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Meal copyWith({
    String? name,
    String? description,
    List<String>? ingredients,
    int? servings,
    String? notes,
  }) {
    return Meal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      servings: servings ?? this.servings,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
