# Google Sign-In – setup checklist (LiFE Mitra Gujarat)

The app code is ready for Google login on **Web, Android and iOS**.  
If the button shows an error, it is almost always a **Firebase console / project
configuration** step that is still missing. Work through this list top-down.

The app now shows a *human readable* reason on the login screen, e.g.
`Google sign-in is not enabled for this project yet` – match it with the table
at the bottom.

---

## Live check of project `green-energy-fb652` (2 Nov 2026)

Verified against the public Identity Toolkit config of the project:

| Item | Status |
|---|---|
| Google provider enabled | ✅ yes (web OAuth client `983072556271-5piiu…` exists) |
| Email / Password provider | ✅ yes |
| Authorized domains | ✅ `localhost`, `127.0.0.1`, `green-energy-fb652.web.app`, `green-energy-fb652.firebaseapp.com` |
| `/__/auth/handler` on hosting | ✅ 200 |
| Android `google-services.json` has `oauth_client` (SHA-1 registered) | ❌ **missing → native Google picker fails on Android (ApiException 10)** |
| Deployed web build | ⚠️ old build from 29 Oct (pre-redesign) – rebuild & redeploy from this zip |

So: **Web Google login is configured correctly**; the failure you saw is the
Android build (step 3 below). The new app code falls back automatically, but
registering the SHA-1 gives the proper native account picker.

## 1. Enable the provider (ALL platforms – required)

Firebase console → **Authentication → Sign-in method → Google → Enable**  
Pick a *project support email* and save.

Without this every platform fails with `operation-not-allowed`.

## 2. Web (Flutter web / Firebase Hosting)

1. Firebase console → **Authentication → Settings → Authorized domains**  
   make sure these exist:
   * `localhost`
   * `green-energy-fb652.web.app`
   * `green-energy-fb652.firebaseapp.com`
   * any custom domain you map later
2. The app uses `signInWithPopup` (Firebase JS SDK). `web/index.html` also
   carries the project's web client id in `<meta name="google-signin-client_id">`
   (harmless; needed only if you ever switch to the google_sign_in_web button).
3. Browser pop-up blockers: the login page tells the user to allow pop-ups
   (`popup-blocked`).

## 3. Android

The current `android/app/google-services.json` has **no `oauth_client`
entry**, which means Firebase does not yet know the signing certificate of the
app. Two things to do:

1. Get the fingerprints of **every** key you build with:

   ```bash
   # debug key (used by `flutter run`)
   keytool -list -v -alias androiddebugkey \
     -keystore ~/.android/debug.keystore -storepass android -keypass android
   # release key (your upload keystore)
   keytool -list -v -alias <alias> -keystore <path/to/keystore.jks>
   ```
   Copy **SHA-1 and SHA-256**.
   (If you publish through Play Console, also add the *App signing key*
   fingerprints from Play Console → Setup → App integrity.)

2. Firebase console → **Project settings → Your apps → Android
   (`gov.gujarat.geda.lifemitra`) → Add fingerprint** → paste all of them →
   **Download the new `google-services.json`** and replace
   `android/app/google-services.json`.  
   The new file will contain `oauth_client` entries (type 1 = Android,
   type 3 = Web). The app already passes the Web client id as
   `serverClientId`, so an `idToken` is returned as soon as the SHA-1 exists.

3. `flutter clean && flutter run`.

> **Fallback already built-in:** if the native account picker is not
> configured (ApiException 10 / DEVELOPER_ERROR / missing token) the app
> automatically falls back to Firebase's browser-based provider flow
> (`signInWithProvider`). So Google login works even before step 3 – as long
> as step 1 is done – it just opens a Chrome Custom Tab instead of the
> native picker.

## 4. iOS (when you add it)

1. Firebase console → add iOS app with bundle id → download
   `GoogleService-Info.plist` into `ios/Runner/`.
2. In `ios/Runner/Info.plist` add the reversed client id as a URL scheme:
   ```xml
   <key>CFBundleURLTypes</key>
   <array><dict>
     <key>CFBundleURLSchemes</key>
     <array><string>REVERSED_CLIENT_ID_FROM_PLIST</string></array>
   </dict></array>
   ```

## 5. Test accounts while Firebase is off

`lib/main.dart` → `LifeMitraApp(useFirebase: false)` switches to the offline
demo backend. There the Google button signs in instantly as
`nisha.patel@gmail.com` (citizen) or `officer@geda.gujarat.gov.in` (admin).

---

## Error message → cause → fix

| Message shown in app | Cause | Fix |
|---|---|---|
| Google sign-in is not enabled for this project yet | Provider disabled | Step 1 |
| This website address is not authorised for Google sign-in yet | Domain missing | Step 2.1 |
| Your browser blocked the Google pop-up | Pop-up blocker | Allow pop-ups / retry |
| Google sign-in is not configured for this build (SHA-1 fingerprint missing) | No fingerprint in Firebase | Step 3 |
| This email is already registered with a password | Same email used with Email/Password earlier | Sign in with password, or enable *One account per email address* → "Allow multiple" |
| Network error | Device offline / firewall | Retry |

Code reference: `lib/data/app_state.dart` → `signInWithGoogle()`,
`_signInWithGoogleMobile()`, `_authError()`.
