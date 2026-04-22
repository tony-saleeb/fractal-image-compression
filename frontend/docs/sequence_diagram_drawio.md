# DeepFract Sequence Diagrams for Draw.io

## How to Use in Draw.io

1. Go to [draw.io](https://app.diagrams.net/)
2. Click **Arrange → Insert → Advanced → Mermaid**
3. Paste the diagram code below
4. Click **Insert**

---

## 1. Complete Application Flow Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    participant U as User
    participant App as DeepFractApp
    participant TP as ThemeProvider
    participant TS as ThemeSwitcher
    participant SS as SplashScreen
    participant OS as OnboardingScreen
    participant HS as HomeScreen
    participant WHS as WebHomeScreen
    participant IPS as ImagePickerService
    participant UM as UploadModal
    participant CLO as CompressionLoadingOverlay
    participant CS as CompressionService
    participant CRS as CompressionResultScreen
    participant SP as SharedPreferences
    participant Backend as Backend API

    %% App Initialization
    rect rgb(240, 248, 255)
        Note over U,Backend: App Initialization Phase
        U->>App: Launch App
        App->>TP: Create ThemeProvider()
        TP->>SP: loadThemeMode()
        SP-->>TP: isDark (bool)
        TP-->>App: ThemeMode (light/dark)
        App->>TS: Wrap with ThemeSwitcher
        App->>SS: Navigate to SplashScreen
    end

    %% Splash Screen
    rect rgb(255, 250, 240)
        Note over U,Backend: Splash Screen Phase
        SS->>SS: Start animations (1.8s)
        SS->>SS: Wait 2.5 seconds

        alt Web Platform
            SS->>WHS: Navigate directly to WebHomeScreen
        else Mobile Platform
            SS->>OS: Navigate to OnboardingScreen
        end
    end

    %% Onboarding Flow (Mobile Only)
    rect rgb(240, 255, 240)
        Note over U,Backend: Onboarding Phase (Mobile)
        OS->>OS: Show Page 1 (Compression Power)
        U->>OS: Swipe / Next
        OS->>OS: Show Page 2 (Lightning Fast AI)
        U->>OS: Swipe / Next
        OS->>OS: Show Page 3 (Simple & Powerful)
        U->>OS: Click "Get Started"
        OS->>SP: setBool(onboarding_complete, true)
        OS->>HS: Navigate to HomeScreen
    end

    %% Theme Toggle Flow
    rect rgb(255, 245, 238)
        Note over U,Backend: Theme Toggle Flow
        U->>TS: Toggle Theme Button
        TS->>TS: Capture current screen
        TS->>TP: toggleTheme()
        TP->>SP: Save theme preference
        TP-->>App: Notify listeners
        TS->>TS: Fade out old theme (600ms)
    end
```

---

## 2. Image Compression Flow Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    participant U as User
    participant HS as HomeScreen
    participant WHS as WebHomeScreen
    participant IPS as ImagePickerService
    participant UM as UploadModal
    participant CLO as CompressionLoadingOverlay
    participant CS as CompressionService
    participant CRS as CompressionResultScreen
    participant Backend as Backend API

    %% Mobile Image Selection
    rect rgb(230, 230, 250)
        Note over U,Backend: Mobile Image Selection
        U->>HS: Click "Select Image"
        HS->>IPS: showImageSourceDialog()
        IPS->>U: Show Bottom Sheet (Gallery/Camera)

        alt Gallery Selected
            U->>IPS: Choose Gallery
            IPS->>IPS: pickFromGallery()
            IPS-->>HS: Return File
        else Camera Selected
            U->>IPS: Choose Camera
            IPS->>IPS: captureFromCamera()
            IPS-->>HS: Return File
        end

        HS->>HS: setState(selectedImage)
        HS->>HS: Display image preview
    end

    %% Web Image Selection
    rect rgb(255, 240, 245)
        Note over U,Backend: Web Image Selection
        U->>WHS: Click Upload Area
        WHS->>UM: showDialog(UploadModal)
        UM->>U: Show drag-drop zone

        alt Drag & Drop
            U->>UM: Drop image file
        else Click to Browse
            U->>UM: Click browse
            UM->>IPS: pickFromGalleryXFile()
            IPS-->>UM: Return XFile
        end

        UM->>UM: Read bytes from XFile
        UM-->>WHS: onImageSelected(file, bytes)
        WHS->>WHS: setState(selectedImage, imageBytes)
    end

    %% Compression Process
    rect rgb(255, 255, 224)
        Note over U,Backend: Compression Process
        U->>HS: Click "Compress Image"
        HS->>HS: setState(isProcessing: true)
        HS->>HS: Record startTime

        HS->>CLO: Push CompressionLoadingOverlay
        CLO->>CLO: Start entrance animation
        CLO->>CLO: Initialize progress (0%)

        loop Progress Animation (3 seconds)
            CLO->>CLO: Update progress 0% → 100%
            CLO->>CLO: Show compression messages
            CLO->>CLO: Animate image transformation
        end

        Note over CLO,Backend: TODO: Backend Integration
        CLO->>CS: compressImage(imageFile)

        alt Backend Available (Future)
            CS->>Backend: POST /api/compress (multipart)
            Backend->>Backend: Convert to grayscale
            Backend->>Backend: Apply fractal compression
            Backend-->>CS: Return compressed image + metadata
        else Mock Mode (Current)
            CS->>CS: Simulate 3s delay
            CS->>CS: Generate mock result (90% ratio)
        end

        CS-->>CLO: CompressionResult
        CLO->>CLO: onComplete callback
        CLO-->>HS: Pop overlay
    end

    %% Result Screen
    rect rgb(240, 255, 255)
        Note over U,Backend: Result Screen
        HS->>HS: Calculate compressionTime
        HS->>CRS: Navigate to CompressionResultScreen
        CRS->>CRS: Start entrance animation
        CRS->>CRS: Start particle animation
        CRS->>CRS: Display compressed image
        CRS->>CRS: Show stats (original/compressed/time)

        U->>CRS: Toggle Original/Compressed
        CRS->>CRS: AnimatedSwitcher swap image

        alt Download
            U->>CRS: Click Download
            CRS->>CRS: Show "Backend required" message
        else Share
            U->>CRS: Click Share
            CRS->>CRS: Share.shareXFiles()
        else New Image
            U->>CRS: Click New
            CRS->>CRS: Show confirmation dialog
            U->>CRS: Confirm
            CRS->>UM: Show UploadModal
        end
    end
```

---

## 3. Web Tutorial Flow Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    participant U as User
    participant WHS as WebHomeScreen
    participant WTO as WebTutorialOverlay
    participant WN as WebNavbar
    participant Hero as HeroSection

    rect rgb(245, 245, 220)
        Note over U,Hero: Web Tutorial Flow
        WHS->>WHS: initState()
        WHS->>WHS: addPostFrameCallback
        WHS->>WHS: Wait 500ms
        WHS->>WTO: WebTutorialOverlay.show()

        WTO->>WTO: Create overlay entry
        WTO->>WTO: Get position of logoKey
        WTO->>U: Highlight Logo
        WTO->>U: Show "Welcome to DeepFract"

        U->>WTO: Click Next
        WTO->>WTO: Get position of uploadKey
        WTO->>U: Highlight Upload Area
        WTO->>U: Show "Upload Your Image"

        U->>WTO: Click Next
        WTO->>WTO: Get position of themeKey
        WTO->>U: Highlight Theme Toggle
        WTO->>U: Show "Customize Your View"

        U->>WTO: Click Finish
        WTO->>WTO: Remove overlay
        WTO-->>WHS: Tutorial complete
    end
```

---

## 4. Simplified Overview Diagram

```mermaid
sequenceDiagram
    participant User
    participant App
    participant Screens
    participant Services
    participant Backend

    User->>App: Launch
    App->>Screens: SplashScreen (2.5s)

    alt Mobile
        Screens->>Screens: Onboarding (3 pages)
    end

    Screens->>Screens: HomeScreen
    User->>Screens: Select Image
    Screens->>Services: ImagePickerService
    Services-->>Screens: Image File

    User->>Screens: Compress
    Screens->>Screens: Loading Overlay
    Screens->>Services: CompressionService
    Services->>Backend: POST /api/compress
    Backend-->>Services: Compressed Image
    Services-->>Screens: CompressionResult

    Screens->>Screens: ResultScreen
    User->>Screens: Download/Share/New
```

---

## Notes for Draw.io

### Color Codes Used:

- **Light Blue** `rgb(240, 248, 255)` - App Initialization
- **Light Orange** `rgb(255, 250, 240)` - Splash Screen
- **Light Green** `rgb(240, 255, 240)` - Onboarding
- **Peach** `rgb(255, 245, 238)` - Theme Toggle
- **Lavender** `rgb(230, 230, 250)` - Mobile Image Selection
- **Pink** `rgb(255, 240, 245)` - Web Image Selection
- **Light Yellow** `rgb(255, 255, 224)` - Compression Process
- **Cyan** `rgb(240, 255, 255)` - Result Screen
- **Beige** `rgb(245, 245, 220)` - Tutorial Flow

### Participants (Actors):

| Abbreviation | Full Name                 | Role                      |
| ------------ | ------------------------- | ------------------------- |
| U            | User                      | End user of the app       |
| App          | DeepFractApp              | Main application widget   |
| TP           | ThemeProvider             | State manager for theme   |
| TS           | ThemeSwitcher             | Smooth theme transition   |
| SS           | SplashScreen              | Initial loading screen    |
| OS           | OnboardingScreen          | 3-page intro (mobile)     |
| HS           | HomeScreen                | Mobile home screen        |
| WHS          | WebHomeScreen             | Web home screen           |
| IPS          | ImagePickerService        | Image selection service   |
| UM           | UploadModal               | Web upload dialog         |
| CLO          | CompressionLoadingOverlay | Loading animation         |
| CS           | CompressionService        | Compression logic         |
| CRS          | CompressionResultScreen   | Results display           |
| SP           | SharedPreferences         | Local storage             |
| Backend      | Backend API               | Future server integration |
