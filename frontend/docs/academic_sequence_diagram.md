# DeepFract - UML Sequence Diagrams

## Fractal Image Compression Using AI Techniques

### Academic Documentation for Graduation Project

---

## 1. Main Application Flow Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    actor User
    participant Application as Application Layer
    participant ThemeManager as Theme Manager
    participant SplashScreen as Splash Screen
    participant OnboardingModule as Onboarding Module
    participant HomeScreen as Home Screen
    participant LocalStorage as Local Storage

    Note over User, LocalStorage: System Initialization Phase

    User->>Application: Launch Application
    activate Application

    Application->>ThemeManager: Initialize Theme Manager
    activate ThemeManager
    ThemeManager->>LocalStorage: Retrieve Theme Preference
    LocalStorage-->>ThemeManager: Return Stored Theme Mode
    ThemeManager-->>Application: Apply Theme Configuration
    deactivate ThemeManager

    Application->>SplashScreen: Display Splash Screen
    activate SplashScreen
    SplashScreen->>SplashScreen: Execute Entry Animation (1800ms)
    SplashScreen->>SplashScreen: Display Application Branding
    SplashScreen->>SplashScreen: Wait for Initialization (2500ms)

    alt Platform Detection: Web Browser
        SplashScreen->>HomeScreen: Navigate to Home Screen
    else Platform Detection: Mobile Device
        SplashScreen->>OnboardingModule: Navigate to Onboarding
        deactivate SplashScreen
        activate OnboardingModule

        OnboardingModule->>User: Display Introduction Screen 1
        User->>OnboardingModule: Proceed to Next
        OnboardingModule->>User: Display Introduction Screen 2
        User->>OnboardingModule: Proceed to Next
        OnboardingModule->>User: Display Introduction Screen 3
        User->>OnboardingModule: Complete Onboarding

        OnboardingModule->>LocalStorage: Store Onboarding Completion Status
        OnboardingModule->>HomeScreen: Navigate to Home Screen
        deactivate OnboardingModule
    end

    activate HomeScreen
    HomeScreen->>User: Display Main Interface
    deactivate HomeScreen
    deactivate Application
```

---

## 2. Image Compression Process Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    actor User
    participant HomeScreen as Home Screen
    participant ImageService as Image Picker Service
    participant DeviceStorage as Device Storage
    participant LoadingOverlay as Loading Overlay
    participant CompressionService as Compression Service
    participant BackendAPI as Backend API Server
    participant ResultScreen as Result Screen

    Note over User, ResultScreen: Image Selection Phase

    User->>HomeScreen: Request Image Selection
    activate HomeScreen
    HomeScreen->>ImageService: Invoke Image Source Dialog
    activate ImageService
    ImageService->>User: Present Selection Options

    alt Option: Device Gallery
        User->>ImageService: Select Gallery Option
        ImageService->>DeviceStorage: Access Photo Library
        DeviceStorage-->>ImageService: Return Selected Image File
    else Option: Device Camera
        User->>ImageService: Select Camera Option
        ImageService->>DeviceStorage: Access Camera Hardware
        DeviceStorage-->>ImageService: Return Captured Image File
    end

    ImageService-->>HomeScreen: Return Image File Reference
    deactivate ImageService
    HomeScreen->>HomeScreen: Update UI State with Image Preview
    HomeScreen->>User: Display Selected Image

    Note over User, ResultScreen: Compression Execution Phase

    User->>HomeScreen: Initiate Compression Request
    HomeScreen->>HomeScreen: Record Process Start Time
    HomeScreen->>LoadingOverlay: Display Loading Interface
    activate LoadingOverlay

    LoadingOverlay->>LoadingOverlay: Initialize Progress Indicator (0%)
    LoadingOverlay->>User: Display Processing Animation

    LoadingOverlay->>CompressionService: Submit Image for Compression
    activate CompressionService

    alt Backend Server Available
        CompressionService->>BackendAPI: POST /api/compress
        activate BackendAPI
        Note right of BackendAPI: Image Processing Pipeline
        BackendAPI->>BackendAPI: 1. Convert to Grayscale
        BackendAPI->>BackendAPI: 2. Apply Fractal Decomposition
        BackendAPI->>BackendAPI: 3. Execute AI Optimization
        BackendAPI->>BackendAPI: 4. Generate Compressed Output
        BackendAPI-->>CompressionService: Return Compression Result
        deactivate BackendAPI
    else Offline Mode / Demo Mode
        CompressionService->>CompressionService: Execute Local Simulation
        CompressionService->>CompressionService: Generate Mock Result Data
    end

    CompressionService-->>LoadingOverlay: Return Compression Result Object
    deactivate CompressionService

    LoadingOverlay->>LoadingOverlay: Update Progress Indicator (100%)
    LoadingOverlay->>LoadingOverlay: Execute Completion Animation
    LoadingOverlay-->>HomeScreen: Signal Process Completion
    deactivate LoadingOverlay

    HomeScreen->>HomeScreen: Calculate Total Processing Duration

    Note over User, ResultScreen: Result Presentation Phase

    HomeScreen->>ResultScreen: Navigate with Compression Data
    deactivate HomeScreen
    activate ResultScreen

    ResultScreen->>ResultScreen: Execute Entry Animation
    ResultScreen->>User: Display Compressed Image
    ResultScreen->>User: Present Compression Statistics
    Note right of ResultScreen: Statistics Display:<br/>- Original File Size<br/>- Compressed File Size<br/>- Compression Ratio<br/>- Processing Duration

    deactivate ResultScreen
```

---

## 3. Result Screen Interaction Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    actor User
    participant ResultScreen as Result Screen
    participant FileSystem as File System
    participant ShareService as Share Service
    participant AlertDialog as Alert Dialog
    participant UploadModal as Upload Modal
    participant CompressionService as Compression Service

    Note over User, CompressionService: User Interaction with Results

    activate ResultScreen
    ResultScreen->>User: Display Compression Results

    alt Action: View Toggle
        User->>ResultScreen: Toggle Image View Mode
        ResultScreen->>ResultScreen: Switch Between Original/Compressed
        ResultScreen->>User: Update Image Display
    end

    alt Action: Download Image
        User->>ResultScreen: Request Download
        ResultScreen->>FileSystem: Save Compressed Image
        FileSystem-->>ResultScreen: Confirm Save Location
        ResultScreen->>User: Display Success Notification
    end

    alt Action: Share Image
        User->>ResultScreen: Request Share
        ResultScreen->>ShareService: Invoke System Share Dialog
        activate ShareService
        ShareService->>ShareService: Prepare Share Intent
        ShareService->>User: Display Share Options
        User->>ShareService: Select Share Target
        ShareService-->>ResultScreen: Confirm Share Completion
        deactivate ShareService
    end

    alt Action: Process New Image
        User->>ResultScreen: Request New Compression
        ResultScreen->>AlertDialog: Display Confirmation Dialog
        activate AlertDialog
        AlertDialog->>User: Warn About Unsaved Changes

        alt User Response: Confirm
            User->>AlertDialog: Confirm Action
            AlertDialog-->>ResultScreen: Return Confirmation
            deactivate AlertDialog

            ResultScreen->>UploadModal: Display Image Selection
            activate UploadModal
            UploadModal->>User: Present Upload Interface
            User->>UploadModal: Select New Image
            UploadModal-->>ResultScreen: Return New Image Data
            deactivate UploadModal

            ResultScreen->>CompressionService: Process New Image
            CompressionService-->>ResultScreen: Return New Results
            ResultScreen->>ResultScreen: Update Display State
            ResultScreen->>User: Display New Results

        else User Response: Cancel
            User->>AlertDialog: Cancel Action
            AlertDialog-->>ResultScreen: Return Cancellation
            deactivate AlertDialog
        end
    end

    deactivate ResultScreen
```

---

## 4. Theme Management Sequence Diagram

```mermaid
sequenceDiagram
    autonumber

    actor User
    participant UIComponent as UI Component
    participant ThemeSwitcher as Theme Switcher
    participant ThemeProvider as Theme Provider
    participant LocalStorage as Local Storage
    participant ApplicationRoot as Application Root

    Note over User, ApplicationRoot: Theme Transition Process

    User->>UIComponent: Activate Theme Toggle
    UIComponent->>ThemeSwitcher: Request Theme Change
    activate ThemeSwitcher

    ThemeSwitcher->>ThemeSwitcher: Capture Current Screen State
    ThemeSwitcher->>ThemeSwitcher: Store Screen as Image Buffer

    ThemeSwitcher->>ThemeProvider: Invoke Toggle Theme Method
    activate ThemeProvider

    ThemeProvider->>ThemeProvider: Switch Theme Mode (Light/Dark)
    ThemeProvider->>LocalStorage: Persist Theme Preference
    LocalStorage-->>ThemeProvider: Confirm Storage

    ThemeProvider->>ApplicationRoot: Notify State Change
    ApplicationRoot->>ApplicationRoot: Rebuild Widget Tree

    deactivate ThemeProvider

    ThemeSwitcher->>ThemeSwitcher: Execute Fade Transition (600ms)
    ThemeSwitcher->>ThemeSwitcher: Dispose Screen Buffer
    ThemeSwitcher-->>UIComponent: Theme Change Complete
    deactivate ThemeSwitcher

    UIComponent->>User: Display Updated Theme
```

---

## 5. System Overview Sequence Diagram (Simplified)

```mermaid
sequenceDiagram
    autonumber

    actor User
    box Application Layer
        participant Frontend as Flutter Frontend
    end
    box Service Layer
        participant Services as Application Services
    end
    box Data Layer
        participant Storage as Local Storage
        participant API as Backend API
    end

    Note over User, API: Complete System Flow Overview

    User->>Frontend: Launch Application
    Frontend->>Storage: Load User Preferences
    Storage-->>Frontend: Return Configuration

    Frontend->>User: Display Onboarding Flow
    User->>Frontend: Complete Onboarding
    Frontend->>Storage: Save Progress

    Frontend->>User: Display Home Screen
    User->>Frontend: Select Image
    Frontend->>Services: Process Image Selection
    Services-->>Frontend: Return Image Data

    User->>Frontend: Request Compression
    Frontend->>Services: Initialize Compression
    Services->>API: Submit Image Data

    Note right of API: AI-Powered Fractal<br/>Compression Algorithm

    API-->>Services: Return Compressed Data
    Services-->>Frontend: Return Results

    Frontend->>User: Display Results
    User->>Frontend: Download/Share
    Frontend->>Services: Execute Action
    Services-->>Frontend: Confirm Completion
    Frontend->>User: Display Confirmation
```

---

## Diagram Descriptions for Academic Discussion

### 1. Main Application Flow

This diagram illustrates the **initialization sequence** of the DeepFract application, demonstrating the interaction between the application layer, theme management system, and navigation flow. Key aspects include:

- Platform-specific routing (Web vs. Mobile)
- Persistent theme preference handling
- Progressive onboarding implementation

### 2. Image Compression Process

This diagram represents the **core functionality** of the system - the image compression workflow. It demonstrates:

- Service-oriented architecture for image handling
- Asynchronous processing with visual feedback
- Backend integration points for AI-powered compression
- Fallback mechanisms for offline operation

### 3. Result Screen Interaction

This diagram shows the **user interaction patterns** available after compression:

- View toggling between original and compressed states
- File system integration for downloads
- Platform-agnostic sharing capabilities
- Seamless workflow for processing multiple images

### 4. Theme Management

This diagram illustrates the **reactive state management** approach:

- Screen capture for smooth transitions
- Provider pattern for state propagation
- Persistent storage integration
- Widget tree reconstruction

### 5. System Overview

This diagram provides a **high-level architectural view** showing the three-tier architecture:

- Presentation Layer (Flutter Frontend)
- Business Logic Layer (Application Services)
- Data Access Layer (Local Storage + Backend API)

---

## Technical Notes

| Component             | Technology        | Purpose                     |
| --------------------- | ----------------- | --------------------------- |
| Frontend              | Flutter/Dart      | Cross-platform UI           |
| State Management      | Provider          | Reactive state handling     |
| Local Storage         | SharedPreferences | User preference persistence |
| Image Handling        | image_picker      | Platform image access       |
| Backend Communication | HTTP/REST         | API integration (planned)   |
| Compression Algorithm | Fractal + AI      | Core processing logic       |

---

## References

- UML 2.5 Specification (OMG)
- Flutter Documentation (flutter.dev)
- Clean Architecture Principles (Robert C. Martin)
