# Software Engineering Exam Answer
## DeepFract - Fractal Image Compression Using AI Techniques

---

## (a) Main Idea and Problem Definition (3 Marks)

### Problem Definition (Given, It is Required To, Such That Pattern)

**Given:**
- The increasing need for efficient image storage and transmission in mobile and web applications
- Traditional compression methods (JPEG, PNG) have limitations in compression ratio while maintaining quality
- Users need a simple, cross-platform solution for image compression

**It is Required To:**
- Develop a cross-platform application (Mobile & Web) that compresses images using AI-powered fractal compression techniques
- Provide an intuitive user interface for selecting, compressing, and sharing images
- Display compression statistics including size reduction, compression ratio, and processing time

**Such That:**
- Users can achieve higher compression ratios compared to traditional methods
- Image quality is preserved using AI optimization algorithms
- The application works seamlessly on both mobile devices (iOS/Android) and web browsers
- The compression process is fast, user-friendly, and accessible to non-technical users

---

## (b) Front-End Implementation: Three Major Steps (9 Marks)

### Step 1: Requirements Analysis Phase

**Techniques Used:**
- **Use Case Diagrams**: Identified all user interactions (Select Image, Compress Image, Download, Share, Toggle Theme)
- **User Stories**: Documented requirements from user perspective
  - "As a user, I want to select an image from my gallery so that I can compress it"
  - "As a user, I want to see compression statistics so that I understand the results"
- **Stakeholder Interviews**: Gathered requirements from potential users

**Approaches:**
- **Functional Requirements Analysis**: Identified core features (image selection, compression, result display)
- **Non-Functional Requirements Analysis**: Performance (fast compression), Usability (intuitive UI), Portability (cross-platform)

---

### Step 2: UI/UX Design Phase

**Techniques Used:**
- **Wireframing**: Created low-fidelity mockups for each screen
- **Prototyping**: Built interactive prototypes to validate user flow
- **User Flow Diagrams**: Mapped the navigation between screens

**Approaches:**
- **Material Design Guidelines**: Followed Google's Material Design for consistent, modern UI
- **Responsive Design**: Ensured UI adapts to mobile and web platforms
- **Component-Based Design**: Designed reusable UI components (buttons, modals, overlays)

**Design Decisions:**
| Screen | Design Approach |
|--------|-----------------|
| Splash Screen | Brand animation for recognition |
| Onboarding | Step-by-step tutorial with illustrations |
| Home Screen | Centered upload area with clear CTA |
| Result Screen | Before/After comparison with statistics |

---

### Step 3: Implementation Phase

**Techniques Used:**
- **Widget Composition**: Built complex UIs from simple, reusable widgets
- **State Management (Provider Pattern)**: Managed app state reactively
- **Platform-Specific Adaptation**: Different layouts for mobile vs web

**Approaches:**
- **Flutter Framework**: Single codebase for iOS, Android, and Web
- **Clean Architecture**: Separated UI (Screens/Widgets), Logic (Services), and Data (Storage)
- **Iterative Development**: Built and tested features incrementally

**Implementation Structure:**
```
lib/
├── screens/         # UI Screens
├── widgets/         # Reusable Components
├── services/        # Business Logic
├── utils/           # Theme, Constants, Routes
└── main.dart        # App Entry Point
```

---

## (c) Types of Control in Main Home Page (3 Marks)

The Home Page contains the following types of controls:

### 1. **Action Controls (Command Buttons)**
| Control | Type | Purpose |
|---------|------|---------|
| Upload Button | Primary Action | Triggers image selection modal |
| Compress Button | Primary Action | Initiates compression process |
| Theme Toggle | Toggle Switch | Switches between light/dark mode |

### 2. **Selection Controls**
| Control | Type | Purpose |
|---------|------|---------|
| Gallery Option | Radio/Selection | Choose image from device gallery |
| Camera Option | Radio/Selection | Capture new photo from camera |

### 3. **Display Controls**
| Control | Type | Purpose |
|---------|------|---------|
| Image Preview | Image Display | Shows selected image before compression |
| Loading Overlay | Progress Indicator | Shows compression progress |

### 4. **Navigation Controls**
| Control | Type | Purpose |
|---------|------|---------|
| App Bar | Navigation Bar | Contains title and theme toggle |
| Back Button | Navigation | Returns to previous screen |

### Control Classification Summary:
- **Input Controls**: Upload button, Camera/Gallery selection
- **Output Controls**: Image preview, Loading indicator
- **Navigation Controls**: App bar, Back button
- **State Controls**: Theme toggle switch

---

## Summary

| Part | Key Points |
|------|------------|
| (a) | Problem: Need for efficient image compression → Solution: AI-powered fractal compression app |
| (b) | Three Steps: Analysis (Use Cases) → Design (Wireframes, Material Design) → Implementation (Flutter, Clean Architecture) |
| (c) | Controls: Action (Buttons), Selection (Gallery/Camera), Display (Preview), Navigation (App Bar) |
