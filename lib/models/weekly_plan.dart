class WeeklyPlan {
  final String id;
  Map<String, List<String>> mealsByDay; // Day -> List of Meal IDs
  DateTime weekStartDate;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;

  WeeklyPlan({
    required this.id,
    required this.mealsByDay,
    required this.weekStartDate,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyPlan.create({
    required DateTime weekStartDate,
    String notes = '',
  }) {
    final now = DateTime.now();
    return WeeklyPlan(
      id: now.millisecondsSinceEpoch.toString(),
      mealsByDay: {
        'Monday': [],
        'Tuesday': [],
        'Wednesday': [],
        'Thursday': [],
        'Friday': [],
        'Saturday': [],
        'Sunday': [],
      },
      weekStartDate: weekStartDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      id: json['id'] as String,
      mealsByDay: (json['mealsByDay'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as List<dynamic>).cast<String>()),
      ),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealsByDay': mealsByDay,
      'weekStartDate': weekStartDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WeeklyPlan copyWith({
    Map<String, List<String>>? mealsByDay,
    DateTime? weekStartDate,
    String? notes,
  }) {
    return WeeklyPlan(
      id: id,
      mealsByDay: mealsByDay ?? this.mealsByDay,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
