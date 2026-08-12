# HelpHub Development Setup

This document records what was installed on this computer based on your project guidelines, and what you still need to do manually.

## Installed on this machine

| Tool | Status | Location / Version |
|------|--------|-------------------|
| Flutter SDK | Installed | `C:\src\flutter` (3.44.8) |
| Dart SDK | Included with Flutter | 3.12.2 |
| Git | Already installed | 2.53.0 |
| VS Code | Already installed | 1.129.1 |
| VS Code Dart extension | Already installed | dart-code.dart-code |
| VS Code Flutter extension | Installed | dart-code.flutter |
| Node.js LTS | Installed | 24.18.0 |
| Firebase CLI | Installed | 15.24.0 |
| FlutterFire CLI | Installed | 1.4.0 |
| Android Studio | Download/install in progress | via winget |

### PATH updated (User environment)

- `C:\src\flutter\bin`
- `C:\Users\Criza Mae Panuelos\AppData\Local\Pub\Cache\bin`

Restart VS Code or open a new terminal so PATH changes take effect.

## Project created

- **Location:** `C:\Users\Criza Mae Panuelos\Documents\HelpHub`
- **Package name:** `com.helphub.helphub`
- **Git:** initialized (not committed yet)

### Folder structure (per guidelines)

```
lib/
  algorithm/   priority_algorithm.dart (starter)
  models/
  services/
  screens/
  widgets/
  utils/
  main.dart
```

### Packages added to pubspec.yaml

- firebase_core, firebase_auth, cloud_firestore, firebase_storage
- firebase_messaging, firebase_app_check
- geolocator, permission_handler, google_maps_flutter
- geoflutterfire_plus, image_picker, intl, uuid

---

## Manual steps you still need to complete

### 1. Finish Android Studio setup (required for Android emulator)

If Android Studio finished installing, open it once and complete the setup wizard:

1. Open **Android Studio** from Start Menu
2. Choose **Standard** installation
3. Let it download **Android SDK**, **SDK Platform**, and **Android Virtual Device**
4. After setup, run in a new terminal:

```powershell
flutter doctor --android-licenses
flutter doctor
```

### 2. Enable Windows Developer Mode (required for Flutter plugins)

Flutter reported that plugin builds need symlink support.

1. Press `Win + I` → **Privacy & security** → **For developers**
2. Turn on **Developer Mode**
3. Or run: `start ms-settings:developers`

### 3. Connect Firebase to the project

1. Create a Firebase project at https://console.firebase.google.com
2. Enable **Authentication**, **Firestore**, **Storage**, **Cloud Messaging**, and **App Check**
3. In the HelpHub folder, run:

```powershell
cd "C:\Users\Criza Mae Panuelos\Documents\HelpHub"
firebase login
flutterfire configure
```

This generates `firebase_options.dart` and links Android/iOS apps.

### 4. Google Maps API key (for map display)

1. In Google Cloud Console, enable **Maps SDK for Android**
2. Create an API key
3. Add it to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 5. Open the project in VS Code

```powershell
code "C:\Users\Criza Mae Panuelos\Documents\HelpHub"
```

### 6. Create GitHub repository (optional but recommended)

```powershell
cd "C:\Users\Criza Mae Panuelos\Documents\HelpHub"
git commit -m "Initial HelpHub Flutter project setup"
gh repo create HelpHub --private --source=. --push
```

---

## Recommended next coding steps (from guidelines)

1. Sprint 1: Firebase connection + database collections
2. Sprint 2: Authentication (login, signup, role-based access)
3. Sprint 3: Resident dashboard
4. Sprint 4: Concern reporting with one-time location capture
5. Sprint 5: Rule-Based Weighted Priority Queue Algorithm
6. Sprint 6–10: Admin dashboard, SOS, notifications, announcements, testing

## Important scope reminders

- Location is captured **only** when submitting a report or activating SOS (no background tracking)
- Do **not** include assistance request feature in current scope
- Every report must pass through the priority algorithm before saving

## Quick verification commands

```powershell
flutter --version
dart --version
firebase --version
flutterfire --version
flutter doctor
```
