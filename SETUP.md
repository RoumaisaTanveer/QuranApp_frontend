# مع القرآن — Quick Setup (3 Steps)

## Step 1 — Get the Amiri Arabic font

1. Go to https://fonts.google.com/specimen/Amiri
2. Click **Download family**
3. Unzip → copy `Amiri-Regular.ttf` and `Amiri-Bold.ttf` into `assets/fonts/`

---

## Step 2 — Install dependencies

Open terminal inside this folder:

```bash
flutter pub get
```

---

## Step 3 — Run on Chrome

Make sure your FastAPI backend is running first:
```bash
# in your backend folder:
uvicorn main:app --reload
```

Then run the Flutter app:
```bash
flutter run -d chrome
```

Or in VS Code: press **F5** → select **Chrome**

---

## To build for web deployment

```bash
flutter build web --release
```
Upload the `build/web/` folder to Netlify / Vercel / Firebase.

---

## If backend is deployed online

Open `lib/services/api_service.dart` and change:
```dart
static const String baseUrl = 'http://localhost:8000';
// to:
static const String baseUrl = 'https://your-backend-url.com';
```
