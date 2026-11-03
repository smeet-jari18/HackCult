# LiFE Mitra Gujarat — Backend & Notifications Setup (do this once, ~30 min)

Everything below is already coded. You only need to **deploy** and flip a few
switches in Firebase Console. Follow the order.

---

## 0. Prerequisites

```bash
npm i -g firebase-tools
firebase login
cd life_mitra
flutter pub get
```

Project: **green-energy-fb652** (already in `lib/firebase_options.dart`,
`android/app/google-services.json`, `firebase.json`).

---

## 1. Firebase Console switches

| Where | What | Why |
|---|---|---|
| Build → Authentication → Sign-in method | Email/Password ✅, Google ✅ (already on) | login |
| Build → Firestore Database | Create database (asia-south1) if not created | all app data |
| Build → Storage | Enable | bill photo uploads |
| Build → Functions | Upgrade project to **Blaze** (pay-as-you-go, free tier is enough) | Cloud Functions need Blaze |
| Project settings → Cloud Messaging | Nothing for Android. iOS: upload APNs key. Web (optional): "Generate key pair" → paste into `PushService.webVapidKey` | push |
| Project settings → Your apps → Android | Add **SHA-1 and SHA-256** of your debug + release keystore, then re-download `google-services.json` | Google Sign-In on Android (see `GOOGLE_SIGNIN_SETUP.md`) |

Get SHA-1: `cd android && ./gradlew signingReport` (look for `Variant: debug`).

---

## 2. Deploy rules, indexes, storage

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

New in this build:
* `users/{uid}` may now store `fcmToken`, `fcmPlatform`
* `users/{uid}/pointsLedger`, `users/{uid}/events` — read-only for the owner
* `leaderboard/{uid}` — public projection (name, district, points) readable by any signed-in citizen
* `campaigns/{id}` — admin-only log of pushes
* Composite indexes for leaderboard (`district+points`, `communityId+points`, weekly variants)

---

## 3. Deploy Cloud Functions (asia-south1)

```bash
cd functions
npm install
npm run deploy          # = tsc build + firebase deploy --only functions
```

| Function | Trigger | Does |
|---|---|---|
| `createUserProfile` | Auth user created | creates `users/{uid}` |
| `setUserRole` | callable (admin) | sets admin / captain custom claims |
| **`awardTaskPoints`** | `users/{uid}/taskLogs/*` written | awards task points (daily self-verified cap 150), updates streak, longest streak, badges (`first_step`, `peak_shifter`, `led_legend`, `streak_7`, `streak_30`), writes `pointsLedger`, level-up `events` |
| **`awardFootprintPoints`** | `users/{uid}/footprints/*` created | 2 pts per unit saved + 50 for a bill upload, `bill_verified` badge |
| **`syncLeaderboard`** | `users/{uid}` written | mirrors public fields to `leaderboard/{uid}` |
| **`resetWeeklyPoints`** | every Monday 00:05 IST | weekly challenge board reset |
| **`sendCampaign`** | callable (admin) | sends FCM push to a topic (or a test to the admin's own device) and logs to `campaigns` |
| **`dailyPeakNudge`** | every day 17:30 IST | server-side peak-hour push to topic `peak_nudge` |

> The app's points/streak/badges in Firebase mode come **only** from these
> functions (clients cannot write `points` — rules block it). The app listens
> to `users/{uid}` live, so the Home/Profile numbers update a second after a
> task is completed.

Make yourself admin (needed for `/admin` and `sendCampaign`):

```bash
cd functions && npm run set-admin -- your.email@example.com
```
Then sign out / sign in again in the app (claims refresh on login).

---

## 4. Notifications — how they work now

### A. Local reminders (on-device, no server) — `lib/core/services/notification_service.dart`
| ID | When | Text | Controlled by |
|---|---|---|---|
| 1 | daily 17:30 | "Peak hours start at 6 pm ⚡" | Profile → Smart Meter Live Sync / Notifications → Peak-hour reminder (`peakNudge`) |
| 2 | daily 20:30 | "Your LiFE streak needs one task 🌱" (auto-skipped on days a task is done) | Notifications → Streak reminders (`streakReminders`) |
| 3 | 1st of month 09:00 | "New month, new bill 📄" | Notifications → Bill & weather reminders (`weatherNudge`) |

* Initialised in `main.dart` (`NotificationService.init()`); permission is asked after sign-in.
* Home → amber nudge card → **Set reminder** schedules #1 immediately.
* Profile → Notifications → **Send a test notification** proves the channel works on the device.
* Android: `POST_NOTIFICATIONS`, boot receiver, and core-library desugaring are already in
  `AndroidManifest.xml` / `build.gradle.kts`. Quiet hours (22:00–07:00) are respected by the chosen times.

### B. Push (FCM) — `lib/core/services/push_service.dart`
* After sign-in the app asks permission, saves the token to `users/{uid}.fcmToken` and subscribes to topics:
  `all_citizens`, `district_<district>`, `community_<id>` (if Community updates is on), `peak_nudge` (if Peak-hour reminder is on).
* Foreground pushes are shown through the local-notification channel `life_alerts`.
* Background pushes are shown by the OS (default channel `life_alerts`, icon set in the manifest).
* Sign-out deletes the token and unsubscribes topics.

**Sending a push**
1. Admin portal → **Campaigns** → title / message / audience → **Send push now** (calls `sendCampaign`). "Send test to me" delivers only to the admin's phone.
2. Or Firebase Console → Messaging → New campaign → topic `all_citizens`.

**Test quickly**: install the app on a phone, sign in, then in Firebase Console → Messaging → "Send test message" → paste the token printed in Firestore `users/{uid}.fcmToken`.

### C. Web push (optional)
`web/firebase-messaging-sw.js` is included. Generate a VAPID key (Console → Cloud Messaging → Web push certificates) and paste it into `PushService.webVapidKey`. Without it, web silently skips push (local reminders are mobile-only).

---

## 5. Deploy the web admin portal

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## 6. Build the Android APK for the demo

```bash
flutter build apk --release        # build/app/outputs/flutter-apk/app-release.apk
```

---

## 7. Quick verification checklist

- [ ] Sign up with email → `users/{uid}` appears (createUserProfile)
- [ ] Complete a task → `taskLogs` doc gets `pointsAwarded`, `users/{uid}.points` increases, Home shows new total within ~1 s
- [ ] `leaderboard/{uid}` doc exists → Community → Contributors shows real citizens
- [ ] Profile → Notifications → "Send a test notification" shows a system notification
- [ ] Admin → Campaigns → "Send test to me" arrives on the phone
- [ ] Hub → "Call 1800-233-0122" opens the dialer; Scheme → "Open official site" opens the browser

---

## 8. Still manual / out of scope
* Gujarati translations (strings are English; `language` preference is stored).
* Bill OCR / photo verification by GEDA staff (photos are stored; verification queue is mock).
* SMS channel (needs a provider such as MSG91 — add to `sendCampaign` if required).
