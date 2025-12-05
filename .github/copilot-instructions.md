# Miraç Prayer Assistant - Copilot Instructions

## Project Overview
Turkish Islamic mobile app (Flutter 3.6+) with prayer times, Qibla compass, Quran, digital tasbih, halal checker, and more. All UI text is in Turkish.

## Architecture

### Directory Structure
```
lib/
├── core/           # Exports (app_export.dart), ThemeManager singleton
├── data/           # Static data files (quran_data.dart, dua_data.dart, etc.)
├── presentation/   # Feature screens, each in own folder with widgets/ subfolder
├── routes/         # AppRoutes with named route constants
├── services/       # Singleton services (prayer times, notifications, ads, premium)
├── theme/          # AppTheme with light/dark themes (Contemporary Islamic Minimalism)
├── widgets/        # Reusable widgets (CustomAppBar, BannerAdWidget, etc.)
```

### Key Patterns
- **Singletons**: All services use singleton pattern via `factory` constructor
- **State persistence**: `SharedPreferences` for user settings (city, theme, notifications)
- **Responsive design**: Use `sizer` package (e.g., `16.sp`, `2.h`, `3.w`)
- **Icons**: Use `CustomIconWidget(iconName: 'icon_name')` - maps to Material Icons
- **Fonts**: Google Fonts only - DO NOT add local font files

## Critical Constraints (from pubspec.yaml)

```yaml
# DO NOT MODIFY these core dependencies
sizer: ^2.0.15              # Responsive design system
google_fonts: ^6.1.0        # Typography - NO local fonts
shared_preferences: ^2.2.2  # Local storage

# DO NOT add new asset directories - use only:
assets/, assets/images/, assets/data/
```

## Services Architecture

### PrayerTimesService
- Uses Aladhan API (`https://api.aladhan.com/v1`)
- Caches prayer times in SharedPreferences
- Method ID stored in `calculationMethodId` key (default: 13 = Diyanet)

### NotificationService  
- Schedules prayer notifications via `flutter_local_notifications`
- Uses timezone-aware scheduling with `tz.TZDateTime`
- Battery optimization handling for Android background reliability

### PremiumService / AdService
- Freemium model with Google AdMob
- Premium users skip ads via `PremiumService().isPremium()`
- Test ad IDs used in debug mode automatically

## Theme System

`AppTheme` class provides:
- `lightTheme` / `darkTheme` - Contemporary Islamic Minimalism palette
- Primary: Deep forest green (`#2D5A4A` light, `#8B9D83` dark)
- Accent: Warm gold (`#D4A574`) for prayer time highlights
- Access via `Theme.of(context).colorScheme`

`ThemeManager` singleton handles persistence and switching.

## Adding New Features

### New Screen Checklist
1. Create folder: `lib/presentation/feature_screen/`
2. Main screen file + `widgets/` subfolder for screen-specific widgets
3. Add route in `lib/routes/app_routes.dart`
4. Use `CustomAppBar` and `CustomBottomBar` for consistency
5. For premium features, check `PremiumService().canAccessFeature()`

### New Service Pattern
```dart
class MyService {
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
  // ... methods
}
```

## Build Commands

```bash
flutter pub get                              # Install dependencies
flutter run                                  # Run debug
flutter build apk --release                  # Android release
flutter pub run flutter_launcher_icons       # Regenerate app icons
flutter pub run flutter_native_splash:create # Regenerate splash
```

## SharedPreferences Keys Reference

| Key | Type | Purpose |
|-----|------|---------|
| `selectedCity`, `selected_district` | String | User location |
| `isDarkMode` | bool | Theme preference |
| `enable_prayer_notifications` | bool | Notification toggle |
| `calculationMethodId` | int | Prayer calculation method |
| `is_premium_user` | bool | Premium status |
| `notification_offset_minutes` | int | Pre-prayer warning time |

## External APIs

- **Prayer Times**: Aladhan API (no key required)
- **Halal Checker**: Open Food Facts API (barcode lookup)
- **Mosque Finder**: Overpass API (OpenStreetMap)
