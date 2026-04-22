# DeepFract - Complete System Sequence Diagram

## Fractal Image Compression Using AI Techniques

### Graduation Project - UML Documentation

---

```mermaid
sequenceDiagram
    autonumber

    actor User
    participant App as Application
    participant Splash as Splash Screen
    participant Onboarding as Onboarding Module
    participant Home as Home Screen
    participant ImagePicker as Image Picker Service
    participant Loading as Loading Overlay
    participant Compression as Compression Service
    participant Backend as Backend Server
    participant Result as Result Screen
    participant Storage as Local Storage

    %% ========== PHASE 1: APPLICATION INITIALIZATION ==========
    rect rgb(240, 248, 255)
        Note over User, Storage: Phase 1: Application Initialization

        User->>App: Launch Application
        activate App
        App->>Storage: Load Theme Preference
        Storage-->>App: Return Theme Mode
        App->>Splash: Display Splash Screen
        activate Splash
        Splash->>Splash: Play Animation (2.5 seconds)
    end

    %% ========== PHASE 2: ONBOARDING ==========
    rect rgb(255, 248, 240)
        Note over User, Storage: Phase 2: User Onboarding (Mobile Only)

        alt Web Platform
            Splash->>Home: Direct Navigation
        else Mobile Platform
            Splash->>Onboarding: Navigate to Onboarding
            deactivate Splash
            activate Onboarding
            Onboarding->>User: Screen 1 - Compression Power
            User->>Onboarding: Next
            Onboarding->>User: Screen 2 - AI Technology
            User->>Onboarding: Next
            Onboarding->>User: Screen 3 - Upload Guide
            User->>Onboarding: Get Started
            Onboarding->>Storage: Save Completion Status
            Onboarding->>Home: Navigate to Home
            deactivate Onboarding
        end
    end

    %% ========== PHASE 3: IMAGE SELECTION ==========
    rect rgb(240, 255, 240)
        Note over User, Storage: Phase 3: Image Selection

        activate Home
        Home->>User: Display Main Interface
        User->>Home: Select Image
        Home->>ImagePicker: Open Image Source Dialog
        activate ImagePicker
        ImagePicker->>User: Show Options (Gallery/Camera)

        alt Gallery
            User->>ImagePicker: Choose Gallery
            ImagePicker->>ImagePicker: Access Device Storage
        else Camera
            User->>ImagePicker: Choose Camera
            ImagePicker->>ImagePicker: Capture Photo
        end

        ImagePicker-->>Home: Return Image File
        deactivate ImagePicker
        Home->>User: Display Image Preview
    end

    %% ========== PHASE 4: COMPRESSION PROCESS ==========
    rect rgb(255, 255, 224)
        Note over User, Storage: Phase 4: AI Compression Process

        User->>Home: Compress Image
        Home->>Loading: Show Loading Overlay
        activate Loading
        Loading->>User: Display Progress Animation
        Loading->>Compression: Submit Image
        activate Compression

        Compression->>Backend: POST /api/compress (Image Data)
        activate Backend
        Backend->>Backend: Convert to Grayscale
        Backend->>Backend: Apply Fractal Decomposition
        Backend->>Backend: Execute AI Optimization
        Backend-->>Compression: Return Compressed Image + Metadata
        deactivate Backend

        Compression-->>Loading: Return Result
        deactivate Compression
        Loading->>Loading: Complete Animation
        Loading-->>Home: Close Overlay
        deactivate Loading
    end

    %% ========== PHASE 5: RESULT DISPLAY ==========
    rect rgb(240, 255, 255)
        Note over User, Storage: Phase 5: Result Presentation

        Home->>Result: Navigate with Results
        deactivate Home
        activate Result
        Result->>User: Display Compressed Image
        Result->>User: Show Statistics (Size, Ratio, Time)

        alt Download
            User->>Result: Download Image
            Result->>Storage: Save to Device
            Result->>User: Confirm Download
        else Share
            User->>Result: Share Image
            Result->>User: Open Share Dialog
        else New Image
            User->>Result: Compress Another
            Result->>Home: Return to Home
            deactivate Result
        end
    end

    deactivate App
```

---

## Diagram Description

This sequence diagram illustrates the complete user journey through the **DeepFract** application, an AI-powered fractal image compression system. The diagram is divided into five distinct phases:

### Phase 1: Application Initialization

The system initializes by loading user preferences from local storage and displaying an animated splash screen for brand introduction.

### Phase 2: User Onboarding

Platform-specific routing directs mobile users through a three-screen onboarding tutorial explaining the application's capabilities, while web users proceed directly to the main interface.

### Phase 3: Image Selection

Users select images through a service that provides access to both the device gallery and camera, with the selected image displayed as a preview.

### Phase 4: AI Compression Process

The core functionality where the selected image is transmitted to the backend server for processing through the fractal compression algorithm enhanced with AI optimization techniques.

### Phase 5: Result Presentation

The compressed image is displayed alongside compression statistics, with options to download, share, or process additional images.

---

## Actors and Components

| Component                | Description                               |
| ------------------------ | ----------------------------------------- |
| **User**                 | End user interacting with the application |
| **Application**          | Main application controller               |
| **Splash Screen**        | Initial loading and branding display      |
| **Onboarding Module**    | User introduction tutorial                |
| **Home Screen**          | Primary user interface                    |
| **Image Picker Service** | Device image access service               |
| **Loading Overlay**      | Visual feedback during processing         |
| **Compression Service**  | Image compression handler                 |
| **Backend Server**       | AI-powered compression API                |
| **Result Screen**        | Compression results display               |
| **Local Storage**        | User preference persistence               |

---

## Key Interactions

1. **Steps 1-4**: System initialization and theme loading
2. **Steps 5-13**: Platform-aware onboarding flow
3. **Steps 14-20**: Image selection from device
4. **Steps 21-29**: Backend compression processing
5. **Steps 30-37**: Result display and user actions
