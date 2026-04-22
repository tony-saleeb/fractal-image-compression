# DeepFract - Block Diagram

## Fractal Image Compression Application Using AI Techniques

### Graduation Project - System Architecture

---

## PlantUML Block Diagram (Academic Format)

```plantuml
@startuml DeepFract_Block_Diagram

skinparam backgroundColor #FFFFFF
skinparam defaultFontName "Times New Roman"
skinparam defaultFontSize 11
skinparam ArrowColor #000000
skinparam ArrowThickness 1.5

skinparam rectangle {
    BackgroundColor #FFFFFF
    BorderColor #000000
    BorderThickness 2
    RoundCorner 10
}

skinparam component {
    BackgroundColor #FFFFFF
    BorderColor #000000
    BorderThickness 1
}

title **DeepFract System - Block Diagram**\nFractal Image Compression Using AI Techniques

' ==================== USER LAYER ====================
rectangle "**User Layer**" as UserLayer #E3F2FD {
    actor "Mobile User" as MobileUser
    actor "Web User" as WebUser
}

' ==================== PRESENTATION LAYER ====================
rectangle "**Presentation Layer**" as PresentationLayer #E8F5E9 {

    rectangle "Screens" as Screens {
        component [Splash Screen] as SplashScreen
        component [Onboarding Screen] as OnboardingScreen
        component [Home Screen] as HomeScreen
        component [Result Screen] as ResultScreen
    }

    rectangle "Widgets" as Widgets {
        component [Theme Toggle] as ThemeToggle
        component [Upload Modal] as UploadModal
        component [Loading Overlay] as LoadingOverlay
        component [Statistics Display] as StatsDisplay
    }

    rectangle "Navigation" as Navigation {
        component [Route Manager] as RouteManager
    }
}

' ==================== APPLICATION LAYER ====================
rectangle "**Application Layer**" as ApplicationLayer #FFF3E0 {

    rectangle "Services" as Services {
        component [Image Picker Service] as ImagePickerService
        component [Compression Service] as CompressionService
        component [Theme Service] as ThemeService
        component [Share Service] as ShareService
    }

    rectangle "State Management" as StateManagement {
        component [Theme Provider] as ThemeProvider
        component [Image State] as ImageState
        component [Compression State] as CompressionState
    }
}

' ==================== DATA LAYER ====================
rectangle "**Data Layer**" as DataLayer #FCE4EC {

    rectangle "Local Storage" as LocalStorage {
        component [Shared Preferences] as SharedPrefs
        component [File System] as FileSystem
    }

    rectangle "API Client" as APIClient {
        component [HTTP Client] as HTTPClient
        component [API Handler] as APIHandler
    }
}

' ==================== EXTERNAL SYSTEMS ====================
rectangle "**External Systems**" as ExternalSystems #F3E5F5 {

    rectangle "Device Hardware" as DeviceHardware {
        component [Camera] as Camera
        component [Gallery] as Gallery
    }

    rectangle "Backend Server" as BackendServer {
        component [AI Compression Engine] as AIEngine
        component [Image Processor] as ImageProcessor
    }

    rectangle "Third-Party Services" as ThirdParty {
        component [Share Platform APIs] as ShareAPIs
    }
}

' ==================== CONNECTIONS ====================

' User to Presentation
MobileUser --> PresentationLayer
WebUser --> PresentationLayer

' Presentation internal
SplashScreen --> OnboardingScreen
OnboardingScreen --> HomeScreen
HomeScreen --> ResultScreen
RouteManager --> Screens

' Presentation to Application
HomeScreen --> ImagePickerService
HomeScreen --> CompressionService
ThemeToggle --> ThemeService
ResultScreen --> ShareService
LoadingOverlay --> CompressionState
StatsDisplay --> CompressionState

' Application internal
ThemeService --> ThemeProvider
ImagePickerService --> ImageState
CompressionService --> CompressionState

' Application to Data
ThemeProvider --> SharedPrefs
CompressionService --> HTTPClient
ShareService --> FileSystem
ImageState --> FileSystem

' Data to External
HTTPClient --> APIHandler
APIHandler --> AIEngine
FileSystem --> Gallery
ImagePickerService --> Camera
ImagePickerService --> Gallery
ShareService --> ShareAPIs
AIEngine --> ImageProcessor

@enduml
```

---

## Compression Pipeline Block Diagram

The following diagram illustrates the AI-powered fractal image compression pipeline:

```mermaid
flowchart TB
    subgraph INPUT["📥 INPUT STAGE"]
        A["🖼️ Image Input"]
    end

    subgraph PREPROCESSING["⚙️ PREPROCESSING STAGE"]
        B["📐 Preprocessing<br/><small>Resize, Normalize, Convert to Grayscale</small>"]
        C["🧩 Segmentation<br/><small>Divide into range blocks</small>"]
    end

    subgraph COMPRESSION["🗜️ COMPRESSION STAGE"]
        D["🔢 Generate Fractal Code<br/><small>IFS transformation mapping</small>"]
        E["🤖 Apply AI Techniques<br/><small>Deep learning optimization</small>"]
        F["💾 Store Compressed Image<br/><small>Encoded fractal parameters</small>"]
    end

    subgraph OUTPUT["📤 OUTPUT STAGE"]
        G["📦 Output Compressed Image"]
    end

    subgraph DECOMPRESSION["🔄 DECOMPRESSION STAGE"]
        H["🔧 Post-Processing<br/><small>Apply enhancement filters</small>"]
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

### Compression Pipeline - Horizontal View

```mermaid
flowchart LR
    subgraph ENCODE["🗜️ ENCODING PIPELINE"]
        direction TB
        A["🖼️ Image<br/>Input"] --> B["📐 Pre-<br/>processing"]
        B --> C["🧩 Segment-<br/>ation"]
        C --> D["🔢 Fractal<br/>Code Gen"]
        D --> E["🤖 AI<br/>Techniques"]
        E --> F["💾 Store<br/>Compressed"]
    end

    subgraph DECODE["🔄 DECODING PIPELINE"]
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

### Compression Pipeline Stages

| Stage | Component | Description | Output |
|-------|-----------|-------------|--------|
| **Input** | Image Input | User selects image from gallery or camera | Raw image data |
| **Preprocessing** | Preprocessing | Resize, normalize, convert to grayscale | Normalized grayscale image |
| | Segmentation | Divide image into non-overlapping range blocks | Block matrix |
| **Compression** | Generate Fractal Code | Create IFS (Iterated Function System) transformations | Affine transformations |
| | Apply AI Techniques | Use deep learning to optimize block matching | Optimized parameters |
| | Store Compressed | Save encoded fractal parameters | Compressed file (.frc) |
| **Output** | Output Compressed | Provide compressed file to user | Downloadable file |
| **Decompression** | Post-Processing | Apply enhancement filters | Enhanced blocks |
| | Reconstruction | Iteratively decode using fractal parameters | Reconstructed image |
| **Quality** | Compute Metrics | Calculate MSE, PSNR, SSIM scores | Quality report |
| **Final** | Final Output | Deliver reconstructed image | Final image |

### Key Algorithms

| Algorithm | Purpose | Technique |
|-----------|---------|-----------|
| **Block Partitioning** | Divide image into blocks | Quadtree decomposition |
| **Domain-Range Matching** | Find self-similar patterns | Contractive affine transformations |
| **AI Optimization** | Improve matching accuracy | CNN/Deep learning |
| **Iterative Decoding** | Reconstruct image | Fixed-point iteration |

---

## Mermaid Block Diagram

```mermaid
%%{init: {'theme': 'base'}}%%
flowchart TB
    subgraph UserLayer["User Layer"]
        MobileUser["Mobile User"]
        WebUser["Web User"]
    end

    subgraph PresentationLayer["Presentation Layer"]
        subgraph Screens["Screens"]
            Splash["Splash Screen"]
            Onboarding["Onboarding Screen"]
            Home["Home Screen"]
            Result["Result Screen"]
        end

        subgraph Widgets["Widgets"]
            ThemeToggle["Theme Toggle"]
            UploadModal["Upload Modal"]
            LoadingOverlay["Loading Overlay"]
            StatsDisplay["Statistics Display"]
        end

        RouteManager["Route Manager"]
    end

    subgraph ApplicationLayer["Application Layer"]
        subgraph Services["Services"]
            ImagePickerSvc["Image Picker Service"]
            CompressionSvc["Compression Service"]
            ThemeSvc["Theme Service"]
            ShareSvc["Share Service"]
        end

        subgraph StateManagement["State Management"]
            ThemeProvider["Theme Provider"]
            ImageState["Image State"]
            CompressionState["Compression State"]
        end
    end

    subgraph DataLayer["Data Layer"]
        subgraph LocalStorage["Local Storage"]
            SharedPrefs["Shared Preferences"]
            FileSystem["File System"]
        end

        subgraph APIClient["API Client"]
            HTTPClient["HTTP Client"]
            APIHandler["API Handler"]
        end
    end

    subgraph ExternalSystems["External Systems"]
        subgraph DeviceHardware["Device Hardware"]
            Camera["Camera"]
            Gallery["Gallery"]
        end

        subgraph Backend["Backend Server"]
            AIEngine["AI Compression Engine"]
            ImageProcessor["Image Processor"]
        end

        ShareAPIs["Share Platform APIs"]
    end

    %% Connections
    MobileUser --> PresentationLayer
    WebUser --> PresentationLayer

    Splash --> Onboarding --> Home --> Result

    Home --> ImagePickerSvc
    Home --> CompressionSvc
    ThemeToggle --> ThemeSvc
    Result --> ShareSvc

    ThemeSvc --> ThemeProvider
    ImagePickerSvc --> ImageState
    CompressionSvc --> CompressionState

    ThemeProvider --> SharedPrefs
    CompressionSvc --> HTTPClient
    ImageState --> FileSystem

    HTTPClient --> APIHandler --> AIEngine --> ImageProcessor
    ImagePickerSvc --> Camera
    ImagePickerSvc --> Gallery
    ShareSvc --> ShareAPIs

    %% Styling
    style UserLayer fill:#E3F2FD,stroke:#1976D2
    style PresentationLayer fill:#E8F5E9,stroke:#388E3C
    style ApplicationLayer fill:#FFF3E0,stroke:#F57C00
    style DataLayer fill:#FCE4EC,stroke:#C2185B
    style ExternalSystems fill:#F3E5F5,stroke:#7B1FA2
```

---

## Simplified Block Diagram

```mermaid
%%{init: {'theme': 'base'}}%%
flowchart TB
    subgraph USER["👤 USER"]
        Mobile["Mobile App"]
        Web["Web App"]
    end

    subgraph UI["📱 USER INTERFACE"]
        Screens["Screens\n─────────\n• Splash\n• Onboarding\n• Home\n• Result"]
        Widgets["Widgets\n─────────\n• Theme Toggle\n• Upload Modal\n• Loading\n• Stats"]
    end

    subgraph APP["⚙️ APPLICATION LOGIC"]
        Services["Services\n─────────\n• Image Picker\n• Compression\n• Theme\n• Share"]
        State["State Management\n─────────\n• Providers\n• Notifiers"]
    end

    subgraph DATA["💾 DATA"]
        Local["Local Storage\n─────────\n• Preferences\n• Files"]
        API["API Client\n─────────\n• HTTP\n• Handlers"]
    end

    subgraph EXTERNAL["🌐 EXTERNAL"]
        Hardware["Device\n─────────\n• Camera\n• Gallery"]
        Backend["Backend\n─────────\n• AI Engine\n• Processor"]
        Share["Share\n─────────\n• WhatsApp\n• Email"]
    end

    USER --> UI
    UI --> APP
    APP --> DATA
    DATA --> EXTERNAL

    style USER fill:#E3F2FD,stroke:#000
    style UI fill:#E8F5E9,stroke:#000
    style APP fill:#FFF3E0,stroke:#000
    style DATA fill:#FCE4EC,stroke:#000
    style EXTERNAL fill:#F3E5F5,stroke:#000
```

---

## Layer Description Table

| Layer                  | Components                            | Responsibility                             |
| ---------------------- | ------------------------------------- | ------------------------------------------ |
| **User Layer**         | Mobile User, Web User                 | End-users interacting with the application |
| **Presentation Layer** | Screens, Widgets, Navigation          | UI rendering and user interaction handling |
| **Application Layer**  | Services, State Management            | Business logic and application state       |
| **Data Layer**         | Local Storage, API Client             | Data persistence and network communication |
| **External Systems**   | Device Hardware, Backend, Third-Party | External integrations and services         |

---

## Component Description Table

### Presentation Layer Components

| Component          | Description                                        |
| ------------------ | -------------------------------------------------- |
| Splash Screen      | Initial branding display with animation            |
| Onboarding Screen  | User introduction tutorial (3 screens)             |
| Home Screen        | Main interface for image selection and compression |
| Result Screen      | Compressed image display with statistics           |
| Theme Toggle       | Light/Dark mode switch widget                      |
| Upload Modal       | Image source selection dialog                      |
| Loading Overlay    | Progress indicator during compression              |
| Statistics Display | Compression ratio and metrics display              |
| Route Manager      | Navigation controller for screen transitions       |

### Application Layer Components

| Component            | Description                                  |
| -------------------- | -------------------------------------------- |
| Image Picker Service | Handles camera and gallery image acquisition |
| Compression Service  | Manages image compression workflow           |
| Theme Service        | Controls application theme state             |
| Share Service        | Handles image sharing to external apps       |
| Theme Provider       | State notifier for theme changes             |
| Image State          | Current selected image state                 |
| Compression State    | Compression progress and result state        |

### Data Layer Components

| Component          | Description                            |
| ------------------ | -------------------------------------- |
| Shared Preferences | Key-value storage for user preferences |
| File System        | Local file storage for images          |
| HTTP Client        | Network request handler                |
| API Handler        | Backend API communication manager      |

### External System Components

| Component             | Description                            |
| --------------------- | -------------------------------------- |
| Camera                | Device camera hardware interface       |
| Gallery               | Device image gallery access            |
| AI Compression Engine | Backend fractal compression algorithm  |
| Image Processor       | Image preprocessing and postprocessing |
| Share Platform APIs   | WhatsApp, Email, social media APIs     |

---

## Data Flow Between Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER LAYER                              │
│                   Mobile User ←→ Web User                       │
└─────────────────────────────┬───────────────────────────────────┘
                              │ User Input / UI Display
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│         Screens ←→ Widgets ←→ Route Manager                     │
└─────────────────────────────┬───────────────────────────────────┘
                              │ Events / State Updates
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                            │
│              Services ←→ State Management                       │
└─────────────────────────────┬───────────────────────────────────┘
                              │ Data Operations
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
│            Local Storage ←→ API Client                          │
└─────────────────────────────┬───────────────────────────────────┘
                              │ I/O Operations
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SYSTEMS                             │
│      Device Hardware ←→ Backend Server ←→ Third-Party           │
└─────────────────────────────────────────────────────────────────┘
```

---

## How to Generate

### PlantUML:

1. Go to **http://www.plantuml.com/plantuml/uml/**
2. Paste the PlantUML code
3. Download as PNG/SVG

### Draw.io:

1. **Arrange → Insert → Advanced → Mermaid**
2. Paste the Mermaid code
3. Click **Insert**
