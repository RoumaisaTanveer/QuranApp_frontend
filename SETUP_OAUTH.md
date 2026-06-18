# Google OAuth Setup — Quran Journal Frontend

This guide covers **Android OAuth** setup for `D:\quran_journal_frontend`.  
Backend (`D:\QuranApp`) is a separate repo — it only needs `GOOGLE_CLIENT_IDS` in its `.env`.

---

## Decided package name (do not change casually)

| Setting | Value | Reason |
|---------|-------|--------|
| **ANDROID_APP_ID** | `com.quranjournal.quran_journal` | Matches `android/app/build.gradle.kts` default + `MainActivity.kt` package |
| **IOS_BUNDLE_ID** | `com.quranjournal.quran_journal` | Same identity for iOS when you build later |

Configured in: `app_config.properties`

---

## Config key status

| Key | File | Purpose | Status |
|-----|------|---------|--------|
| `ANDROID_APP_ID` | `app_config.properties` | Android package for OAuth + Play Store | ✅ Set (`com.quranjournal.quran_journal`) |
| `IOS_BUNDLE_ID` | `app_config.properties` | iOS bundle ID (future iOS builds) | ✅ Set (`com.quranjournal.quran_journal`) |
| `APP_DISPLAY_NAME` | `app_config.properties` | Launcher label | ✅ Set (`Quran Journal`) |
| `GOOGLE_WEB_CLIENT_ID` | `app_config.properties` | Web + Android `serverClientId` + backend token verify | ⚠️ Placeholder — paste from Google Cloud |
| `GOOGLE_IOS_CLIENT_ID` | `app_config.properties` | iOS native sign-in | ⚠️ Placeholder — paste from Google Cloud |
| `API_BASE_URL` | `app_config.properties` | FastAPI backend URL | ✅ Set (`http://10.0.2.2:8000` for emulator) |
| `GOOGLE_CLIENT_IDS` | `D:\QuranApp\.env` | Backend accepts Google `id_token` audiences | ⚠️ Set manually in backend repo |

**Note:** Android OAuth client ID from Google Cloud is **not** stored in the frontend. Android sign-in uses the **Web** client ID as `serverClientId`. You still must create an **Android** OAuth client in Google Cloud (package + SHA-1) for sign-in to work.

---

## Step-by-step: Google Cloud Console

### 1. Open Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. **APIs & Services** → **OAuth consent screen** — configure if not done (External, add `email` + `profile`)
4. **APIs & Services** → **Credentials**

### 2. Create Web OAuth client (required first)

1. **Create Credentials** → **OAuth client ID**
2. Application type: **Web application**
3. Name: e.g. `Quran Journal Web`
4. **Authorized JavaScript origins** (required for Chrome — include port):
   ```
   http://localhost:8080
   http://127.0.0.1:8080
   ```
   (`http://localhost` alone does **not** cover random Flutter ports like `:59470`)
5. **Create** → copy **Client ID**
6. Paste into `app_config.properties`:
   ```
   GOOGLE_WEB_CLIENT_ID=<paste-here>.apps.googleusercontent.com
   ```
7. Also add the same Web client ID to backend `D:\QuranApp\.env`:
   ```
   GOOGLE_CLIENT_IDS=<web-client-id>.apps.googleusercontent.com,<ios-client-id-if-any>
   ```

### 3. Create Android OAuth client

1. **Create Credentials** → **OAuth client ID**
2. Application type: **Android**
3. Name: e.g. `Quran Journal Android`
4. **Package name** — enter **exactly**:
   ```
   com.quranjournal.quran_journal
   ```
5. **SHA-1 certificate fingerprint** — get debug SHA-1:

   **Windows (PowerShell / CMD):**
   ```cmd
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   Copy the line that looks like:
   ```
   SHA1: AA:BB:CC:DD:...
   ```

   Or run from project root (prints package + SHA-1):
   ```powershell
   cd D:\quran_journal_frontend
   .\run_app.ps1 android
   ```
   (Script prints `Android applicationId` and SHA-1 before OAuth validation.)

6. **Create** — Android client ID is registered in Google Cloud only (no paste into frontend config)

### 4. Create iOS OAuth client (when building for iOS)

1. Application type: **iOS**
2. Bundle ID: `com.quranjournal.quran_journal`
3. Paste Client ID into `app_config.properties`:
   ```
   GOOGLE_IOS_CLIENT_ID=<paste-here>.apps.googleusercontent.com
   ```
4. Add iOS client ID to backend `GOOGLE_CLIENT_IDS` (comma-separated)

---

## After pasting client IDs

1. Edit `app_config.properties` — replace `REPLACE_ME_*` values
2. Run:
   ```powershell
   cd D:\quran_journal_frontend
   .\run_app.ps1 android
   ```
3. Ensure backend is running:
   ```powershell
   cd D:\QuranApp
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

---

## Troubleshooting (Web / Chrome)

| Problem | Fix |
|---------|-----|
| `Error 400: origin_mismatch` | Add `http://localhost:8080` and `http://127.0.0.1:8080` to Web client **Authorized JavaScript origins** |
| App opens on wrong port | Use `.\run_app.ps1 chrome` or `flutter run -d chrome --web-port=8080 ...` |
| Config error on login | Run `.\sync_config.ps1` first |

## Troubleshooting (Android)

| Problem | Fix |
|---------|-----|
| `Set GOOGLE_WEB_CLIENT_ID in app_config.properties` | Replace placeholder with real Web client ID |
| `DEVELOPER_ERROR` (code 10) | Package name or SHA-1 mismatch in Android OAuth client |
| `null id_token` | Web client ID wrong/missing; check `GOOGLE_WEB_CLIENT_ID` |
| `401` from backend | Add Web client ID to `GOOGLE_CLIENT_IDS` in `D:\QuranApp\.env` |
| Cannot reach server | Physical device: set `API_BASE_URL=http://<your-pc-lan-ip>:8000` |

---

## Files touched by OAuth config

| File | Role |
|------|------|
| `app_config.properties` | Source of truth (gitignored) |
| `android/app/build.gradle.kts` | Reads `ANDROID_APP_ID`, injects `default_web_client_id` |
| `android/app/src/main/AndroidManifest.xml` | `ServerClientId` meta-data |
| `web/index.html` | Web meta tag (patched by `run_app.ps1`) |
| `ios/AppConfig.xcconfig` | Generated by `run_app.ps1` for iOS |
