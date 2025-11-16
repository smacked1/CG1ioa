# ChefGrocer - Technical Documentation

## Overview

ChefGrocer is a Flutter-based grocery list application designed with an offline-first architecture. All data is stored locally using JSON files, making it perfect for users who need a reliable grocery list app without requiring an internet connection.

## Architecture

### Modular Structure

The application follows a clean, modular architecture:

```
lib/
├── models/          # Data models
├── services/        # Business logic and data persistence
├── views/          # UI components
└── main.dart       # Application entry point
```

### Key Components

#### 1. Models (`lib/models/`)

**GroceryItem** (`grocery_item.dart`)
- Core data model representing a grocery item
- Fields:
  - `id`: Unique identifier (timestamp-based)
  - `name`: Item name
  - `quantity`: Numeric quantity (double)
  - `unit`: Unit of measurement (pcs, kg, L, etc.)
  - `category`: Classification (Produce, Dairy, etc.)
  - `notes`: Optional user notes
  - `starred`: Boolean flag for favorites
  - `createdAt`: Creation timestamp
  - `updatedAt`: Last modification timestamp

- Methods:
  - `create()`: Factory constructor for new items
  - `fromJson()`: Deserialize from JSON
  - `toJson()`: Serialize to JSON
  - `copyWith()`: Create modified copy

#### 2. Services (`lib/services/`)

**ItemStore** (`item_store.dart`)
- Singleton service managing all grocery items
- Responsibilities:
  - Load items from JSON file on app start
  - Save items to JSON file after modifications
  - CRUD operations: add, update, delete items
  - Query operations: search, filter by category, get starred items
  - Category management

- Storage location: `<app_documents>/grocery_items.json`
- Automatic persistence on all data changes

#### 3. Views (`lib/views/`)

**ItemListView** (`item_list_view.dart`)
- Main screen displaying all grocery items
- Features:
  - Search bar for filtering items
  - Category filter dropdown
  - Starred-only toggle
  - List/Grid display of items
  - Quick star/unstar from list
  - Navigation to detail/edit views
  - Floating action button to add new items

**ItemDetailView** (`item_detail_view.dart`)
- Detailed view of a single grocery item
- Features:
  - Complete item information display
  - Formatted timestamps
  - Star/unstar toggle
  - Edit button
  - Delete with confirmation dialog
  - Automatic refresh on updates

**ItemEditView** (`item_edit_view.dart`)
- Form for creating and editing items
- Features:
  - Validated input fields
  - Dropdown for common units
  - Dropdown for common categories
  - Star toggle
  - Save/Update functionality
  - Auto-save on form submission

## Features

### 1. Offline-First Architecture
- All data stored locally in JSON format
- No internet connection required
- Instant load and save operations
- Data persists across app restarts

### 2. Search and Filter
- **Search**: Real-time search across name, category, and notes
- **Category Filter**: Filter by specific category
- **Starred Filter**: Show only favorite items
- **Combined Filters**: Filters work together

### 3. Data Management
- **Add**: Create new grocery items with validation
- **Edit**: Modify existing items
- **Delete**: Remove items with confirmation
- **Star**: Mark/unmark items as favorites

### 4. User Experience
- **Material Design 3**: Modern, clean UI
- **Dark Mode**: Automatic theme switching based on system preferences
- **Responsive**: Adapts to different screen sizes
- **Navigation**: Intuitive back navigation
- **Validation**: Form validation prevents invalid data

### 5. iOS-Ready
- Configured for iOS deployment
- TestFlight ready
- Proper bundle configuration
- iOS 12.0+ support

## Data Persistence

### Storage Format

Items are stored as a JSON array:

```json
[
  {
    "id": "1700000000000",
    "name": "Apples",
    "quantity": 5.0,
    "unit": "pcs",
    "category": "Produce",
    "notes": "Granny Smith",
    "starred": true,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
]
```

### File Location

- **iOS**: `~/Library/Application Support/<bundle_id>/grocery_items.json`
- File is created automatically on first write
- Loaded automatically on app start

## Common Units

Predefined units for easy selection:
- `pcs` (pieces)
- `kg` (kilograms)
- `g` (grams)
- `lb` (pounds)
- `oz` (ounces)
- `L` (liters)
- `mL` (milliliters)
- `cup`
- `tbsp` (tablespoon)
- `tsp` (teaspoon)

## Common Categories

Predefined categories:
- Produce
- Dairy
- Meat
- Bakery
- Beverages
- Snacks
- Pantry
- Frozen
- Other

## Development

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- iOS development tools (Xcode, CocoaPods)
- Dart SDK (included with Flutter)

### Setup

```bash
# Clone the repository
git clone <repository_url>

# Navigate to project directory
cd CG1ioa

# Install dependencies
flutter pub get

# For iOS
cd ios && pod install && cd ..
```

### Running

```bash
# Run on iOS simulator
flutter run

# Run on connected iOS device
flutter run -d <device_id>

# Run with specific flavor
flutter run --release
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/grocery_item_test.dart

# Run with coverage
flutter test --coverage
```

### Building for iOS

```bash
# Build for iOS
flutter build ios

# Build for release
flutter build ios --release

# Create IPA for TestFlight
flutter build ipa
```

## Deployment to TestFlight

1. Open Xcode project: `open ios/Runner.xcworkspace`
2. Configure signing:
   - Select Runner target
   - Go to Signing & Capabilities
   - Select your Team
   - Set Bundle Identifier (e.g., `com.yourcompany.chefgrocer`)
3. Archive the app:
   - Product > Archive
4. Upload to App Store Connect:
   - Window > Organizer
   - Select archive and click "Distribute App"
   - Choose App Store Connect
   - Follow the upload wizard
5. Submit for TestFlight:
   - Go to App Store Connect
   - Select your app
   - Go to TestFlight tab
   - Add testers and submit

## Future Enhancements

Potential features for future versions:
- Export/Import functionality
- Shopping list mode with checkboxes
- Recipe integration
- Barcode scanning
- Multi-list support
- Cloud sync (optional)
- Sharing lists with family
- Price tracking
- Store location mapping

## Troubleshooting

### Common Issues

**Issue**: Items not persisting
- **Solution**: Check app permissions for file access
- **Solution**: Verify Documents directory is writable

**Issue**: Build fails on iOS
- **Solution**: Run `pod install` in ios directory
- **Solution**: Clean build folder in Xcode
- **Solution**: Update Flutter: `flutter upgrade`

**Issue**: Dark mode not working
- **Solution**: Check system dark mode settings
- **Solution**: Verify ThemeMode.system is set in main.dart

## License

This project is for demonstration purposes.

## Support

For issues, questions, or contributions, please refer to the repository's issue tracker.
