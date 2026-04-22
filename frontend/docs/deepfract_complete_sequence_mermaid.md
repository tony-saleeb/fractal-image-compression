# DeepFract - Complete System Sequence Diagram (Mermaid)

## Fractal Image Compression Using AI Techniques

### Graduation Project - UML Documentation

---

## Mermaid Code (Note: X markers not supported in Mermaid)

```mermaid
sequenceDiagram
    actor User
    participant Application
    participant SplashScreen as Splash Screen
    participant Onboarding as Onboarding Module
    participant HomeScreen as Home Screen
    participant ImagePicker as Image Picker Service
    participant LoadingOverlay as Loading Overlay
    participant Compression as Compression Service
    participant Backend as Backend Server
    participant ResultScreen as Result Screen
    participant LocalStorage as Local Storage

    Note over User,LocalStorage: Phase 1: Application Initialization
    User->>+Application: 1. Launch Application
    Application->>+LocalStorage: 2. Load Theme Preference
    LocalStorage-->>-Application: 3. Return Theme Mode
    Application->>+SplashScreen: 4. Display Splash Screen
    SplashScreen->>SplashScreen: 5. Play Animation (2.5 seconds)

    Note over User,LocalStorage: Phase 2: User Onboarding

    alt Web Platform
        SplashScreen->>HomeScreen: 6. Direct Navigation
    else Mobile Platform
        SplashScreen->>+Onboarding: 7. Navigate to Onboarding
        Onboarding-->>User: 8. Screen 1 - Compression Power
        User->>Onboarding: 9. Next
        Onboarding-->>User: 10. Screen 2 - AI Technology
        User->>Onboarding: 11. Next
        Onboarding-->>User: 12. Screen 3 - Upload Guide
        User->>Onboarding: 13. Get Started
        Onboarding->>+LocalStorage: 14. Save Completion Status
        deactivate LocalStorage
        Onboarding->>-HomeScreen: 15. Navigate to Home
    end
    deactivate SplashScreen

    Note over User,LocalStorage: Phase 3: Image Selection
    activate HomeScreen
    HomeScreen-->>User: 16. Display Main Interface
    User->>HomeScreen: 17. Select Image
    HomeScreen->>+ImagePicker: 18. Open Image Source Dialog
    ImagePicker-->>User: 19. Show Options (Gallery/Camera)

    alt Gallery
        User->>ImagePicker: 20. Choose Gallery
        ImagePicker->>ImagePicker: 21. Access Device Storage
    else Camera
        User->>ImagePicker: 22. Choose Camera
        ImagePicker->>ImagePicker: 23. Capture Photo
    end

    ImagePicker-->>-HomeScreen: 24. Return Image File
    HomeScreen-->>User: 25. Display Image Preview

    Note over User,LocalStorage: Phase 4: AI Compression Process
    User->>HomeScreen: 26. Compress Image
    HomeScreen->>+LoadingOverlay: 27. Show Loading Overlay
    LoadingOverlay-->>User: 28. Display Progress Animation
    LoadingOverlay->>+Compression: 29. Submit Image
    Compression->>+Backend: 30. POST /api/compress (Image Data)
    Backend->>Backend: 31. Convert to Grayscale
    Backend->>Backend: 32. Apply Fractal Decomposition
    Backend->>Backend: 33. Execute AI Optimization
    Backend-->>-Compression: 34. Return Compressed Image + Metadata
    Compression-->>-LoadingOverlay: 35. Return Result
    LoadingOverlay->>LoadingOverlay: 36. Complete Animation
    LoadingOverlay-->>-HomeScreen: 37. Close Overlay
    deactivate HomeScreen

    Note over User,LocalStorage: Phase 5: Result Presentation
    HomeScreen->>+ResultScreen: 38. Navigate with Results
    ResultScreen-->>User: 39. Display Compressed Image
    ResultScreen-->>User: 40. Show Statistics (Size, Ratio, Time)

    alt Download
        User->>ResultScreen: 41. Download Image
        ResultScreen->>+LocalStorage: 42. Save to Device
        deactivate LocalStorage
        ResultScreen-->>User: 43. Confirm Download
    else Share
        User->>ResultScreen: 44. Share Image
        ResultScreen-->>User: 45. Open Share Dialog
    else New Image
        User->>ResultScreen: 46. Compress Another
        ResultScreen-->>HomeScreen: 47. Return to Home
    end
    deactivate ResultScreen
    deactivate Application

    Note over User,LocalStorage: ✕ End of Sequence ✕
```

---

## ⚠️ Mermaid Limitation

**Mermaid does NOT support X destruction markers** like PlantUML does.

For X markers, use **PlantUML** instead:

---

## PlantUML Version (With X Destruction Markers)

```plantuml
@startuml DeepFract_Sequence

actor User
participant Application
participant "Splash Screen" as SplashScreen
participant "Onboarding Module" as Onboarding
participant "Home Screen" as HomeScreen
participant "Image Picker Service" as ImagePicker
participant "Loading Overlay" as LoadingOverlay
participant "Compression Service" as Compression
participant "Backend Server" as Backend
participant "Result Screen" as ResultScreen
participant "Local Storage" as LocalStorage

== Phase 1: Application Initialization ==
User -> Application: 1. Launch Application
activate Application
Application -> LocalStorage: 2. Load Theme Preference
activate LocalStorage
LocalStorage --> Application: 3. Return Theme Mode
deactivate LocalStorage
Application -> SplashScreen: 4. Display Splash Screen
activate SplashScreen
SplashScreen -> SplashScreen: 5. Play Animation (2.5 seconds)

== Phase 2: User Onboarding ==
alt Web Platform
    SplashScreen -> HomeScreen: 6. Direct Navigation
else Mobile Platform
    SplashScreen -> Onboarding: 7. Navigate to Onboarding
    activate Onboarding
    Onboarding --> User: 8. Screen 1 - Compression Power
    User -> Onboarding: 9. Next
    Onboarding --> User: 10. Screen 2 - AI Technology
    User -> Onboarding: 11. Next
    Onboarding --> User: 12. Screen 3 - Upload Guide
    User -> Onboarding: 13. Get Started
    Onboarding -> LocalStorage: 14. Save Completion Status
    Onboarding -> HomeScreen: 15. Navigate to Home
    deactivate Onboarding
end
deactivate SplashScreen

== Phase 3: Image Selection ==
activate HomeScreen
HomeScreen --> User: 16. Display Main Interface
User -> HomeScreen: 17. Select Image
HomeScreen -> ImagePicker: 18. Open Image Source Dialog
activate ImagePicker
ImagePicker --> User: 19. Show Options (Gallery/Camera)

alt Gallery
    User -> ImagePicker: 20. Choose Gallery
    ImagePicker -> ImagePicker: 21. Access Device Storage
else Camera
    User -> ImagePicker: 22. Choose Camera
    ImagePicker -> ImagePicker: 23. Capture Photo
end

ImagePicker --> HomeScreen: 24. Return Image File
deactivate ImagePicker
HomeScreen --> User: 25. Display Image Preview

== Phase 4: AI Compression Process ==
User -> HomeScreen: 26. Compress Image
HomeScreen -> LoadingOverlay: 27. Show Loading Overlay
activate LoadingOverlay
LoadingOverlay --> User: 28. Display Progress Animation
LoadingOverlay -> Compression: 29. Submit Image
activate Compression
Compression -> Backend: 30. POST /api/compress (Image Data)
activate Backend
Backend -> Backend: 31. Convert to Grayscale
Backend -> Backend: 32. Apply Fractal Decomposition
Backend -> Backend: 33. Execute AI Optimization
Backend --> Compression: 34. Return Compressed Image + Metadata
deactivate Backend
Compression --> LoadingOverlay: 35. Return Result
deactivate Compression
LoadingOverlay -> LoadingOverlay: 36. Complete Animation
LoadingOverlay --> HomeScreen: 37. Close Overlay
deactivate LoadingOverlay
deactivate HomeScreen

== Phase 5: Result Presentation ==
HomeScreen -> ResultScreen: 38. Navigate with Results
activate ResultScreen
ResultScreen --> User: 39. Display Compressed Image
ResultScreen --> User: 40. Show Statistics (Size, Ratio, Time)

alt Download
    User -> ResultScreen: 41. Download Image
    ResultScreen -> LocalStorage: 42. Save to Device
    ResultScreen --> User: 43. Confirm Download
else Share
    User -> ResultScreen: 44. Share Image
    ResultScreen --> User: 45. Open Share Dialog
else New Image
    User -> ResultScreen: 46. Compress Another
    ResultScreen --> HomeScreen: 47. Return to Home
end
deactivate ResultScreen
deactivate Application

' X Destruction markers
destroy User
destroy Application
destroy SplashScreen
destroy Onboarding
destroy HomeScreen
destroy ImagePicker
destroy LoadingOverlay
destroy Compression
destroy Backend
destroy ResultScreen
destroy LocalStorage

@enduml
```

---

## Generate PlantUML at:

**http://www.plantuml.com/plantuml/uml/**

The PlantUML version will show the **X destruction markers** at the bottom of each lifeline.
