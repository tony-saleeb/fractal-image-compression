Here are the detailed written use case descriptions based on the *DeepFract System* diagram you provided.

I have organized them by functional modules (Authentication, Main User Flow, Output Management, and Administration) for clarity.

### *Module 1: Authentication*

#### *Use Case: Sign Up*
* *Primary Actor:* User
* [cite_start]*Secondary Actor:* Firebase Auth [cite: 31]
* *Relationships:*
    * [cite_start]*Includes:* Sign up validation [cite: 34, 44]
* *Description:* Allows a new user to register an account to access the system.
* *Main Flow (Steps):*
    1.  User selects the "Sign Up" option on the landing screen.
    2.  User enters required details (email, password, etc.).
    3.  *System executes the "Sign up validation" use case* (verifies format and uniqueness).
    4.  System sends data to *Firebase Auth* for account creation.
    5.  System confirms successful registration and logs the user in.

#### *Use Case: Login*
* *Primary Actor:* User
* [cite_start]*Secondary Actor:* Firebase Auth [cite: 31]
* *Relationships:*
    * [cite_start]*Includes:* Login verification [cite: 28, 38]
* *Description:* Allows an existing user to authenticate and access the application.
* *Main Flow (Steps):*
    1.  User selects the "Login" option.
    2.  User enters credentials (email/password).
    3.  *System executes the "Login verification" use case.*
    4.  System communicates with *Firebase Auth* to verify credentials.
    5.  Upon success, the System redirects the User to the Home Screen.

---

### *Module 2: Main User Flow (Image Input & Processing)*

#### *Use Case: View Home Screen*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Extended By:* Select Image From Gallery, Take A Photo [cite: 21, 12]
* *Description:* The main dashboard where the user can initiate actions.
* *Main Flow (Steps):*
    1.  System displays the default theme and navigation options.
    2.  User views the dashboard.
    3.  User may choose to trigger an extension point (e.g., select an image or take a photo).

#### *Use Case: Select Image From Gallery*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Extends:* View Home Screen, Compress Image, View Compressed Image [cite: 21, 39, 40]
* *Description:* The user browses their device storage to pick an image for compression.
* *Main Flow (Steps):*
    1.  User initiates the selection action from the Home Screen or Results screen.
    2.  System requests permission to access device storage.
    3.  User browses and confirms an image file.
    4.  System loads the image into the workspace.

#### *Use Case: Take A Photo*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Extends:* View Home Screen, View Compressed Image [cite: 12, 41]
* *Description:* The user captures a new image using the device camera for compression.
* *Main Flow (Steps):*
    1.  User selects the camera option.
    2.  System activates the device camera.
    3.  User captures a photo.
    4.  System saves the temporary image and loads it into the workspace.

#### *Use Case: Compress Image*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Includes:* View Compressed Image [cite: 26]
    * [cite_start]*Extended By:* Select Image From Gallery [cite: 39]
* *Description:* The core function where the AI Fractal algorithm processes the image.
* *Main Flow (Steps):*
    1.  User initiates the "Compress" command on the loaded image.
    2.  (Optional) User may select a new image first (Extension point).
    3.  System runs the AI Fractal compression algorithm.
    4.  System generates the output.
    5.  *System executes the "View Compressed Image" use case* to show results.

---

### *Module 3: Output & Results*

#### *Use Case: View Compressed Image*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Included By:* Compress Image [cite: 26]
    * [cite_start]*Includes:* View Compression Statistics [cite: 27]
    * [cite_start]*Extended By:* Share Compressed Image, Download Compressed Image [cite: 22, 23]
* *Description:* Displays the final processed image alongside technical data.
* *Main Flow (Steps):*
    1.  System renders the compressed image on screen.
    2.  *System automatically executes "View Compression Statistics"* (showing size reduction, quality metrics, etc.).
    3.  User views the visual result.
    4.  User may choose to Share or Download (Extension points).

#### *Use Case: View Compression Statistics*
* *Primary Actor:* User (via inclusion)
* *Relationships:*
    * [cite_start]*Included By:* View Compressed Image [cite: 27]
* *Description:* Shows the mathematical results of the compression.
* *Main Flow (Steps):*
    1.  System calculates the file size difference (Original vs. Compressed).
    2.  System calculates quality metrics (e.g., PSNR, SSIM).
    3.  System displays these metrics as an overlay or panel next to the image.

#### *Use Case: Download Compressed Image*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Extends:* View Compressed Image [cite: 23]
* *Description:* Saves the result to the local device.
* *Main Flow (Steps):*
    1.  User clicks the "Download" button.
    2.  System writes the file to the device gallery/storage.
    3.  System confirms "Download Complete".

#### *Use Case: Share Compressed Image*
* *Primary Actor:* User
* *Relationships:*
    * [cite_start]*Extends:* View Compressed Image [cite: 22]
* *Description:* Share the result via external apps (social media, email).
* *Main Flow (Steps):*
    1.  User clicks the "Share" button.
    2.  System opens the native OS sharing dialog.
    3.  User selects an external app.
    4.  System passes the image file to the selected app.

---

### *Module 4: Administration & System*

#### *Use Case: Monitor System Performance*
* [cite_start]*Primary Actor:* clerk [cite: 5]
* *Relationships:* None specified in diagram.
* *Description:* The clerk monitors the server and application health.
* *Main Flow (Steps):*
    1.  Clerk logs into the Admin dashboard.
    2.  Clerk selects "System Performance".
    3.  System displays graphs of CPU usage, active users, and memory load.
    4.  Clerk reviews data for anomalies.

#### *Use Case: Manage AI Models*
* [cite_start]*Primary Actor:* clerk [cite: 5]
* *Relationships:* None specified in diagram.
* *Description:* The clerk updates or retrains the fractal AI models used for compression.
* *Main Flow (Steps):*
    1.  Clerk accesses the "AI Models" section.
    2.  Clerk uploads a new model weight file or configuration.
    3.  System validates the new model.
    4.  System deploys the model to the compression engine.

#### *Use Case: Switch Theme*
* *Primary Actor:* User
* *Relationships:* Standard Association.
* *Description:* Allows the user to toggle between Light and Dark modes.
* *Main Flow (Steps):*
    1.  User clicks the "Theme" toggle.
    2.  System instantly updates the UI color palette.
    3.  System saves the preference for future sessions.