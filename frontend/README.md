# DeepFract

Fractal Image Compression using AI Techniques - A college graduation project.

## Overview

DeepFract is a mobile application that implements fractal image compression using artificial intelligence techniques. This repository contains the frontend implementation built with Flutter.

## Features

- **Splash Screen**: Welcoming screen with app branding
- **Onboarding Flow**: 3-page interactive onboarding experience
  - Page 1: Introduction to Fractal Compression
  - Page 2: AI-Powered compression techniques
  - Page 3: Upload functionality with camera and gallery support
- **Image Upload**: Support for both camera capture and gallery selection
- **Modern UI**: Minimal flat design with clean user experience
- **Cross-Platform**: Works on Android and iOS

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # Screen widgets
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   └── home_screen.dart
├── widgets/                  # Reusable components
│   ├── custom_button.dart
│   └── onboarding_page.dart
├── services/                 # Business logic
│   └── image_picker_service.dart
└── utils/                    # Constants and configurations
    ├── constants.dart
    ├── theme.dart
    └── routes.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or later)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd deepfract
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- `image_picker`: ^1.0.7 - Image selection from camera/gallery
- `shared_preferences`: ^2.2.2 - Local storage for onboarding state
- `smooth_page_indicator`: ^1.1.0 - Page indicators for onboarding

## Permissions

### Android
The app requires the following permissions (already configured):
- Camera access
- Storage read/write access
- Media images access

### iOS
The app requires the following permissions (already configured):
- Camera usage
- Photo library access
- Photo library add usage

## Next Steps

The backend implementation for actual fractal image compression using AI techniques will be integrated in the next phase. This includes:
- Fractal compression algorithm implementation
- AI model integration for optimization
- Image processing pipeline
- Compression ratio display
- Before/after comparison

## Architecture

The frontend follows a clean architecture pattern with:
- **Screens**: UI layer for different app screens
- **Widgets**: Reusable UI components
- **Services**: Business logic and API interactions
- **Utils**: Constants, themes, and routing configuration

## Theme

The app uses a minimal flat design with:
- Primary color: Blue (#2196F3)
- Clean typography
- Modern rounded corners
- Consistent spacing and padding

## License

This project is part of a college graduation project.
