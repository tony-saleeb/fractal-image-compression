# DeepFract - Component Diagram

## UML Component Diagram (Proper Notation)

### Fractal Image Compression Using AI Techniques

---

## PlantUML Component Diagram

```plantuml
@startuml DeepFract_Component

skinparam backgroundColor #FFFFFF
skinparam componentStyle uml2
skinparam ArrowColor #000000

title DeepFract - Component Diagram

package "DeepFract Application" {

    package "Presentation Layer" #E8F5E9 {
        [Splash Screen] as Splash
        [Onboarding Screen] as Onboarding
        [Home Screen] as Home
        [Result Screen] as Result
        [Upload Modal] as Upload
        [Loading Overlay] as Loading
        [Theme Switcher] as ThemeSwitch
    }

    package "Application Layer" #FCE4EC {
        [Image Picker Service] as ImagePicker
        [Compression Service] as Compression
        [Theme Service] as Theme
        [Share Service] as Share
    }

    package "Data Layer" #F3E5F5 {
        [Local Storage] as Storage
        [HTTP Client] as HTTP
    }

}

package "External Systems" #FFF3E0 {
    [Backend Server] as Backend
    [Device Camera] as Camera
    [Device Gallery] as Gallery
    [Share Platforms] as SharePlat
}

' Interfaces
interface "IImagePicker" as IIP
interface "ICompression" as IC
interface "ITheme" as IT
interface "IShare" as IS
interface "IStorage" as IST
interface "IHTTP" as IH

' Provided Interfaces
ImagePicker -up- IIP
Compression -up- IC
Theme -up- IT
Share -up- IS
Storage -up- IST
HTTP -up- IH

' Required Interfaces (Dependencies)
Home ..> IIP : uses
Home ..> IC : uses
Home ..> IT : uses
Result ..> IS : uses
Upload ..> IIP : uses
ThemeSwitch ..> IT : uses

' Service Dependencies
ImagePicker ..> Camera : accesses
ImagePicker ..> Gallery : accesses
Compression ..> IH : uses
HTTP ..> Backend : calls
Share ..> SharePlat : calls
Theme ..> IST : uses

' Navigation
Splash --> Onboarding : navigates
Splash --> Home : navigates
Onboarding --> Home : navigates
Home --> Result : navigates

@enduml
```

---

## Simplified Component Diagram

```plantuml
@startuml DeepFract_Component_Simple

skinparam componentStyle uml2

package "DeepFract" {

    component [UI Layer] as UI
    component [Service Layer] as Service
    component [Data Layer] as Data

    UI --> Service
    Service --> Data
}

cloud "External" {
    component [Backend API] as API
    component [Device HW] as HW
}

Data --> API
Service --> HW

@enduml
```

---

## Mermaid Component Diagram (UML Style)

```mermaid
flowchart LR
    subgraph DeepFract["DeepFract Application"]
        subgraph UI["UI Layer"]
            Screens["📱 Screens"]
            Widgets["🧩 Widgets"]
        end

        subgraph Services["Service Layer"]
            IS(("○"))
            IC(("○"))
            IT(("○"))
            ImageSvc["Image Picker"]
            CompSvc["Compression"]
            ThemeSvc["Theme"]
        end

        subgraph Data["Data Layer"]
            Storage["Local Storage"]
            HTTP["HTTP Client"]
        end
    end

    subgraph External["External"]
        Backend["Backend Server"]
        Camera["Camera"]
        Gallery["Gallery"]
    end

    Screens -->|uses| IS
    IS --- ImageSvc
    Screens -->|uses| IC
    IC --- CompSvc
    Widgets -->|uses| IT
    IT --- ThemeSvc

    ImageSvc --> Camera
    ImageSvc --> Gallery
    CompSvc --> HTTP
    HTTP --> Backend
    ThemeSvc --> Storage
```

---

## Component Notation Guide

| Symbol              | Meaning            |
| ------------------- | ------------------ |
| Rectangle with tabs | Component          |
| Lollipop (○—)       | Provided Interface |
| Socket (◠)          | Required Interface |
| Solid Arrow         | Dependency         |
| Dashed Arrow        | Uses               |

---

## Components and Interfaces

| Component            | Provided Interface | Description           |
| -------------------- | ------------------ | --------------------- |
| Image Picker Service | IImagePicker       | Camera/Gallery access |
| Compression Service  | ICompression       | Image compression     |
| Theme Service        | ITheme             | Theme management      |
| Share Service        | IShare             | Image sharing         |
| Local Storage        | IStorage           | Data persistence      |
| HTTP Client          | IHTTP              | API communication     |

---

## Generate at:

**http://www.plantuml.com/plantuml/uml/**
