# ChefGrocer

A Flutter grocery list app with offline-first local JSON storage.

## Features

- **Offline-first**: All data stored locally using JSON
- **Grocery Management**: Add, edit, delete, and view grocery items
- **Search & Filter**: Search items by name, category, or notes
- **Category Filter**: Filter items by category
- **Starred Items**: Mark favorite items and filter to show only starred
- **Dark Mode**: Automatic dark mode support based on system preferences
- **Clean Architecture**: Modular structure with Models, Views, and Services

## Project Structure

```
lib/
├── models/
│   └── grocery_item.dart      # GroceryItem model with JSON serialization
├── services/
│   └── item_store.dart        # ItemStore service for data persistence
├── views/
│   ├── item_list_view.dart    # Main list view with search and filter
│   ├── item_detail_view.dart  # Detail view for individual items
│   └── item_edit_view.dart    # Form for adding/editing items
└── main.dart                  # App entry point with theme configuration
```

## GroceryItem Model

Each grocery item includes:
- `id`: Unique identifier
- `name`: Item name
- `quantity`: Numeric quantity
- `unit`: Unit of measurement (pcs, kg, L, etc.)
- `category`: Item category (Produce, Dairy, etc.)
- `notes`: Optional notes
- `starred`: Favorite flag
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

## Building for iOS TestFlight

1. Ensure you have Flutter installed and configured for iOS development
2. Run `flutter pub get` to install dependencies
3. Open the iOS project in Xcode: `open ios/Runner.xcworkspace`
4. Configure your development team and bundle identifier
5. Build and archive for TestFlight distribution

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on iOS simulator/device
flutter run
```

## Storage

Data is stored in a JSON file at the app's documents directory:
- Path: `<app_documents>/grocery_items.json`
- Format: Array of GroceryItem JSON objects
- Automatic load on app start
- Automatic save on any data modification