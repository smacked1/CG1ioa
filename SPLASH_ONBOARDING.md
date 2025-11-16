# Splash Screen Setup

## Overview
The ChefGrocer app now includes a splash screen and onboarding flow.

## Components

### 1. Splash Screen (SplashLoader)
- Displays ChefGrocer logo with app name and tagline
- Shows for 500ms while checking onboarding status
- Green gradient background with white circular logo container
- Automatically navigates to onboarding or main app

### 2. Onboarding Flow
Three slides introducing the app:

**Slide 1: Welcome to ChefGrocer**
- Icon: Shopping cart (green)
- Description: Your all-in-one solution for grocery shopping, meal planning, and budget tracking

**Slide 2: Plan & Shop**
- Icon: Calendar (orange)
- Description: Create weekly meal plans, manage your shopping list, and never forget an ingredient

**Slide 3: Budget & Calculate**
- Icon: Money (blue)
- Description: Track costs, compare prices, and scale recipes to save money and reduce waste

### 3. Navigation Flow
```
App Start
    ↓
SplashLoader (checks SharedPreferences)
    ↓
├─→ First Time User → OnboardingScreen → MainNavigation (after "Get Started")
└─→ Returning User → MainNavigation
```

## Implementation Details

### Dependencies Added
- `flutter_native_splash: ^2.3.5` - Native splash screen
- `shared_preferences: ^2.2.2` - Store onboarding completion status
- `smooth_page_indicator: ^1.1.0` - Page dots indicator

### Key Features
1. **Onboarding Skip**: Users can skip onboarding at any time
2. **Get Started Button**: On last slide, button text changes to "Get Started"
3. **Persistent State**: Onboarding shown only once using SharedPreferences
4. **Smooth Animations**: Page transitions with smooth indicator dots

### Files Modified/Created
- `lib/main.dart` - Added SplashLoader widget and onboarding check
- `lib/views/onboarding_screen.dart` - New onboarding implementation
- `pubspec.yaml` - Added dependencies and splash configuration
- `assets/` - Created for logo assets

## Native Splash Screen Setup

To generate the native iOS splash screen:

1. Add your logo image at `assets/logo.png` (recommended size: 1152x1152px)
2. Run the following command:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

This will automatically configure the iOS splash screen with:
- Background color: #4CAF50 (green)
- Logo centered on screen
- iOS-only (Android disabled in config)

## Testing

The onboarding can be reset for testing by:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('onboarding_complete');
```

Or by reinstalling the app.

## UI/UX Details

### Splash Screen
- Full-screen green background
- White circular container with shopping cart icon
- App name in bold white text (32px)
- Tagline "Plan. Shop. Save." in lighter white (16px)

### Onboarding
- Full-screen pages with centered content
- Large circular colored backgrounds for icons (200x200)
- Icon size: 100px
- Title: HeadlineMedium (bold)
- Description: BodyLarge (gray)
- Smooth page indicator with worm effect
- Primary colored dots for active page
- Full-width action button (56px height)
- Skip button below main button (except on last page)

## Color Scheme
- Primary: Green (#4CAF50)
- Slide 1: Green
- Slide 2: Orange
- Slide 3: Blue
- Text: Dark (titles) / Gray (descriptions)
