# DeepFract - Class Diagram & Analysis Classes

> **Project:** DeepFract - AI-Powered Fractal Image Compression  
> **Version:** 1.0  
> **Date:** December 2024

---

## Table of Contents

1. [Class Diagram (Entity Classes - Attributes Only)](#class-diagram-entity-classes)
2. [Analysis Class Diagram (BCE Pattern)](#analysis-class-diagram)
3. [Entity Classes](#entity-classes)
4. [Control Classes](#control-classes)
5. [Boundary/Interface Classes](#boundaryinterface-classes)
6. [Class Relationships](#class-relationships)

---

## Class Diagram (Entity Classes)

> **Note:** This diagram shows only **attributes** (no methods) - suitable for Object-Oriented Database design.

```mermaid
classDiagram
    direction TB

    class User {
        <<Entity>>
        -String uid
        -String email
        -String displayName
        -String photoURL
        -DateTime createdAt
        -DateTime lastLogin
    }

    class Transaction {
        <<Entity>>
        -String id
        -String userId
        -String originalFileName
        -int originalSizeBytes
        -int compressedSizeBytes
        -double compressionRatio
        -DateTime timestamp
    }

    class CompressionResult {
        <<Entity>>
        -File originalFile
        -File compressedFile
        -int originalSize
        -int compressedSize
        -double compressionRatio
        -bool isGrayscale
    }

    class ThemePreference {
        <<Entity>>
        -String id
        -bool isDarkMode
        -DateTime lastModified
    }

    class ImageData {
        <<Entity>>
        -String id
        -String fileName
        -String filePath
        -int fileSize
        -String mimeType
        -Uint8List bytes
    }

    %% Relationships with Cardinality
    User "1" --> "0..*" Transaction : has many
    User "1" --> "0..1" ThemePreference : has one
    Transaction "1" --> "1" CompressionResult : produces
    CompressionResult "1" --> "2" ImageData : contains (original + compressed)
```

---

## Entity Classes - Attributes Table

### User Entity

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| `uid` | String | PK, NOT NULL | Firebase Auth unique identifier |
| `email` | String | NOT NULL, UNIQUE | User email address |
| `displayName` | String | NULLABLE | User display name |
| `photoURL` | String | NULLABLE | Profile photo URL |
| `createdAt` | DateTime | NOT NULL | Account creation timestamp |
| `lastLogin` | DateTime | NOT NULL | Last login timestamp |

### Transaction Entity

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| `id` | String | PK, NOT NULL | Auto-generated document ID |
| `userId` | String | FK, NOT NULL | Reference to User.uid |
| `originalFileName` | String | NOT NULL | Original image filename |
| `originalSizeBytes` | int | NOT NULL, >= 0 | Size before compression |
| `compressedSizeBytes` | int | NOT NULL, >= 0 | Size after compression |
| `compressionRatio` | double | NOT NULL, 0-100 | Compression percentage |
| `timestamp` | DateTime | NOT NULL | When compression occurred |

### CompressionResult Entity

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| `originalFile` | File | NOT NULL | Original image file |
| `compressedFile` | File | NOT NULL | Compressed image file |
| `originalSize` | int | NOT NULL | Original size in bytes |
| `compressedSize` | int | NOT NULL | Compressed size in bytes |
| `compressionRatio` | double | NOT NULL | Ratio percentage |
| `isGrayscale` | bool | NOT NULL | Whether output is grayscale |

### ThemePreference Entity

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| `id` | String | PK | User identifier |
| `isDarkMode` | bool | NOT NULL | Theme preference |
| `lastModified` | DateTime | NOT NULL | Last change timestamp |

### ImageData Entity

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| `id` | String | PK | Unique identifier |
| `fileName` | String | NOT NULL | File name |
| `filePath` | String | NULLABLE | File system path |
| `fileSize` | int | NOT NULL | Size in bytes |
| `mimeType` | String | NOT NULL | MIME type (image/jpeg, etc.) |
| `bytes` | Uint8List | NULLABLE | Raw image bytes |

---

## Analysis Class Diagram

> **BCE Pattern:** Boundary (Interface), Control, Entity classes

```mermaid
classDiagram
    direction TB

    %% ==================== ENTITY CLASSES ====================
    class User {
        <<Entity>>
        -String uid
        -String email
        -String displayName
        -String photoURL
        -DateTime createdAt
        -DateTime lastLogin
    }

    class Transaction {
        <<Entity>>
        -String id
        -String userId
        -String originalFileName
        -int originalSizeBytes
        -int compressedSizeBytes
        -double compressionRatio
        -DateTime timestamp
    }

    class CompressionResult {
        <<Entity>>
        -String originalFile
        -String compressedFile
        -int originalSize
        -int compressedSize
        -double compressionRatio
        -bool isGrayscale
    }

    class ThemePreference {
        <<Entity>>
        -bool isDarkMode
    }

    %% ==================== CONTROL CLASSES ====================
    class AuthController {
        <<Control>>
        +signUpWithEmail(email, password)
        +signInWithEmail(email, password)
        +signUpWithGoogle()
        +signInWithGoogle()
        +signOut()
        +sendPasswordResetEmail(email)
        +validateCredentials(email, password)
        +checkUserExists(uid)
        +createUserRecord(user)
        +updateLastLogin(uid)
    }

    class CompressionController {
        <<Control>>
        +compressImage(imageFile)
        +calculateCompressionRatio(original, compressed)
        +validateImageFormat(file)
        +prepareImageForCompression(file)
        +processCompressionResult(result)
        +saveTransaction(result, userId)
    }

    class ImageController {
        <<Control>>
        +pickFromGallery()
        +captureFromCamera()
        +validateImage(file)
        +readImageBytes(file)
        +showImageSourceDialog(context)
    }

    class TransactionController {
        <<Control>>
        +addTransaction(data)
        +getUserTransactions(userId)
        +deleteTransaction(userId, transactionId)
        +getTransactionCount(userId)
        +getTotalBytesSaved(userId)
        +streamTransactions(userId)
    }

    class ThemeController {
        <<Control>>
        +toggleTheme()
        +setTheme(isDark)
        +loadTheme()
        +saveTheme()
        +notifyThemeChange()
    }

    class NavigationController {
        <<Control>>
        +navigateToHome()
        +navigateToProfile()
        +navigateToResult(result)
        +navigateToAuth()
        +navigateBack()
    }

    %% ==================== BOUNDARY/INTERFACE CLASSES ====================
    class AuthScreen {
        <<Boundary>>
        +displayLoginForm()
        +displaySignUpForm()
        +displayGoogleSignInButton()
        +showErrorMessage(message)
        +showLoadingIndicator()
        +hideLoadingIndicator()
    }

    class HomeScreen {
        <<Boundary>>
        +displayUploadArea()
        +displayImagePreview(image)
        +displayCompressButton()
        +showUploadModal()
        +showLoadingOverlay()
    }

    class CompressionResultScreen {
        <<Boundary>>
        +displayOriginalImage()
        +displayCompressedImage()
        +displayStatistics(stats)
        +displayActionButtons()
        +showShareSheet()
        +showDownloadConfirmation()
    }

    class ProfileScreen {
        <<Boundary>>
        +displayUserInfo(user)
        +displayThemeToggle()
        +displayStatistics(stats)
        +displaySignOutButton()
        +showConfirmationDialog()
    }

    class UploadModal {
        <<Boundary>>
        +displayCameraOption()
        +displayGalleryOption()
        +displayDragDropArea()
        +showImagePreview(image)
    }

    class LoadingOverlay {
        <<Boundary>>
        +displayLoadingAnimation()
        +displayProgressText()
        +displayCancelButton()
    }

    class WebNavbar {
        <<Boundary>>
        +displayLogo()
        +displayNavigationItems()
        +displayProfileButton()
        +highlightActiveItem()
    }

    %% ==================== RELATIONSHIPS WITH CARDINALITY ====================

    %% Boundary --> Control (1 to 1)
    AuthScreen "1" --> "1" AuthController : uses
    HomeScreen "1" --> "1" ImageController : uses
    HomeScreen "1" --> "1" CompressionController : uses
    CompressionResultScreen "1" --> "1" TransactionController : uses
    ProfileScreen "1" --> "1" AuthController : uses
    ProfileScreen "1" --> "1" ThemeController : uses

    %% Control --> Entity (1 to many)
    AuthController "1" --> "0..*" User : manages
    CompressionController "1" --> "1" CompressionResult : creates
    TransactionController "1" --> "0..*" Transaction : manages
    ThemeController "1" --> "1" ThemePreference : manages

    %% Entity relationships
    User "1" --> "0..*" Transaction : owns
```

---

## Entity Classes

> **Purpose:** Represent data objects stored in the database. Contains only attributes.

```mermaid
classDiagram
    class User {
        <<Entity>>
        -String uid
        -String email
        -String displayName
        -String photoURL
        -DateTime createdAt
        -DateTime lastLogin
    }

    class Transaction {
        <<Entity>>
        -String id
        -String userId
        -String originalFileName
        -int originalSizeBytes
        -int compressedSizeBytes
        -double compressionRatio
        -DateTime timestamp
    }

    class CompressionResult {
        <<Entity>>
        -File originalFile
        -File compressedFile
        -int originalSize
        -int compressedSize
        -double compressionRatio
        -bool isGrayscale
    }

    class ThemePreference {
        <<Entity>>
        -bool isDarkMode
    }

    User "1" --> "0..*" Transaction : has many
    User "1" --> "0..1" ThemePreference : has one
    Transaction "1" --> "1" CompressionResult : produces
```

---

## Control Classes

> **Purpose:** Contain business logic and methods. Process requests from Boundary classes and manipulate Entity classes.

```mermaid
classDiagram
    class AuthController {
        <<Control>>
        +signUpWithEmail(email, password)
        +signInWithEmail(email, password)
        +signUpWithGoogle()
        +signInWithGoogle()
        +signOut()
        +sendPasswordResetEmail(email)
        +checkUserExists(uid)
        +createUserRecord(user)
        +updateLastLogin(uid)
    }

    class CompressionController {
        <<Control>>
        +compressImage(imageFile)
        +calculateCompressionRatio(original, compressed)
        +validateImageFormat(file)
        +processCompressionResult(result)
        +saveTransaction(result, userId)
    }

    class ImageController {
        <<Control>>
        +pickFromGallery()
        +captureFromCamera()
        +validateImage(file)
        +readImageBytes(file)
        +showImageSourceDialog(context)
    }

    class TransactionController {
        <<Control>>
        +addTransaction(data)
        +getUserTransactions(userId)
        +deleteTransaction(userId, transactionId)
        +getTransactionCount(userId)
        +getTotalBytesSaved(userId)
    }

    class ThemeController {
        <<Control>>
        +toggleTheme()
        +setTheme(isDark)
        +loadTheme()
        +saveTheme()
    }
```

### Control Classes - Methods Table

| Controller | Method | Parameters | Return | Description |
|------------|--------|------------|--------|-------------|
| **AuthController** | signUpWithEmail | email, password | UserCredential | Create new account |
| | signInWithEmail | email, password | UserCredential | Authenticate user |
| | signUpWithGoogle | - | UserCredential? | Google OAuth sign-up |
| | signInWithGoogle | - | UserCredential? | Google OAuth sign-in |
| | signOut | - | void | End session |
| | checkUserExists | uid | bool | Verify user in database |
| **CompressionController** | compressImage | File | CompressionResult | Compress image |
| | calculateCompressionRatio | int, int | double | Calculate ratio |
| | saveTransaction | result, userId | void | Store record |
| **ImageController** | pickFromGallery | - | File? | Select from gallery |
| | captureFromCamera | - | File? | Take photo |
| **TransactionController** | addTransaction | data | String | Add new record |
| | getUserTransactions | userId | List | Get history |
| | getTotalBytesSaved | userId | int | Calculate savings |
| **ThemeController** | toggleTheme | - | void | Switch theme |
| | loadTheme | - | void | Load saved preference |
| | saveTheme | - | void | Persist preference |

---

## Boundary/Interface Classes

> **Purpose:** Handle user interaction. Display data and capture user input. Communicate with Control classes.

```mermaid
classDiagram
    class AuthScreen {
        <<Boundary>>
        +displayLoginForm()
        +displaySignUpForm()
        +displayGoogleSignInButton()
        +showErrorMessage(message)
        +showLoadingIndicator()
    }

    class HomeScreen {
        <<Boundary>>
        +displayUploadArea()
        +displayImagePreview(image)
        +displayCompressButton()
        +showUploadModal()
        +showLoadingOverlay()
    }

    class CompressionResultScreen {
        <<Boundary>>
        +displayOriginalImage()
        +displayCompressedImage()
        +displayStatistics(stats)
        +displayActionButtons()
        +showShareSheet()
    }

    class ProfileScreen {
        <<Boundary>>
        +displayUserInfo(user)
        +displayThemeToggle()
        +displayStatistics(stats)
        +displaySignOutButton()
    }

    class UploadModal {
        <<Boundary>>
        +displayCameraOption()
        +displayGalleryOption()
        +showImagePreview(image)
    }

    class LoadingOverlay {
        <<Boundary>>
        +displayLoadingAnimation()
        +displayProgressText()
    }

    class WebNavbar {
        <<Boundary>>
        +displayNavigationItems()
        +displayProfileButton()
    }
```

### Boundary Classes - Interface Methods Table

| Screen | Method | Description |
|--------|--------|-------------|
| **AuthScreen** | displayLoginForm() | Render login form with email/password fields |
| | displaySignUpForm() | Render sign-up form with confirmation |
| | displayGoogleSignInButton() | Show Google OAuth button |
| | showErrorMessage(msg) | Display error feedback |
| | showLoadingIndicator() | Show progress spinner |
| **HomeScreen** | displayUploadArea() | Show image upload zone |
| | displayImagePreview(img) | Preview selected image |
| | displayCompressButton() | Show compression action button |
| | showUploadModal() | Open source selection dialog |
| **CompressionResultScreen** | displayOriginalImage() | Show before image |
| | displayCompressedImage() | Show after image |
| | displayStatistics(stats) | Show compression metrics |
| | showShareSheet() | Open platform share dialog |
| **ProfileScreen** | displayUserInfo(user) | Show user details |
| | displayThemeToggle() | Show dark/light switch |
| | displaySignOutButton() | Show logout option |

---

## Class Relationships

### BCE Interaction Diagram

```mermaid
flowchart LR
    subgraph Boundary["🖥️ BOUNDARY (Interface)"]
        B1[AuthScreen]
        B2[HomeScreen]
        B3[ResultScreen]
        B4[ProfileScreen]
    end

    subgraph Control["⚙️ CONTROL"]
        C1[AuthController]
        C2[CompressionController]
        C3[ImageController]
        C4[TransactionController]
        C5[ThemeController]
    end

    subgraph Entity["📦 ENTITY"]
        E1[User]
        E2[Transaction]
        E3[CompressionResult]
        E4[ThemePreference]
    end

    %% Boundary to Control (1 to 1)
    B1 -->|"1..1"| C1
    B2 -->|"1..1"| C2
    B2 -->|"1..1"| C3
    B3 -->|"1..1"| C4
    B4 -->|"1..1"| C1
    B4 -->|"1..1"| C5

    %% Control to Entity (1 to many)
    C1 -->|"1..*"| E1
    C2 -->|"1..1"| E3
    C4 -->|"1..*"| E2
    C5 -->|"1..1"| E4

    style Boundary fill:#e3f2fd,stroke:#1976d2
    style Control fill:#e8f5e9,stroke:#388e3c
    style Entity fill:#fff3e0,stroke:#f57c00
```

---

## Mapping to Codebase

| Analysis Class | Code Implementation | File |
|----------------|---------------------|------|
| **AuthController** | AuthService | `lib/services/auth_service.dart` |
| **CompressionController** | CompressionService | `lib/services/compression_service.dart` |
| **ImageController** | ImagePickerService | `lib/services/image_picker_service.dart` |
| **TransactionController** | TransactionService | `lib/services/transaction_service.dart` |
| **ThemeController** | ThemeProvider | `lib/utils/theme_provider.dart` |
| **User** | Firebase User + Firestore doc | Firestore `users` collection |
| **Transaction** | UserTransaction | `lib/models/user_transaction.dart` |
| **CompressionResult** | CompressionResult | `lib/services/compression_service.dart` |
| **AuthScreen** | AuthScreen | `lib/screens/auth_screen.dart` |
| **HomeScreen** | HomeScreen | `lib/screens/home_screen.dart` |
| **ResultScreen** | CompressionResultScreen | `lib/screens/compression_result_screen.dart` |
| **ProfileScreen** | ProfileScreen | `lib/screens/profile_screen.dart` |

---

*Document generated from DeepFract codebase analysis - December 2024*
