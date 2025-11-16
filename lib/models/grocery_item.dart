class GroceryItem {
  final String id;
  String name;
  double quantity;
  String unit;
  String category;
  String notes;
  bool starred;
  final DateTime createdAt;
  DateTime updatedAt;

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.notes = '',
    this.starred = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryItem.create({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    String notes = '',
    bool starred = false,
  }) {
    final now = DateTime.now();
    return GroceryItem(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      notes: notes,
      starred: starred,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
      notes: json['notes'] as String? ?? '',
      starred: json['starred'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'notes': notes,
      'starred': starred,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  GroceryItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? notes,
    bool? starred,
  }) {
    return GroceryItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      starred: starred ?? this.starred,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
