class BudgetItem {
  final String groceryItemId;
  double cost;
  DateTime updatedAt;

  BudgetItem({
    required this.groceryItemId,
    required this.cost,
    required this.updatedAt,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      groceryItemId: json['groceryItemId'] as String,
      cost: (json['cost'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groceryItemId': groceryItemId,
      'cost': cost,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PriceCalculation {
  final String id;
  String itemName;
  double bulkPrice;
  double bulkQuantity;
  double singlePrice;
  double singleQuantity;
  String unit;
  final DateTime createdAt;

  PriceCalculation({
    required this.id,
    required this.itemName,
    required this.bulkPrice,
    required this.bulkQuantity,
    required this.singlePrice,
    required this.singleQuantity,
    required this.unit,
    required this.createdAt,
  });

  double get bulkUnitPrice => bulkPrice / bulkQuantity;
  double get singleUnitPrice => singlePrice / singleQuantity;
  double get savings => singleUnitPrice - bulkUnitPrice;
  double get savingsPercentage => (savings / singleUnitPrice) * 100;

  factory PriceCalculation.create({
    required String itemName,
    required double bulkPrice,
    required double bulkQuantity,
    required double singlePrice,
    required double singleQuantity,
    required String unit,
  }) {
    final now = DateTime.now();
    return PriceCalculation(
      id: now.millisecondsSinceEpoch.toString(),
      itemName: itemName,
      bulkPrice: bulkPrice,
      bulkQuantity: bulkQuantity,
      singlePrice: singlePrice,
      singleQuantity: singleQuantity,
      unit: unit,
      createdAt: now,
    );
  }

  factory PriceCalculation.fromJson(Map<String, dynamic> json) {
    return PriceCalculation(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      bulkPrice: (json['bulkPrice'] as num).toDouble(),
      bulkQuantity: (json['bulkQuantity'] as num).toDouble(),
      singlePrice: (json['singlePrice'] as num).toDouble(),
      singleQuantity: (json['singleQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'bulkPrice': bulkPrice,
      'bulkQuantity': bulkQuantity,
      'singlePrice': singlePrice,
      'singleQuantity': singleQuantity,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
