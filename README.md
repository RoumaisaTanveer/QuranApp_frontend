# Uns (اُنس) — Quranic Journaling App

**Uns** means familiarity, comfort, closeness — the ease you feel with something you're deeply connected to. This app brings that same closeness to the Quran: journal your thoughts and feelings, and Uns surfaces ayaat that speak to where you actually are, not just keyword matches.

## 🎥 Demo Video




https://github.com/user-attachments/assets/18b65e41-3455-41ca-bc52-de1485cd0c36



---

## What Uns Does

Uns is a journaling companion that connects your emotions to the Quran.

- **Write freely** — journal whatever's on your mind, in your own words
- **Emotion detection** — Uns reads the feeling behind your entry (grief, gratitude, anxiety, hope, and more)
- **Ayah matching** — surfaces ayaat that genuinely relate to that emotional moment, not just matching keywords
- **History & bookmarks** — revisit past entries and save ayaat that resonated with you
- **Wellbeing tracker** — see emotional patterns over time through simple charts
- **Feedback loop** — react to the ayaat you're shown, helping the app get better at understanding context with every entry

The goal: less distant recitation, more a real, ongoing closeness with the Quran — one journal entry at a time.

---

## 1. Install Flutter

### Windows
```
winget install Google.Flutter
```
Or download from: https://docs.flutter.dev/get-started/install/windows

### macOS
```
brew install flutter
```

### Verify installation
```
flutter doctor
```
Fix anything it flags (Android Studio, Xcode, etc.)

---

## 2. Get the Amiri Arabic Font

Download Amiri font files from Google Fonts:
https://fonts.google.com/specimen/Amiri

Download and place these two files in `assets/fonts/`:
- `Amiri-Regular.ttf`
- `Amiri-Bold.ttf`

---

## 3. Install dependencies

```
cd uns
flutter pub get
```

---

## 4. Update your backend URL

Open `lib/services/api_service.dart` and set your backend URL depending on your environment (local, emulator, physical device, or production).

---

## 5. Run the app

### Web (easiest for testing)
```
flutter run -d chrome
```

### Android
```
flutter run -d android
```

### iOS (Mac only)
```
flutter run -d ios
```

---

## 6. Build for release

### Android APK
```
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```
flutter build appbundle --release
```

### Web
```
flutter build web --release
```
Output in: `build/web/`

---

## 7. Backend

Uns is currently backed by a hosted API on Hugging Face Spaces. See `api_service.dart` for the active endpoint configuration.

---

## Project Structure

```
uns/
├── lib/
│   ├── main.dart              # App entry + bottom nav
│   ├── theme.dart             # Colors, fonts, text styles
│   ├── models/
│   │   └── models.dart        # Data classes
│   ├── services/
│   │   └── api_service.dart   # All API calls
│   ├── widgets/
│   │   └── widgets.dart       # Reusable UI components
│   └── screens/
│       ├── splash_screen.dart     # Splash screen
│       ├── login_screen.dart      # Auth flow
│       ├── journal_screen.dart    # Main write screen
│       ├── results_screen.dart    # Ayah results + emotion after
│       ├── history_screen.dart    # History + bookmarks tabs
│       └── wellbeing_screen.dart  # Charts + emotional tracker
├── assets/
│   └── fonts/
│       ├── Amiri-Regular.ttf  # Download from Google Fonts
│       └── Amiri-Bold.ttf
└── pubspec.yaml
```

---

## Quick start checklist

- [ ] Flutter installed (`flutter doctor` passes)
- [ ] Amiri font files placed in `assets/fonts/`
- [ ] `flutter pub get` run successfully
- [ ] Backend URL updated in `api_service.dart`
- [ ] `flutter run -d chrome` to test
