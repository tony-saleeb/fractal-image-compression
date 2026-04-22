# DeepFract System Analysis Document

> **Version:** 1.0  
> **Date:** December 2024  
> **Project:** DeepFract - AI-Powered Fractal Image Compression

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Block Diagram - Compression Pipeline](#block-diagram---compression-pipeline)
3. [Use Case Diagram](#use-case-diagram)
4. [Use Case Specifications](#use-case-specifications)
5. [Sequence Diagrams](#sequence-diagrams)
6. [Class Diagram](#class-diagram)
7. [Database Schema (ERD)](#database-schema)
8. [Activity Diagrams](#activity-diagrams)

---

## Block Diagram - Compression Pipeline

The following block diagram illustrates the AI-powered fractal image compression pipeline in DeepFract:

```mermaid
flowchart TB
    subgraph INPUT["📥 INPUT STAGE"]
        A["🖼️ Image Input"]
    end

    subgraph PREPROCESSING["⚙️ PREPROCESSING STAGE"]
        B["📐 Preprocessing<br/><small>Resize, Normalize, Convert</small>"]
        C["🧩 Segmentation<br/><small>Divide into blocks</small>"]
    end

    subgraph COMPRESSION["🗜️ COMPRESSION STAGE"]
        D["🔢 Generate Fractal Code<br/><small>IFS transformation</small>"]
        E["🤖 Apply AI Techniques<br/><small>Deep learning optimization</small>"]
        F["💾 Store Compressed Image<br/><small>Encoded fractal data</small>"]
    end

    subgraph OUTPUT["📤 OUTPUT STAGE"]
        G["📦 Output Compressed Image"]
    end

    subgraph DECOMPRESSION["🔄 DECOMPRESSION STAGE"]
        H["🔧 Post-Processing<br/><small>Apply filters</small>"]
        I["🏗️ Reconstruction<br/><small>Iterative decoding</small>"]
    end

    subgraph QUALITY["📊 QUALITY ASSESSMENT"]
        J["📈 Compute Quality Metrics<br/><small>MSE, PSNR, SSIM</small>"]
    end

    subgraph FINAL["✅ FINAL OUTPUT"]
        K["🖼️ Final Image Output"]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
    I --> J
    J --> K

    style INPUT fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    style PREPROCESSING fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style COMPRESSION fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style OUTPUT fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    style DECOMPRESSION fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style QUALITY fill:#e0f7fa,stroke:#0097a7,stroke-width:2px
    style FINAL fill:#c8e6c9,stroke:#2e7d32,stroke-width:3px
```

### Alternative Linear View

```mermaid
flowchart LR
    subgraph ENCODE["ENCODING PIPELINE"]
        direction TB
        A["🖼️ Image<br/>Input"] --> B["📐 Pre-<br/>processing"]
        B --> C["🧩 Segment-<br/>ation"]
        C --> D["🔢 Fractal<br/>Code Gen"]
        D --> E["🤖 AI<br/>Techniques"]
        E --> F["💾 Store<br/>Compressed"]
    end

    subgraph DECODE["DECODING PIPELINE"]
        direction TB
        G["📦 Output<br/>Compressed"] --> H["🔧 Post-<br/>Processing"]
        H --> I["🏗️ Recon-<br/>struction"]
        I --> J["📈 Quality<br/>Metrics"]
        J --> K["✅ Final<br/>Output"]
    end

    F --> G

    style ENCODE fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style DECODE fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
```

### Pipeline Stages Description

| Stage | Component | Description |
|-------|-----------|-------------|
| **Input** | Image Input | User selects image from gallery or camera |
| **Preprocessing** | Preprocessing | Resize, normalize, convert to grayscale |
| | Segmentation | Divide image into non-overlapping blocks (range blocks) |
| **Compression** | Generate Fractal Code | Create IFS (Iterated Function System) transformations |
| | Apply AI Techniques | Use deep learning to optimize affine transformations |
| | Store Compressed | Save encoded fractal parameters |
| **Output** | Output Compressed | Provide compressed file to user |
| **Decompression** | Post-Processing | Apply enhancement filters |
| | Reconstruction | Iteratively decode using fractal parameters |
| **Quality** | Compute Metrics | Calculate MSE, PSNR, SSIM scores |
| **Final** | Final Output | Deliver reconstructed image |

---

## System Overview

DeepFract is an AI-powered image compression application that uses fractal compression algorithms to achieve high compression ratios while maintaining image quality. The system supports both web and mobile platforms, integrating with Firebase for authentication and Firestore for data persistence.

### Key Features
- **User Authentication** (Email/Password, Google OAuth)
- **Image Selection** (Gallery, Camera)
- **AI-Powered Compression** (Fractal algorithms)
- **Result Visualization** (Before/After comparison, statistics)
- **Image Sharing & Download**
- **Theme Customization** (Dark/Light mode)
- **Transaction History** (Compression records)

### System Actors

| Actor | Description |
|-------|-------------|
| **User** | End-user who uses the application to compress images |
| **Clerk (Admin)** | System administrator who monitors performance and manages AI models |
| **Firebase** | Backend service for authentication and data storage |
| **AI Backend** | Server that performs the actual fractal compression |

---

## Use Case Diagram

![Use Case Diagram](file:///C:/Users/TONY/.gemini/antigravity/brain/bbbcff54-adea-4615-b667-ac57adc410be/uploaded_image_1765323771935.png)

```mermaid
graph TB
    subgraph "DeepFract System"
        UC1[Switch Theme]
        UC2[View Home Screen]
        UC3[Take A Photo]
        UC4[Select Image]
        UC5[Press Compress Button]
        UC6[View Compressed Image]
        UC7[View Compression Statistics]
        UC8[Share Compressed Image]
        UC9[Download Compressed Image]
        UC10[Monitor System Performance]
        UC11[Manage AI Models]
    end

    User((User))
    Clerk((Clerk))

    User --> UC1
    User --> UC2
    User --> UC5
    
    UC2 -.->|<<extend>>| UC3
    UC2 -.->|<<extend>>| UC4
    
    UC5 -.->|<<include>>| UC6
    
    UC6 -.->|<<include>>| UC7
    UC6 -.->|<<extend>>| UC8
    UC6 -.->|<<extend>>| UC9
    
    Clerk --> UC10
    Clerk --> UC11
```

---

## Use Case Specifications

### UC-01: Switch Theme

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-01 |
| **Name** | Switch Theme |
| **Actor** | User |
| **Preconditions** | User is authenticated and on any screen with theme access |
| **Postconditions** | Application theme is changed (Dark ↔ Light) |
| **Trigger** | User clicks on theme toggle switch |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User navigates to Profile Screen | System displays profile with current theme setting |
| 2 | User toggles the Dark Mode switch | System captures current screen state |
| 3 | | System applies theme transition animation |
| 4 | | System updates theme in ThemeProvider |
| 5 | | System persists theme preference locally |
| 6 | | System refreshes UI with new theme |

#### Alternative Flows
- **A1:** Theme animation fails → System applies theme without animation

---

### UC-02: View Home Screen

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-02 |
| **Name** | View Home Screen |
| **Actor** | User |
| **Preconditions** | User is authenticated |
| **Postconditions** | Home screen is displayed with upload options |
| **Trigger** | User completes authentication or navigates to home |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User successfully logs in | System validates authentication |
| 2 | | System determines platform (Web/Mobile) |
| 3 | | System renders appropriate home screen layout |
| 4 | | System displays navigation options |
| 5 | | System shows image selection area |

#### Extensions
- **E1:** First-time user → System shows onboarding tutorial
- **E2:** Web platform → System shows WebHomeScreen with navbar

---

### UC-03: Take A Photo

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-03 |
| **Name** | Take A Photo |
| **Actor** | User |
| **Preconditions** | User is on Home Screen, device has camera access |
| **Postconditions** | Photo is captured and ready for compression |
| **Trigger** | User selects camera option |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User taps "Camera" option | System checks camera permission |
| 2 | | System opens device camera |
| 3 | User captures photo | System receives image data |
| 4 | User confirms photo | System stores image temporarily |
| 5 | | System displays image preview |
| 6 | | System enables "Compress" button |

#### Alternative Flows
- **A1:** Camera permission denied → System shows permission request dialog
- **A2:** User cancels capture → System returns to home screen
- **A3:** Camera unavailable (web) → System hides camera option

---

### UC-04: Select Image

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-04 |
| **Name** | Select Image |
| **Actor** | User |
| **Preconditions** | User is on Home Screen |
| **Postconditions** | Image is selected and ready for compression |
| **Trigger** | User selects gallery option |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User taps "Gallery" option | System opens image picker |
| 2 | User browses gallery | System displays available images |
| 3 | User selects an image | System validates image format |
| 4 | | System reads image bytes |
| 5 | | System displays image preview |
| 6 | | System enables "Compress" button |

#### Alternative Flows
- **A1:** Storage permission denied → System shows permission dialog
- **A2:** Invalid image format → System shows error message
- **A3:** User cancels selection → System returns to home screen

---

### UC-05: Press Compress Button

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-05 |
| **Name** | Press Compress Button |
| **Actor** | User |
| **Preconditions** | Image is selected/captured |
| **Postconditions** | Image is compressed, results displayed |
| **Trigger** | User clicks compress button |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User taps "Compress" button | System validates image is selected |
| 2 | | System shows loading overlay with animation |
| 3 | | System sends image to compression service |
| 4 | | CompressionService processes image |
| 5 | | System receives compressed result |
| 6 | | System calculates compression statistics |
| 7 | | System records transaction to Firestore |
| 8 | | System navigates to result screen (UC-06) |

#### Alternative Flows
- **A1:** Compression fails → System shows error dialog
- **A2:** Network error → System shows retry option
- **A3:** User cancels during compression → System aborts and returns

---

### UC-06: View Compressed Image

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-06 |
| **Name** | View Compressed Image |
| **Actor** | User |
| **Preconditions** | Compression completed successfully |
| **Postconditions** | Compressed image is displayed with statistics |
| **Trigger** | Compression process completes (included by UC-05) |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | | System displays CompressionResultScreen |
| 2 | | System shows before/after image comparison |
| 3 | | System displays compression statistics (UC-07) |
| 4 | User can toggle between original/compressed | System updates image preview |
| 5 | | System shows action buttons (share, download, new) |

---

### UC-07: View Compression Statistics

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-07 |
| **Name** | View Compression Statistics |
| **Actor** | User |
| **Preconditions** | Viewing compression result |
| **Postconditions** | Statistics are displayed |
| **Trigger** | Result screen is shown (included by UC-06) |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | | System calculates original file size |
| 2 | | System calculates compressed file size |
| 3 | | System calculates compression ratio |
| 4 | | System calculates compression time |
| 5 | | System displays all statistics in UI |

**Statistics Displayed:**
- Original Size (e.g., "10.5 MB")
- Compressed Size (e.g., "1.05 MB")
- Compression Ratio (e.g., "90.0%")
- Compression Time (e.g., "2.5 seconds")

---

### UC-08: Share Compressed Image

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-08 |
| **Name** | Share Compressed Image |
| **Actor** | User |
| **Preconditions** | Compressed image is available |
| **Postconditions** | Image is shared via platform's share mechanism |
| **Trigger** | User taps share button |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User taps "Share" button | System gets compressed image file |
| 2 | | System invokes platform share sheet |
| 3 | User selects sharing target | Platform handles sharing |
| 4 | | System shows success confirmation |

#### Alternative Flows
- **A1:** Web platform → System uses Web Share API or clipboard
- **A2:** Sharing fails → System shows error message

---

### UC-09: Download Compressed Image

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-09 |
| **Name** | Download Compressed Image |
| **Actor** | User |
| **Preconditions** | Compressed image is available |
| **Postconditions** | Image is saved to device storage |
| **Trigger** | User taps download button |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | User taps "Download" button | System checks storage permission |
| 2 | | System generates unique filename |
| 3 | | System saves image to device storage |
| 4 | | System shows success snackbar |

#### Alternative Flows
- **A1:** Permission denied → System shows permission dialog
- **A2:** Storage full → System shows error message
- **A3:** Web platform → System triggers browser download

---

### UC-10: Monitor System Performance

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-10 |
| **Name** | Monitor System Performance |
| **Actor** | Clerk (Admin) |
| **Preconditions** | Admin access to backend systems |
| **Postconditions** | Performance metrics are viewed |
| **Trigger** | Admin accesses monitoring dashboard |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | Admin accesses dashboard | System authenticates admin |
| 2 | | System retrieves performance metrics |
| 3 | | System displays: compression counts, success rates, avg times |
| 4 | Admin reviews metrics | System provides drill-down options |

---

### UC-11: Manage AI Models

| Attribute | Description |
|-----------|-------------|
| **Use Case ID** | UC-11 |
| **Name** | Manage AI Models |
| **Actor** | Clerk (Admin) |
| **Preconditions** | Admin access to AI backend |
| **Postconditions** | AI models are updated/configured |
| **Trigger** | Admin needs to update compression models |

#### Main Success Scenario
| Step | Actor | System |
|------|-------|--------|
| 1 | Admin accesses AI management | System shows available models |
| 2 | Admin uploads new model | System validates model format |
| 3 | | System deploys model to backend |
| 4 | | System updates model version |
| 5 | Admin configures parameters | System applies new configuration |

---

## Sequence Diagrams

### SD-01: User Authentication Sequence (Email)

```mermaid
sequenceDiagram
    actor User
    participant AuthScreen
    participant AuthService
    participant Firebase
    participant Firestore
    participant HomeScreen

    User->>+AuthScreen: Enter email & password
    AuthScreen->>AuthScreen: Validate input
    AuthScreen->>+AuthService: signInWithEmail(email, password)
    AuthService->>+Firebase: signInWithEmailAndPassword()
    Firebase-->>-AuthService: UserCredential
    AuthService->>+Firestore: Check user exists
    Firestore-->>-AuthService: User document
    AuthService->>+Firestore: Update lastLogin
    Firestore-->>-AuthService: Updated
    AuthService-->>-AuthScreen: Success
    AuthScreen->>+HomeScreen: Navigate to home
    deactivate AuthScreen
    HomeScreen-->>-User: Display home screen
```

### SD-01b: User Authentication Sequence (Google Sign-In)

```mermaid
sequenceDiagram
    actor User
    participant AuthScreen
    participant AuthService
    participant GoogleSignIn
    participant Firebase
    participant Firestore
    participant HomeScreen

    User->>+AuthScreen: Click "Sign In with Google"
    AuthScreen->>+AuthService: signInWithGoogle()
    AuthService->>+GoogleSignIn: signIn()
    GoogleSignIn-->>-AuthService: GoogleSignInAccount
    AuthService->>+Firebase: signInWithCredential()
    Firebase-->>-AuthService: UserCredential
    AuthService->>+Firestore: Check user exists
    Firestore-->>-AuthService: User exists? (true/false)
    
    break User NOT registered in Firestore
        AuthService->>+Firebase: signOut()
        Firebase-->>-AuthService: Signed out
        AuthService-->>AuthScreen: Error: "Please sign up first"
        deactivate AuthService
        AuthScreen-->>User: Show error message
        deactivate AuthScreen
    end
    
    AuthService->>+Firestore: Update lastLogin
    Firestore-->>-AuthService: Updated
    AuthService-->>-AuthScreen: Success
    AuthScreen->>+HomeScreen: Navigate to home
    deactivate AuthScreen
    HomeScreen-->>-User: Display home screen
```

### SD-02: Image Selection and Compression Sequence

```mermaid
sequenceDiagram
    actor User
    participant HomeScreen
    participant ImagePickerService
    participant CompressionService
    participant LoadingOverlay
    participant TransactionService
    participant Firestore
    participant ResultScreen

    User->>+HomeScreen: Select image source
    
    alt Camera
        HomeScreen->>+ImagePickerService: captureFromCamera()
        ImagePickerService->>ImagePickerService: Open camera
        ImagePickerService-->>-HomeScreen: File
    else Gallery
        HomeScreen->>+ImagePickerService: pickFromGallery()
        ImagePickerService->>ImagePickerService: Open gallery picker
        ImagePickerService-->>-HomeScreen: File
    end
    
    HomeScreen-->>User: Show image preview
    deactivate HomeScreen
    
    User->>+HomeScreen: Press Compress button
    
    HomeScreen->>+LoadingOverlay: Show loading animation
    
    HomeScreen->>+CompressionService: compressImage(file)
    Note over CompressionService: AI-powered fractal compression
    CompressionService->>CompressionService: Calculate original size
    CompressionService->>CompressionService: Apply compression algorithm
    CompressionService->>CompressionService: Calculate compressed size
    CompressionService-->>-HomeScreen: CompressionResult
    
    HomeScreen->>+TransactionService: addTransaction()
    TransactionService->>+Firestore: Store transaction
    Firestore-->>-TransactionService: Transaction ID
    TransactionService-->>-HomeScreen: Transaction saved
    
    HomeScreen->>LoadingOverlay: Hide loading
    deactivate LoadingOverlay
    
    HomeScreen->>+ResultScreen: Navigate with result
    deactivate HomeScreen
    ResultScreen-->>-User: Display compressed image & stats
```

### SD-03: Theme Switch Sequence

```mermaid
sequenceDiagram
    actor User
    participant ProfileScreen
    participant ThemeSwitcher
    participant ThemeProvider
    participant SharedPreferences

    User->>+ProfileScreen: Toggle Dark Mode switch
    
    ProfileScreen->>+ThemeSwitcher: changeTheme()
    
    ThemeSwitcher->>ThemeSwitcher: Capture current screen image
    ThemeSwitcher->>+ThemeProvider: toggleTheme()
    
    ThemeProvider->>ThemeProvider: Switch isDark state
    ThemeProvider->>+SharedPreferences: Save theme preference
    SharedPreferences-->>-ThemeProvider: Saved
    
    ThemeProvider-->>-ThemeSwitcher: Theme changed
    
    ThemeSwitcher->>ThemeSwitcher: Apply transition animation
    ThemeSwitcher-->>-ProfileScreen: Animation complete
    
    ProfileScreen-->>-User: New theme applied
```

### SD-04: Share Compressed Image Sequence

```mermaid
sequenceDiagram
    actor User
    participant ResultScreen
    participant SharePlus
    participant Platform

    User->>+ResultScreen: Press Share button
    
    ResultScreen->>ResultScreen: Get compressed file path
    
    alt Has valid file
        ResultScreen->>+SharePlus: Share.shareXFiles([file])
        SharePlus->>+Platform: Open share sheet
        Platform-->>User: Select sharing target
        User->>Platform: Choose target app
        Platform->>Platform: Complete sharing
        Platform-->>-SharePlus: Share complete
        SharePlus-->>-ResultScreen: Success
        ResultScreen-->>User: Show success message
    else No file available
        ResultScreen-->>User: Show error message
    end
    
    deactivate ResultScreen
```

### SD-05: Download Compressed Image Sequence

```mermaid
sequenceDiagram
    actor User
    participant ResultScreen
    participant FileSystem
    participant Browser
    participant SnackBar

    User->>+ResultScreen: Press Download button
    
    ResultScreen->>ResultScreen: Check platform
    
    alt Mobile Platform
        ResultScreen->>+FileSystem: Request storage permission
        FileSystem-->>ResultScreen: Permission granted
        ResultScreen->>ResultScreen: Generate filename
        ResultScreen->>FileSystem: Save to Pictures/Downloads
        FileSystem->>FileSystem: Write file to storage
        FileSystem-->>-ResultScreen: File saved
        
        ResultScreen->>+SnackBar: Show success message
        SnackBar-->>-User: "Image saved successfully"
    else Web Platform
        ResultScreen->>ResultScreen: Create download blob
        ResultScreen->>+Browser: Trigger download
        Browser->>Browser: Download file
        Browser-->>-User: File downloaded
    end
    
    deactivate ResultScreen
```

### SD-06: View Compression Statistics Sequence

```mermaid
sequenceDiagram
    actor User
    participant ResultScreen
    participant CompressionResult

    Note over User,CompressionResult: After compression completes
    
    activate ResultScreen
    
    ResultScreen->>+CompressionResult: Get originalSize
    CompressionResult-->>-ResultScreen: originalSize (bytes)
    
    ResultScreen->>+CompressionResult: Get compressedSize
    CompressionResult-->>-ResultScreen: compressedSize (bytes)
    
    ResultScreen->>+CompressionResult: Get compressionRatio
    CompressionResult-->>-ResultScreen: ratio (percentage)
    
    ResultScreen->>ResultScreen: Format sizes to human-readable
    ResultScreen->>ResultScreen: Calculate compression time
    ResultScreen->>ResultScreen: Build statistics UI
    
    ResultScreen-->>User: Display statistics panel
    deactivate ResultScreen
    
    Note over ResultScreen: Statistics shown:
    Note over ResultScreen: - Original: "10.5 MB"
    Note over ResultScreen: - Compressed: "1.05 MB"
    Note over ResultScreen: - Ratio: "90.0%"
    Note over ResultScreen: - Time: "2.5s"
```

### SD-07: Google Sign-Up Sequence (New User Registration)

```mermaid
sequenceDiagram
    actor User
    participant AuthScreen
    participant AuthService
    participant GoogleSignIn
    participant Firebase
    participant Firestore
    participant HomeScreen

    User->>+AuthScreen: Click "Sign Up with Google"
    
    AuthScreen->>+AuthService: signUpWithGoogle()
    
    AuthService->>+GoogleSignIn: signIn()
    GoogleSignIn->>GoogleSignIn: Show Google account picker
    GoogleSignIn-->>-AuthService: GoogleSignInAccount
    
    AuthService->>+Firebase: signInWithCredential(credential)
    Firebase-->>-AuthService: UserCredential
    
    AuthService->>+Firestore: Check if user exists
    Firestore-->>-AuthService: exists = false
    
    AuthService->>+Firestore: Create user document
    Note over Firestore: Save email, displayName,<br/>photoURL, createdAt, lastLogin
    Firestore-->>-AuthService: User created
    
    AuthService-->>-AuthScreen: Success (new user)
    
    AuthScreen->>+HomeScreen: Navigate to home
    deactivate AuthScreen
    HomeScreen-->>-User: Welcome to DeepFract!
```

---

## Class Diagram

```mermaid
classDiagram
    direction TB
    
    class AuthService {
        -FirebaseAuth _auth
        -GoogleSignIn? _googleSignIn
        +Stream~User?~ authStateChanges
        +User? currentUser
        +bool isLoggedIn
        +signUpWithEmail(email, password) Future~UserCredential~
        +signInWithEmail(email, password) Future~UserCredential~
        +signInWithGoogle() Future~UserCredential?~
        +signOut() Future~void~
        +sendPasswordResetEmail(email) Future~void~
        -_handleAuthError(e) String
    }

    class CompressionService {
        +String apiBaseUrl$
        +String compressEndpoint$
        +compressImage(File) Future~CompressionResult~
        +calculateCompressionRatio(int, int) double
    }

    class CompressionResult {
        +File originalFile
        +File compressedFile
        +int originalSize
        +int compressedSize
        +double compressionRatio
        +bool isGrayscale
        +String formattedOriginalSize
        +String formattedCompressedSize
        +String formattedCompressionRatio
    }

    class CompressionException {
        +String message
        +String? code
        +dynamic originalError
        +serverError(int) CompressionException$
        +networkError(String?) CompressionException$
        +failed(dynamic) CompressionException$
        +toString() String
    }

    class ImagePickerService {
        -ImagePicker _picker
        +pickFromGalleryXFile() Future~XFile?~
        +pickFromGallery() Future~File?~
        +captureFromCameraXFile() Future~XFile?~
        +captureFromCamera() Future~File?~
        +showImageSourceDialog(context) Future~File?~$
    }

    class TransactionService {
        -FirebaseFirestore _firestore
        -_transactionsRef(userId) CollectionReference
        +addTransaction(...) Future~String~
        +getUserTransactions(userId) Future~List~
        +streamUserTransactions(userId) Stream~List~
        +getTransactionCount(userId) Future~int~
        +deleteTransaction(userId, transactionId) Future~void~
        +getTotalBytesSaved(userId) Future~int~
    }

    class UserTransaction {
        +String id
        +String userId
        +String originalFileName
        +int originalSizeBytes
        +int compressedSizeBytes
        +double compressionRatio
        +DateTime timestamp
        +fromFirestore(doc) UserTransaction$
        +toFirestore() Map
        +String formattedOriginalSize
        +String formattedCompressedSize
        +String formattedRatio
    }

    class ThemeProvider {
        +bool _isDark
        +bool isDark
        +ThemeMode themeMode
        +toggleTheme() void
        +setTheme(bool) void
        -_loadTheme() void
        -_saveTheme() void
    }

    class ProfileScreen {
        +build(context) Widget
    }

    class HomeScreen {
        +build(context) Widget
    }

    class CompressionResultScreen {
        +File originalImage
        +Uint8List? imageBytes
        +String originalSize
        +String compressedSize
        +Duration compressionTime
        +build(context) Widget
    }

    CompressionService --> CompressionResult : creates
    CompressionService --> CompressionException : throws
    TransactionService --> UserTransaction : manages
    HomeScreen --> ImagePickerService : uses
    HomeScreen --> CompressionService : uses
    CompressionResultScreen --> TransactionService : uses
    ProfileScreen --> ThemeProvider : uses
    ProfileScreen --> AuthService : uses
```

---

## Database Schema

### Firestore Database Structure

```mermaid
erDiagram
    USERS {
        string uid PK "Firebase Auth UID"
        string email "User email"
        string displayName "User display name"
        string photoURL "Profile photo URL"
        timestamp createdAt "Account creation date"
        timestamp lastLogin "Last login timestamp"
    }

    TRANSACTIONS {
        string id PK "Auto-generated ID"
        string userId FK "Reference to user"
        string originalFileName "Original file name"
        int originalSizeBytes "Size before compression"
        int compressedSizeBytes "Size after compression"
        double compressionRatio "Compression percentage"
        timestamp timestamp "Transaction timestamp"
    }

    USERS ||--o{ TRANSACTIONS : "has many"
```

### Collection Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── displayName: string
│       ├── photoURL: string
│       ├── createdAt: timestamp
│       ├── lastLogin: timestamp
│       └── transactions/
│           └── {transactionId}/
│               ├── userId: string
│               ├── originalFileName: string
│               ├── originalSizeBytes: int
│               ├── compressedSizeBytes: int
│               ├── compressionRatio: double
│               └── timestamp: timestamp
```

### Data Dictionary

| Collection | Field | Type | Description | Constraints |
|------------|-------|------|-------------|-------------|
| **users** | uid | string | Firebase Auth unique identifier | PK, Required |
| | email | string | User's email address | Required, Unique |
| | displayName | string | User's display name | Optional |
| | photoURL | string | URL to profile photo | Optional |
| | createdAt | timestamp | Account creation timestamp | Auto-set |
| | lastLogin | timestamp | Last login timestamp | Auto-update |
| **transactions** | id | string | Auto-generated document ID | PK, Auto |
| | userId | string | Reference to parent user | FK, Required |
| | originalFileName | string | Name of original file | Required |
| | originalSizeBytes | int | File size before compression | Required, >= 0 |
| | compressedSizeBytes | int | File size after compression | Required, >= 0 |
| | compressionRatio | double | Compression percentage | Required, 0-100 |
| | timestamp | timestamp | When compression occurred | Auto-set |

---

## Activity Diagrams

### AD-01: Complete Image Compression Flow

```mermaid
flowchart TD
    A[Start] --> B{User Authenticated?}
    B -->|No| C[Show Auth Screen]
    C --> D[User Signs In]
    D --> B
    B -->|Yes| E[Display Home Screen]
    
    E --> F{Select Image Source}
    F -->|Camera| G[Open Camera]
    F -->|Gallery| H[Open Gallery]
    
    G --> I{Photo Captured?}
    I -->|Yes| J[Store Image]
    I -->|No| E
    
    H --> K{Image Selected?}
    K -->|Yes| J
    K -->|No| E
    
    J --> L[Display Preview]
    L --> M{Press Compress?}
    M -->|No| N{Select New Image?}
    N -->|Yes| F
    N -->|No| O[End]
    
    M -->|Yes| P[Show Loading Overlay]
    P --> Q[Call Compression Service]
    Q --> R{Compression Success?}
    
    R -->|No| S[Show Error Dialog]
    S --> T{Retry?}
    T -->|Yes| Q
    T -->|No| E
    
    R -->|Yes| U[Calculate Statistics]
    U --> V[Save to Firestore]
    V --> W[Display Result Screen]
    
    W --> X{User Action}
    X -->|Share| Y[Share Image]
    X -->|Download| Z[Save to Device]
    X -->|New Image| E
    
    Y --> W
    Z --> W
```

### AD-02: User Authentication Flow

```mermaid
flowchart TD
    A[Start] --> B{Has Account?}
    
    B -->|Yes| C[Show Login Form]
    B -->|No| D[Show Register Form]
    
    C --> E{Login Method}
    E -->|Email| F[Enter Email/Password]
    E -->|Google| G[Google Sign-In]
    
    F --> H{Valid Credentials?}
    H -->|Yes| I[Firebase Auth]
    H -->|No| J[Show Error]
    J --> C
    
    G --> K{Platform?}
    K -->|Mobile| L[Native Google Sign-In]
    K -->|Web| M[Popup Sign-In]
    
    L --> I
    M --> I
    
    I --> N{Auth Success?}
    N -->|Yes| O[Navigate to Home]
    N -->|No| P[Show Auth Error]
    P --> C
    
    D --> Q[Enter Registration Details]
    Q --> R{Valid Details?}
    R -->|Yes| S[Create Account]
    R -->|No| T[Show Validation Error]
    T --> D
    
    S --> N
    
    O --> U[End]
```

### AD-03: Theme Switching Flow

```mermaid
flowchart TD
    A[Start] --> B[User on Profile Screen]
    B --> C[Toggle Theme Switch]
    C --> D[Capture Current Screen State]
    D --> E[ThemeSwitcher.changeTheme]
    E --> F[ThemeProvider.toggleTheme]
    F --> G{Is Dark Mode?}
    G -->|Yes| H[Switch to Light Mode]
    G -->|No| I[Switch to Dark Mode]
    H --> J[Update isDark = false]
    I --> K[Update isDark = true]
    J --> L[Save to SharedPreferences]
    K --> L
    L --> M[Apply Theme Animation]
    M --> N[Rebuild UI with New Theme]
    N --> O[End]
```

---

## Appendix

### Technology Stack

| Layer | Technology |
|-------|------------|
| **Frontend Framework** | Flutter 3.x |
| **State Management** | Provider |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage (planned) |
| **Image Processing** | AI Backend (Python/TensorFlow) |
| **File Sharing** | share_plus package |
| **Image Selection** | image_picker package |

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── core/
│   ├── constants/              # App constants
│   └── errors/                 # Custom exceptions
├── models/
│   └── user_transaction.dart   # Transaction data model
├── screens/
│   ├── splash_screen.dart      # Initial loading screen
│   ├── onboarding_screen.dart  # First-time user tutorial
│   ├── auth_screen.dart        # Login/Register screen
│   ├── home_screen.dart        # Main home (mobile)
│   ├── web_home_screen.dart    # Main home (web)
│   ├── compression_result_screen.dart  # Results display
│   ├── profile_screen.dart     # User profile
│   └── about_screen.dart       # App information
├── services/
│   ├── auth_service.dart       # Authentication logic
│   ├── compression_service.dart # Compression logic
│   ├── image_picker_service.dart # Image selection
│   └── transaction_service.dart # Firestore operations
├── utils/
│   ├── constants.dart          # UI constants
│   ├── theme_provider.dart     # Theme management
│   ├── routes.dart             # App routing
│   └── file_size_extension.dart # Size formatting
└── widgets/
    ├── animated_background.dart # Background animations
    ├── theme_switcher.dart     # Theme transition
    ├── upload_modal.dart       # Image upload dialog
    ├── web_navbar.dart         # Web navigation
    └── ... (12 total widgets)
```

---

*Document generated by analyzing the DeepFract codebase - December 2024*
