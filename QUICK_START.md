# ChefGrocer - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Xcode (for iOS development)
- CocoaPods

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CG1ioa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Features

### Main Screen (ItemListView)
- **Search**: Type in the search bar to find items by name, category, or notes
- **Filter by Category**: Tap filter icon → select category
- **Show Starred Only**: Tap star icon in top right
- **Add New Item**: Tap the + button
- **Quick Actions**: Tap star on any card to favorite, use three-dot menu for edit/delete

### Detail Screen (ItemDetailView)
- **View Details**: Tap any item card to see complete information
- **Star/Unstar**: Tap star icon
- **Edit**: Tap edit icon
- **Delete**: Tap delete icon → confirm

### Add/Edit Screen (ItemEditView)
- **Name**: Required, text input
- **Quantity**: Required, number input
- **Unit**: Select from dropdown (pcs, kg, L, etc.)
- **Category**: Select from dropdown (Produce, Dairy, etc.)
- **Notes**: Optional, multiline text
- **Starred**: Toggle switch

## 💾 Data Storage

All data is stored locally in JSON format at:
```
<app_documents>/grocery_items.json
```

No internet connection required!

## 🎨 Customization

### Theme
The app automatically adapts to your device's dark/light mode settings.

### Categories & Units
Edit `lib/views/item_edit_view.dart` to customize:
- `_commonUnits` list (lines ~25-37)
- `_commonCategories` list (lines ~39-49)

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point & theme
├── models/
│   └── grocery_item.dart        # Data model
├── services/
│   └── item_store.dart          # Data persistence
└── views/
    ├── item_list_view.dart      # Main list screen
    ├── item_detail_view.dart    # Detail screen
    └── item_edit_view.dart      # Add/Edit screen
```

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/grocery_item_test.dart
```

## 📦 Building for iOS

### Development Build
```bash
flutter build ios --debug
```

### Release Build
```bash
flutter build ios --release
```

### Create IPA for TestFlight
```bash
flutter build ipa
```

## 🔧 Common Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter test` | Run tests |
| `flutter clean` | Clean build artifacts |
| `flutter doctor` | Check Flutter setup |
| `flutter build ios` | Build iOS app |

## 📖 Documentation

- **README.md** - Project overview
- **TECHNICAL_DOCS.md** - Technical details
- **USER_GUIDE.md** - User instructions
- **IMPLEMENTATION_SUMMARY.md** - Feature list
- **PROJECT_OVERVIEW.md** - Complete overview

## 🐛 Troubleshooting

### Build fails
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Tests fail
```bash
flutter clean
flutter pub get
flutter test
```

### CocoaPods issues
```bash
cd ios
pod deintegrate
pod install
cd ..
```

## 📞 Need Help?

1. Check the documentation files
2. Review the code comments
3. Run `flutter doctor` to check setup
4. Open an issue on GitHub

## ⚡ Quick Tips

- Use **Cmd+Shift+P** in VS Code to access Flutter commands
- Use **Hot Reload** (r in terminal) for quick UI changes
- Use **Hot Restart** (R in terminal) for full restart
- Check `analysis_options.yaml` for linting rules

## 🎯 Next Steps

1. Explore the code in `lib/` directory
2. Run the app and add some items
3. Read the technical documentation
4. Customize categories and units
5. Build for your device/simulator

---

Ready to start? Run `flutter run` and enjoy ChefGrocer! 🛒
