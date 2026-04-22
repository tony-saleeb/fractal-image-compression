# DeepFract - Quick Start Guide

## Prerequisites

Before running the app, ensure you have:

1. **Flutter SDK** (3.7.0 or later)
   ```bash
   flutter --version
   ```

2. **Android Studio** (for Android) or **Xcode** (for iOS)

3. **Connected Device** or **Emulator/Simulator**

## Installation Steps

### 1. Install Dependencies

```bash
cd deepfract
flutter pub get
```

Expected output:
```
Resolving dependencies...
Got dependencies!
```

### 2. Verify Installation

```bash
flutter doctor
```

This will check your Flutter setup. Ensure at least one platform is properly configured.

### 3. Check for Code Issues (Optional)

```bash
flutter analyze
```

Expected output:
```
Analyzing deepfract...
No issues found!
```

## Running the App

### Option 1: Run on Connected Device

1. **Connect your device** via USB
2. **Enable USB debugging** (Android) or **Trust computer** (iOS)
3. **Run the app:**

```bash
flutter run
```

### Option 2: Run on Emulator/Simulator

**Android Emulator:**
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

**iOS Simulator (macOS only):**
```bash
# Open simulator
open -a Simulator

# Run app
flutter run
```

### Option 3: Run in Chrome (Web - Limited functionality)

```bash
flutter run -d chrome
```

Note: Camera/gallery functionality will be limited in web browser.

## Testing the App Flow

### First Launch (Onboarding)

1. **Splash Screen** appears for 2.5 seconds
2. **Onboarding Page 1** - View fractal compression intro
   - Click "Next" arrow to proceed
   - OR click "Skip" to go directly to home
3. **Onboarding Page 2** - View AI-powered features
   - Click "Next" arrow to proceed
   - OR click "Skip" to go directly to home
4. **Onboarding Page 3** - Upload functionality
   - Click "Upload from Gallery" to select existing image
   - OR click "Take Photo" to capture new image
5. Select an image from gallery or take a photo
6. **Home Screen** appears

### Subsequent Launches

1. **Splash Screen** appears for 2.5 seconds
2. **Home Screen** appears directly (onboarding skipped)

### Home Screen Features

1. **Select Image**
   - Click "Select Image" button
   - Choose "Gallery" or "Camera" from bottom sheet
   - Select/Capture an image
   - Image appears in preview area

2. **Compress Image (Placeholder)**
   - With an image selected, click "Compress Image"
   - 2-second simulation runs
   - Message appears: "Backend compression will be implemented next"

## Resetting Onboarding

To test the onboarding flow again:

### Method 1: Uninstall and Reinstall
```bash
# Uninstall
flutter run --uninstall-only

# Reinstall and run
flutter run
```

### Method 2: Clear App Data

**Android:**
- Settings → Apps → DeepFract → Storage → Clear Data

**iOS:**
- Uninstall and reinstall the app

## Build for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open Xcode to archive and upload to App Store.

## Common Issues & Solutions

### Issue 1: "No connected devices"

**Solution:**
```bash
# Check devices
flutter devices

# If no devices, start an emulator
flutter emulators
flutter emulators --launch <emulator_id>
```

### Issue 2: "Gradle build failed" (Android)

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 3: "CocoaPods not installed" (iOS)

**Solution:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### Issue 4: Camera/Gallery permission denied

**Solution:**
- Android: Check Settings → Apps → DeepFract → Permissions
- iOS: Check Settings → DeepFract → Permissions
- Uninstall and reinstall the app

### Issue 5: "MissingPluginException"

**Solution:**
```bash
flutter clean
flutter pub get
# Restart your IDE
flutter run
```

## Development Tips

### Hot Reload

While the app is running, make code changes and press:
- **`r`** in terminal for hot reload (preserves state)
- **`R`** in terminal for hot restart (resets state)

### Debugging

**Enable debug mode:**
```bash
flutter run --debug
```

**View logs:**
```bash
flutter logs
```

**Debug in VS Code:**
1. Open project in VS Code
2. Press F5
3. Set breakpoints by clicking left of line numbers

**Debug in Android Studio:**
1. Open project
2. Click Debug button (bug icon)
3. Set breakpoints by clicking left of line numbers

## Project Structure Quick Reference

```
deepfract/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/                     # All screens
│   │   ├── splash_screen.dart       # Launch screen
│   │   ├── onboarding_screen.dart   # 3-page onboarding
│   │   └── home_screen.dart         # Main screen
│   ├── widgets/                     # Reusable components
│   │   ├── custom_button.dart
│   │   └── onboarding_page.dart
│   ├── services/                    # Business logic
│   │   └── image_picker_service.dart
│   └── utils/                       # Configuration
│       ├── constants.dart           # App constants
│       ├── theme.dart              # Theme config
│       └── routes.dart             # Navigation
├── android/                         # Android config
├── ios/                            # iOS config
├── assets/images/                  # Image assets
└── pubspec.yaml                    # Dependencies

```

## Next Steps

After verifying the frontend works:

1. **Backend Integration**
   - Implement fractal compression algorithm
   - Integrate AI model
   - Connect to home screen

2. **Additional Features**
   - Save compressed images
   - Share functionality
   - Compression history
   - Settings page

3. **Testing**
   - Write unit tests
   - Write widget tests
   - Write integration tests

4. **Polish**
   - Add actual image assets
   - Refine animations
   - Optimize performance
   - Add error messages

## Support

For issues or questions:
1. Check `IMPLEMENTATION_SUMMARY.md` for detailed documentation
2. Check `SCREENS_OVERVIEW.md` for UI/UX details
3. Review Flutter documentation: https://flutter.dev/docs

## Version Info

- Flutter SDK: 3.7.0+
- Dart SDK: 3.7.0+
- Material Design: 3
- Target Platforms: Android, iOS

---

**Status:** ✅ Frontend Complete - Ready for Backend Integration

