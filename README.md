# مع القرآن — Flutter App Setup Guide

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

```bash
cd quran_journal
flutter pub get
```

---

## 4. Update your backend URL

Open `lib/services/api_service.dart` and change:
```dart
static const String baseUrl = 'http://localhost:8000';
```

**For Android emulator** (can't use localhost):
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**For physical Android device** (use your PC's local IP):
```dart
static const String baseUrl = 'http://192.168.1.X:8000';  // your PC's IP
```

**For web** (same machine):
```dart
static const String baseUrl = 'http://localhost:8000';
```

**For production** (after deploying backend):
```dart
static const String baseUrl = 'https://your-api.yourdomain.com';
```

---

## 5. Run the app

### Web (easiest to test)
```bash
flutter run -d chrome
```

### Android
```bash
# Start emulator or connect physical device
flutter run -d android
```

### iOS (Mac only)
```bash
flutter run -d ios
```

---

## 6. Build for release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS (Mac only)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
# Output in: build/web/
```

---

## 7. Deploy the web version

### Option A — Netlify (easiest, free)
1. Run `flutter build web --release`
2. Go to https://netlify.com
3. Drag the `build/web/` folder onto Netlify
4. Done — your app is live

### Option B — Firebase Hosting (free)
```bash
npm install -g firebase-tools
firebase login
firebase init hosting   # select build/web as public dir
flutter build web --release
firebase deploy
```

### Option C — Vercel (free)
```bash
npm install -g vercel
flutter build web --release
cd build/web
vercel --prod
```

---

## 8. Deploy the backend (FastAPI)

### Option A — Railway (free tier, easiest)
1. Push your backend folder to GitHub
2. Go to https://railway.app
3. New project → Deploy from GitHub
4. Add env var: `OPENROUTER_API_KEY=your_key`
5. Railway auto-detects FastAPI and deploys

### Option B — Render (free tier)
1. Push to GitHub
2. https://render.com → New Web Service
3. Build command: `pip install -r requirements.txt`
4. Start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Option C — Your own VPS
```bash
pip install fastapi uvicorn sentence-transformers pandas
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

## Project Structure

```
quran_journal/
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

## CORS — important for web deployment

When deploying both frontend (web) and backend to different domains,
make sure your FastAPI backend allows your frontend's domain:

```python
# In main.py, update the CORS middleware:
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:*",
        "https://your-app.netlify.app",  # add your domain
        "*"  # or keep wildcard for now
    ],
    ...
)
```

---

## Quick start checklist

- [ ] Flutter installed (`flutter doctor` passes)
- [ ] Amiri font files placed in `assets/fonts/`
- [ ] `flutter pub get` run successfully
- [ ] Backend URL updated in `api_service.dart`
- [ ] FastAPI backend running
- [ ] `flutter run -d chrome` to test
