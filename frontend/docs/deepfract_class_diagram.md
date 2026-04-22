# DeepFract - Class Diagram

## Fractal Image Compression Application Using AI Techniques

### Graduation Project - UML Documentation

---

## Mermaid Class Diagram

```mermaid
classDiagram
    direction TB

    %% ==================== MAIN APP ====================
    class DeepFractApp {
        +ThemeMode themeMode
        +build() Widget
    }

    %% ==================== SCREENS ====================
    class SplashScreen {
        -AnimationController _controller
        -Animation~double~ _fadeAnimation
        -Animation~double~ _scaleAnimation
        +initState() void
        +dispose() void
        +build() Widget
        -_navigateToNext() void
    }

    class OnboardingScreen {
        -PageController _pageController
        -int _currentPage
        +initState() void
        +dispose() void
        +build() Widget
        -_onPageChanged() void
        -_goToNextPage() void
        -_completeOnboarding() void
    }

    class HomeScreen {
        -File? _selectedImage
        -Uint8List? _imageBytes
        -bool _isCompressing
        +build() Widget
        -_onImageSelected() void
        -_compressImage() void
        -_showUploadModal() void
    }

    class WebHomeScreen {
        -File? _selectedImage
        -Uint8List? _imageBytes
        +build() Widget
        -_onImageSelected() void
    }

    class CompressionResultScreen {
        +File originalImage
        +Uint8List imageBytes
        +CompressionResult result
        +build() Widget
        -_downloadImage() void
        -_shareImage() void
        -_compressAnother() void
    }

    %% ==================== SERVICES ====================
    class ImagePickerService {
        +pickFromGallery() Future~File?~
        +captureFromCamera() Future~File?~
        +pickFromGalleryXFile() Future~XFile?~
        +captureFromCameraXFile() Future~XFile?~
    }

    class CompressionService {
        +compressImage() Future~CompressionResult~
        -_processImage() Future~Uint8List~
        -_calculateStats() CompressionStats
    }

    %% ==================== MODELS ====================
    class CompressionResult {
        +Uint8List compressedImage
        +int originalSize
        +int compressedSize
        +double compressionRatio
        +Duration processingTime
    }

    %% ==================== PROVIDERS ====================
    class ThemeProvider {
        -ThemeMode _themeMode
        -SharedPreferences? _prefs
        +ThemeMode themeMode
        +isDarkMode bool
        +init() Future~void~
        +toggleTheme() void
        -_saveTheme() void
    }

    %% ==================== WIDGETS ====================
    class AnimatedBackground {
        +Widget child
        +build() Widget
    }

    class CompressionLoadingOverlay {
        +bool isVisible
        +String? message
        +build() Widget
    }

    class UploadModal {
        +Function onImageSelected
        +build() Widget
        -_handleImageSelection() void
    }

    class ThemeSwitcher {
        +build() Widget
        -_toggleTheme() void
    }

    class WebNavbar {
        +build() Widget
    }

    class WebTutorialOverlay {
        -int _currentStep
        -bool _isVisible
        +build() Widget
        -_nextStep() void
        -_previousStep() void
        -_close() void
    }

    class HeroSection {
        +Function onUploadPressed
        +build() Widget
    }

    class OnboardingPage {
        +int pageIndex
        +String title
        +String description
        +IconData icon
        +build() Widget
    }

    class PremiumButton {
        +String text
        +VoidCallback onPressed
        +bool isLoading
        +build() Widget
    }

    class CustomButton {
        +String text
        +VoidCallback onPressed
        +build() Widget
    }

    class PremiumAlertDialog {
        +String title
        +String message
        +show() void
    }

    %% ==================== UTILS ====================
    class AppTheme {
        +ThemeData lightTheme$
        +ThemeData darkTheme$
        +ColorScheme lightColorScheme$
        +ColorScheme darkColorScheme$
    }

    class AppConstants {
        +String appName$
        +String apiBaseUrl$
        +Duration splashDuration$
        +Duration animationDuration$
    }

    class AppRoutes {
        +String splash$
        +String onboarding$
        +String home$
        +String result$
    }

    %% ==================== RELATIONSHIPS ====================

    DeepFractApp --> ThemeProvider : uses
    DeepFractApp --> SplashScreen : navigates

    SplashScreen --> OnboardingScreen : navigates
    SplashScreen --> HomeScreen : navigates
    SplashScreen --> WebHomeScreen : navigates (web)

    OnboardingScreen --> HomeScreen : navigates
    OnboardingScreen *-- OnboardingPage : contains

    HomeScreen --> CompressionResultScreen : navigates
    HomeScreen --> ImagePickerService : uses
    HomeScreen --> CompressionService : uses
    HomeScreen *-- UploadModal : shows
    HomeScreen *-- CompressionLoadingOverlay : shows
    HomeScreen *-- AnimatedBackground : contains
    HomeScreen *-- ThemeSwitcher : contains

    WebHomeScreen --> CompressionResultScreen : navigates
    WebHomeScreen *-- WebNavbar : contains
    WebHomeScreen *-- HeroSection : contains
    WebHomeScreen *-- WebTutorialOverlay : shows

    CompressionResultScreen --> HomeScreen : navigates back
    CompressionResultScreen *-- PremiumButton : contains

    CompressionService --> CompressionResult : returns

    ThemeProvider --> AppTheme : uses

    UploadModal --> ImagePickerService : uses

    PremiumButton --|> CustomButton : extends
```

---

## Class Categories

| Category      | Classes                                                                                                                                                                                | Count |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **Screens**   | SplashScreen, OnboardingScreen, HomeScreen, WebHomeScreen, CompressionResultScreen                                                                                                     | 5     |
| **Services**  | ImagePickerService, CompressionService                                                                                                                                                 | 2     |
| **Providers** | ThemeProvider                                                                                                                                                                          | 1     |
| **Widgets**   | AnimatedBackground, CompressionLoadingOverlay, UploadModal, ThemeSwitcher, WebNavbar, WebTutorialOverlay, HeroSection, OnboardingPage, PremiumButton, CustomButton, PremiumAlertDialog | 11    |
| **Utils**     | AppTheme, AppConstants, AppRoutes                                                                                                                                                      | 3     |
| **Models**    | CompressionResult                                                                                                                                                                      | 1     |

---

## Relationship Types

| Symbol  | Meaning                |
| ------- | ---------------------- |
| `-->`   | Association (uses)     |
| `*--`   | Composition (contains) |
| `o--`   | Aggregation            |
| `--\|>` | Inheritance (extends)  |
| `..>`   | Dependency             |

---

## How to Use in Draw.io

1. **Arrange → Insert → Advanced → Mermaid**
2. Paste the code
3. Click **Insert**
