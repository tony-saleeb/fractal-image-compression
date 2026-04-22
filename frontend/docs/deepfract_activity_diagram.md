# DeepFract - Activity Diagram

## Fractal Image Compression Using AI Techniques

### Graduation Project - UML Documentation

---

## Mermaid Activity Diagram (Clean & Organized)

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'lineColor': '#000000'}}}%%
flowchart TB
    %% ==================== START ====================
    Start((Start))

    %% ==================== PHASE 1: INITIALIZATION ====================
    subgraph Phase1["Phase 1: Application Initialization"]
        direction TB
        A1["Launch Application"]
        A2["Load Theme Preference"]
        A3["Display Splash Screen"]
        A4["Play Animation"]
    end

    %% ==================== PHASE 2: PLATFORM DECISION ====================
    subgraph Phase2["Phase 2: Platform Routing"]
        direction TB
        D1{"Platform?"}
        A5["Show Onboarding Screen 1"]
        A6["Show Onboarding Screen 2"]
        A7["Show Onboarding Screen 3"]
        A8["Save Completion Status"]
    end

    %% ==================== PHASE 3: HOME & IMAGE SELECTION ====================
    subgraph Phase3["Phase 3: Image Selection"]
        direction TB
        A9["Display Home Screen"]
        D2{"Select Image?"}
        D3{"Image Source?"}
        A10["Access Gallery"]
        A11["Open Camera"]
        A12["Get Image File"]
        A13["Display Preview"]
    end

    %% ==================== PHASE 4: COMPRESSION ====================
    subgraph Phase4["Phase 4: AI Compression"]
        direction TB
        D4{"Compress?"}
        A14["Show Loading Overlay"]
        A15["Submit to Backend"]
        A16["Convert to Grayscale"]
        A17["Apply Fractal Compression"]
        A18["Execute AI Optimization"]
        A19["Return Compressed Data"]
        A20["Close Overlay"]
    end

    %% ==================== PHASE 5: RESULTS ====================
    subgraph Phase5["Phase 5: Result Presentation"]
        direction TB
        A21["Display Result Screen"]
        A22["Show Compressed Image"]
        A23["Show Statistics"]
        D5{"User Action?"}
        A24["Save to Device"]
        A25["Share Image"]
    end

    %% ==================== END ====================
    End((End))

    %% ==================== CONNECTIONS ====================
    Start --> A1
    A1 --> A2
    A2 --> A3
    A3 --> A4
    A4 --> D1

    D1 -- "Web" --> A9
    D1 -- "Mobile" --> A5
    A5 --> A6
    A6 --> A7
    A7 --> A8
    A8 --> A9

    A9 --> D2
    D2 -- "Yes" --> D3
    D2 -- "Theme" --> A9

    D3 -- "Gallery" --> A10
    D3 -- "Camera" --> A11
    A10 --> A12
    A11 --> A12
    A12 --> A13

    A13 --> D4
    D4 -- "No" --> D2
    D4 -- "Yes" --> A14

    A14 --> A15
    A15 --> A16
    A16 --> A17
    A17 --> A18
    A18 --> A19
    A19 --> A20

    A20 --> A21
    A21 --> A22
    A22 --> A23
    A23 --> D5

    D5 -- "Download" --> A24
    D5 -- "Share" --> A25
    D5 -- "New" --> A9
    D5 -- "Exit" --> End

    A24 --> D5
    A25 --> D5

    %% ==================== STYLING ====================
    style Start fill:#000,stroke:#000,color:#fff
    style End fill:#000,stroke:#000,color:#fff

    style D1 fill:#FFFACD,stroke:#000
    style D2 fill:#FFFACD,stroke:#000
    style D3 fill:#FFFACD,stroke:#000
    style D4 fill:#FFFACD,stroke:#000
    style D5 fill:#FFFACD,stroke:#000

    style Phase1 fill:#E3F2FD,stroke:#1976D2
    style Phase2 fill:#FFF3E0,stroke:#F57C00
    style Phase3 fill:#E8F5E9,stroke:#388E3C
    style Phase4 fill:#FCE4EC,stroke:#C2185B
    style Phase5 fill:#F3E5F5,stroke:#7B1FA2
```

---

## PlantUML Activity Diagram (Professional)

```plantuml
@startuml DeepFract_Activity

skinparam ActivityDiamondBackgroundColor #FFFACD
skinparam ActivityDiamondBorderColor #000000
skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #000000
skinparam ArrowColor #000000
skinparam PartitionBackgroundColor #F5F5F5
skinparam PartitionBorderColor #000000

title DeepFract Activity Diagram

|#E3F2FD|Phase 1: Initialization|
start
:Launch Application;
:Load Theme Preference;
:Display Splash Screen;
:Play Animation (2.5s);

|#FFF3E0|Phase 2: Routing|
if (Platform?) then (Web)
else (Mobile)
    :Show Screen 1: Compression Power;
    :Show Screen 2: AI Technology;
    :Show Screen 3: Upload Guide;
    :Save Completion Status;
endif

|#E8F5E9|Phase 3: Image Selection|
:Display Home Screen;

repeat
    if (Action?) then (Select Image)
        if (Source?) then (Gallery)
            :Access Device Gallery;
        else (Camera)
            :Open Camera;
        endif
        :Get Image File;
        :Display Preview;

        |#FCE4EC|Phase 4: Compression|
        if (Compress?) then (Yes)
            :Show Loading Overlay;
            :Submit to Backend;
            :Convert to Grayscale;
            :Apply Fractal Compression;
            :Execute AI Optimization;
            :Return Compressed Data;
            :Close Overlay;

            |#F3E5F5|Phase 5: Results|
            :Display Result Screen;
            :Show Compressed Image;
            :Show Statistics;

            repeat
                if (Action?) then (Download)
                    :Save to Device;
                    :Confirm Download;
                elseif (Share) then
                    :Share Image;
                elseif (New Image) then
                    |#E8F5E9|Phase 3: Image Selection|
                    break
                else (Exit)
                    stop
                endif
            repeat while (More Actions?)
        else (No)
            |#E8F5E9|Phase 3: Image Selection|
        endif
    elseif (Theme Toggle) then
        :Switch Theme;
    else (Exit)
        stop
    endif
repeat while (Continue?)

stop

@enduml
```

---

## Simple Clean Version (Vertical Flow)

```mermaid
%%{init: {'theme': 'base'}}%%
flowchart TB
    Start((●))
    End((◉))

    Start --> Launch

    subgraph INIT["⚙️ INITIALIZATION"]
        Launch[Launch App] --> Theme[Load Theme]
        Theme --> Splash[Splash Screen]
    end

    Splash --> Platform{Platform?}

    Platform -->|Web| Home
    Platform -->|Mobile| Onboard

    subgraph ONBOARD["📱 ONBOARDING"]
        Onboard[Screen 1] --> Screen2[Screen 2]
        Screen2 --> Screen3[Screen 3]
    end

    Screen3 --> Home

    subgraph SELECT["🖼️ IMAGE SELECTION"]
        Home[Home Screen] --> Source{Source?}
        Source -->|Gallery| Gallery[Gallery]
        Source -->|Camera| Camera[Camera]
        Gallery --> Preview[Preview]
        Camera --> Preview
    end

    Preview --> Compress{Compress?}
    Compress -->|No| Home
    Compress -->|Yes| Loading

    subgraph PROCESS["🔄 COMPRESSION"]
        Loading[Loading] --> Backend[Backend Process]
        Backend --> Done[Complete]
    end

    Done --> Result

    subgraph RESULT["📊 RESULTS"]
        Result[Result Screen] --> Stats[Statistics]
        Stats --> Action{Action?}
    end

    Action -->|Download| Download[Save]
    Action -->|Share| Share[Share]
    Action -->|New| Home
    Action -->|Exit| End

    Download --> Action
    Share --> Action

    style Start fill:#000,stroke:#000
    style End fill:#000,stroke:#000
    style Platform fill:#FFE082,stroke:#000
    style Source fill:#FFE082,stroke:#000
    style Compress fill:#FFE082,stroke:#000
    style Action fill:#FFE082,stroke:#000
```

---

## How to Use in Draw.io

1. **Arrange → Insert → Advanced → Mermaid**
2. Paste the code
3. Click **Insert**

## Phase Colors

| Phase           | Color  | Hex     |
| --------------- | ------ | ------- |
| Initialization  | Blue   | #E3F2FD |
| Routing         | Orange | #FFF3E0 |
| Image Selection | Green  | #E8F5E9 |
| Compression     | Pink   | #FCE4EC |
| Results         | Purple | #F3E5F5 |
| Decisions       | Yellow | #FFFACD |
