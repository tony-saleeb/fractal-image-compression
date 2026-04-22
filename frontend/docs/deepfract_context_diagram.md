# DeepFract - Context Diagram

## Fractal Image Compression Application

---

## Mermaid Context Diagram (Matching Reference Format)

```mermaid
flowchart LR
    User["User"]
    Admin["Admin"]

    System["Manage\nDeepFract\nApplication"]

    Backend["Backend Server /\nAI Engine"]
    Camera["Camera /\nGallery"]
    Storage["Device Storage"]

    User -->|Image selection| System
    User -->|Compression request| System
    User -->|Theme preference| System
    User -->|Download request| System

    System -->|Compressed image| User
    System -->|Statistics| User
    System -->|Progress status| User
    System -->|UI display| User

    Admin -->|Reports| System

    System -->|Original image| Backend
    Backend -->|Compressed image| System
    Backend -->|Metadata| System

    Camera -->|Photo| System
    Camera -->|Image file| System

    System -->|Save preferences| Storage
    System -->|Save image| Storage
    Storage -->|Load preferences| System

    style System fill:#fff,stroke:#4472C4,stroke-width:2px
    style User fill:#B4C7E7,stroke:#4472C4
    style Admin fill:#B4C7E7,stroke:#4472C4
    style Backend fill:#B4C7E7,stroke:#4472C4
    style Camera fill:#B4C7E7,stroke:#4472C4
    style Storage fill:#B4C7E7,stroke:#4472C4
```

---

## Use in Draw.io:

**Arrange → Insert → Advanced → Mermaid**
