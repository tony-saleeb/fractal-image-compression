# DeepFract - Use Case Diagram

## Fractal Image Compression Using AI Techniques

### Graduation Project - UML Documentation

---

## PlantUML Code

```plantuml
@startuml DeepFract_UseCase

left to right direction
skinparam packageStyle rectangle

actor User
actor Admin

rectangle "DeepFract System" {

    (Switch Theme)
    (View Onboarding)
    (View Home Screen)
    (Select Image)
    (Take A Photo)
    (Press Compress Button)
    (View Compressed Image)
    (Download Compressed Image)
    (Share Compressed Image)
    (View Compression Statistics)
    (Monitor System Performance)
    (Manage AI Models)

}

' User associations (left side - solid lines)
User --- (Switch Theme)
User --- (View Home Screen)
User --- (Press Compress Button)

' Extend relationships from View Home Screen (dashed lines)
(View Home Screen) <.. (Select Image) : <<extend>>
(View Home Screen) <.. (Take A Photo) : <<extend>>

' Include relationships (solid lines with arrow)
(Press Compress Button) --> (View Compressed Image) : <<include>>
(View Compressed Image) --> (View Compression Statistics) : <<include>>

' Extend relationships from View Compressed Image (dashed lines)
(View Compressed Image) <.. (Download Compressed Image) : <<extend>>
(View Compressed Image) <.. (Share Compressed Image) : <<extend>>

' Admin associations (right side - solid lines)
(Monitor System Performance) --- Admin
(Manage AI Models) --- Admin

@enduml
```

---

## Changes Made

| Before                                  | After                                                |
| --------------------------------------- | ---------------------------------------------------- |
| `(View Home Screen) --- (Select Image)` | `(View Home Screen) <.. (Select Image) : <<extend>>` |
| `(View Home Screen) --- (Take A Photo)` | `(View Home Screen) <.. (Take A Photo) : <<extend>>` |

Now **Select Image** and **Take A Photo** are shown as **extend** relationships with dashed lines.

---

## Generate at:

**http://www.plantuml.com/plantuml/uml/**
