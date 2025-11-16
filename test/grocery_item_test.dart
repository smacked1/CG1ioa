import 'package:flutter_test/flutter_test.dart';
import 'package:chef_grocer/models/grocery_item.dart';

void main() {
  group('GroceryItem', () {
    test('creates item with required fields', () {
      final item = GroceryItem.create(
        name: 'Apples',
        quantity: 5,
        unit: 'pcs',
        category: 'Produce',
      );

      expect(item.name, 'Apples');
      expect(item.quantity, 5);
      expect(item.unit, 'pcs');
      expect(item.category, 'Produce');
      expect(item.starred, false);
      expect(item.notes, '');
    });

    test('creates starred item', () {
      final item = GroceryItem.create(
        name: 'Milk',
        quantity: 2,
        unit: 'L',
        category: 'Dairy',
        starred: true,
      );

      expect(item.starred, true);
    });

    test('serializes to JSON', () {
      final item = GroceryItem.create(
        name: 'Bread',
        quantity: 1,
        unit: 'pcs',
        category: 'Bakery',
        notes: 'Whole wheat',
      );

      final json = item.toJson();

      expect(json['name'], 'Bread');
      expect(json['quantity'], 1);
      expect(json['unit'], 'pcs');
      expect(json['category'], 'Bakery');
      expect(json['notes'], 'Whole wheat');
      expect(json['starred'], false);
    });

    test('deserializes from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': '12345',
        'name': 'Eggs',
        'quantity': 12,
        'unit': 'pcs',
        'category': 'Dairy',
        'notes': 'Large',
        'starred': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final item = GroceryItem.fromJson(json);

      expect(item.id, '12345');
      expect(item.name, 'Eggs');
      expect(item.quantity, 12);
      expect(item.unit, 'pcs');
      expect(item.category, 'Dairy');
      expect(item.notes, 'Large');
      expect(item.starred, true);
    });

    test('copyWith updates fields', () {
      final item = GroceryItem.create(
        name: 'Bananas',
        quantity: 6,
        unit: 'pcs',
        category: 'Produce',
      );

      final updated = item.copyWith(
        quantity: 8,
        starred: true,
      );

      expect(updated.name, 'Bananas');
      expect(updated.quantity, 8);
      expect(updated.starred, true);
      expect(updated.id, item.id);
    });
  });
}
