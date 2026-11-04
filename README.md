<div align="center">

# 🌿 LiFE Mitra Gujarat

### Mission LiFE ko har ghar tak — track karo, bachao, kamao.

A Flutter app + web admin portal that turns everyday low-carbon choices into
measurable savings, verified rewards and community momentum.

**Problem statement `HC26-GEDA01`** · Mission LiFE citizen engagement

<br>

[![Flutter](https://img.shields.io/badge/Flutter-3.47%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Tests](https://img.shields.io/badge/tests-28%20passing-success?style=for-the-badge)](#-testing)
[![Release](https://img.shields.io/github/v/release/smeet-jari18/HackCult?style=for-the-badge&label=android&color=1B5E20)](https://github.com/smeet-jari18/HackCult/releases/latest)

</div>

---

## 🔗 Live Links — start here

| | Platform | Link |
|:--:|---|---|
| 📱 | **Android App (APK)** | **[⬇️ Download LiFE-Mitra-v1.0.0.apk](https://github.com/smeet-jari18/HackCult/releases/download/v1.0.0/LiFE-Mitra-v1.0.0.apk)** <br><sub>69 MB · Android 6.0+ (minSdk 23) · [all releases](https://github.com/smeet-jari18/HackCult/releases)</sub> |
| 🌐 | **Web App** (citizen) | **[https://hackcult.antideploy.app](https://hackcult.antideploy.app)** |
| 🔐 | **Web Admin Login** | **[https://hackcult.antideploy.app/#/admin/login](https://hackcult.antideploy.app/#/admin/login)** |
| 🗄️ | Backend | Supabase — Postgres · Auth · Storage · Realtime |

<details>
<summary><b>Alternate / mirror deployment</b> (Firebase Hosting, older build)</summary>

<br>

| | Link |
|---|---|
| 🌐 Web app | https://green-energy-fb652.web.app |
| 🔐 Admin login | https://green-energy-fb652.web.app/#/admin/login |

Both deployments talk to **the same Supabase backend**, so accounts, points and
data are shared. The Antideploy URL is the current build — prefer it for a demo.

</details>

> 📲 **APK install:** download → open the file → allow *"Install from unknown
> sources"* if Android asks → install. No Play Store needed.

> 🔑 **Admin access is role-gated.** Signing in at the admin URL only works for
> an account whose `profiles.role = 'admin'`. See [Admin setup](#-admin-setup).

---

## 📑 Contents

- [What it does](#-what-it-does)
- [Features](#-features)
- [Photo-verified rewards](#-photo-verified-rewards)
- [Tech stack](#-tech-stack)
- [Run locally](#-run-locally)
- [Backend setup](#-backend-setup)
- [Admin setup](#-admin-setup)
- [Screens & routes](#-screens--routes)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Security](#-security)
- [Project structure](#-project-structure)
- [Limitations & roadmap](#-limitations--roadmap)
- [Repository status](#-repository-status)
- [Team](#-team)

---

## 🎯 What it does

Most sustainability apps stop at a tip list. LiFE Mitra closes the loop:

```
  Baseline your home  →  Do eco-tasks  →  Prove it with a photo
            ↓                                      ↓
   See ₹ + kWh + CO₂ saved  ←  Earn verified points  ←  Server checks the proof
            ↓
  Compete with your ward / society  →  Claim solar subsidy
```

1. **Baseline** — a 5-step onboarding captures your home, appliances and travel,
   then computes your monthly electricity, cooking and transport footprint.
2. **Act** — a curated eco-task list, each worth points, each completable with a
   camera or gallery photo as proof.
3. **Prove** — the photo is uploaded to a private, per-user storage folder. A
   **server-side Postgres function** verifies the proof path before any points
   are awarded. The client cannot mint points.
4. **Measure** — add a monthly electricity bill to see units saved, rupees saved
   and percent change against your baseline, with charts.
5. **Compete** — join or create a community (society / ward / village / school /
   office), contribute to a shared reduction goal, climb the leaderboard.
6. **Upgrade** — a rooftop-solar calculator gives size, subsidy, net cost,
   payback and 25-year CO₂ avoided, then raises a survey/quote request that
   lands in the GEDA admin's lead queue.

---

## ✨ Features

### 👤 Citizen

| | Feature | Detail |
|:--:|---|---|
| 🏠 | **Home dashboard** | Live footprint, streak, points, next-best task |
| ✅ | **Eco-Tasks** | Photo-proof completion, per-task point caps, skip / not-applicable |
| 📊 | **Impact analytics** | Monthly bill entry, kWh + ₹ + CO₂ trends, `fl_chart` visuals |
| 🏘️ | **Community** | Leaderboard, ward challenges, noticeboard, shared goals, join codes |
| ☀️ | **Solar & Scheme Hub** | Rooftop sizing, central + state subsidy, payback, vendor survey requests |
| 🔥 | **Gas connection** | LPG / PNG linkage for cooking-footprint accuracy |
| 🏅 | **Rewards** | Points history, badges (incl. `bill_verified`), weekly reset |
| 👨‍👩‍ | **Profile** | Household editing, language, notification preferences, privacy & terms |
| 🔔 | **Reminders** | Local notifications for streaks, peaks and community updates |

### 🛠️ Admin (GEDA)

| Route | Screen | Status |
|---|---|---|
| `/#/admin/login` | Role-gated sign-in | ✅ Live |
| `/#/admin` | Overview | ⚠️ Partly connected |
| `/#/admin/leads` | Solar survey / quote leads + status pipeline | ✅ Live |
| `/#/admin/content` | Task & scheme content editing | 🚧 Not connected |
| `/#/admin/campaigns` | Push / SMS campaigns | 🚧 Not connected |

Lead statuses: `new → contacted → survey_done → quoted → installed → dropped`.

Admin pages that are not wired up **say so on screen** instead of showing fake
numbers as if they were live.

---

## 📸 Photo-verified rewards

The core anti-cheat design. Points are never trusted from the client.

```
camera / gallery
      ↓  resize 1600px, q82, ≤10 MB, jpeg/png/webp
private bucket  bill-proofs/<uid>/<file>
      ↓  storage path only — never a public URL
RPC  award_task_points(..., p_proof_path)
      ↓
verify_proof_path(path, uid)
      • path must start with the caller's own uid/
      • rejects ".." traversal
      • object must actually exist in storage.objects
      ↓
points awarded + points_ledger entry + badge
```

**Enforced in the database, not the UI:**

| Rule | Behaviour |
|---|---|
| Photo-required task, no proof | Rejected — `A photo proof is required for this task.` |
| Proof path points nowhere | Rejected — `Proof photo not found. Please upload the photo again.` |
| Someone else's folder | Rejected by prefix check + RLS |
| Per-task ceiling | **100 points** |
| Non-self task without proof | Capped at **50 points** |
| Bill bonus | **+50** and the `bill_verified` badge, only with a verified proof |
| Admin review | `admin_task_proofs(p_limit)` — admin-only, `anon` revoked |
| Proof viewing | Signed URLs, 1-hour expiry |

Schema: [`supabase/migrations/0002_photo_proofs.sql`](supabase/migrations/0002_photo_proofs.sql)
· Guide: [`PHOTO_VERIFICATION.md`](PHOTO_VERIFICATION.md)

---

## 🧱 Tech stack

| Layer | Choice |
|---|---|
| **UI** | Flutter 3.47+ / Dart 3.13+ — Android, iOS, Web, desktop |
| **Routing** | `go_router` 14 with role-based redirects |
| **State** | `AppState` + `AppScope` (InheritedNotifier), no codegen |
| **Backend** | **Supabase** — Postgres, Row Level Security, Auth, Storage, Realtime |
| **Auth** | Email/password + Google sign-in |
| **Charts** | `fl_chart` |
| **Media** | `image_picker` (camera + gallery) |
| **Notifications** | `flutter_local_notifications`, `firebase_messaging` |
| **Legacy backend** | Firebase (Auth, Firestore, Storage) — still selectable, see below |
| **Hosting** | Antideploy (static) · Firebase Hosting (mirror) |
| **Design** | Flat institutional utility — mint `#F0FDF3`, Deep Banyan Green `#1B5E20`, Inter |

**Three backend modes**, chosen at build time:

```bash
# Supabase (default & recommended)
flutter run -d chrome

# Legacy Firebase
flutter run -d chrome --dart-define=LIFE_BACKEND=firebase

# Offline demo — no backend, local mock data
flutter run -d chrome --dart-define=LIFE_BACKEND=demo
```

Selection priority is **Supabase → Firebase → demo data**: Supabase is used
automatically whenever it is configured, unless you explicitly override it.

<details>
<summary><b>Offline demo credentials</b> (<code>LIFE_BACKEND=demo</code> only — these do not work on the deployed app)</summary>

<br>

| Role | Email | Password |
|---|---|---|
| Citizen | `nisha@demo.com` | `Demo@1234` |
| GEDA admin | `admin@geda.demo` | `Admin@1234` |

</details>

---

## 🚀 Run locally

**Prerequisites:** Flutter 3.47+, Dart 3.13+, Chrome (for web) or an Android
device/emulator. Node 18+ only if you touch `functions/`.

```bash
git clone https://github.com/smeet-jari18/HackCult.git
cd HackCult
flutter pub get

# Web
flutter run -d chrome

# Android
flutter run -d <device-id>
```

The Supabase URL and publishable key already have working fallbacks in
`lib/data/supabase/supabase_config.dart`, so it runs with no extra setup. To point
at your own project instead:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-key>
```

**Release builds**

```bash
flutter build apk --release      # Android
flutter build web --release      # Web  → build/web
```

> 💡 Add `--no-wasm-dry-run` to `flutter build web` to skip the extra dart2wasm
> dry-run pass — noticeably less memory and faster, with identical JS output.

---

## 🗄️ Backend setup

Full walkthrough: **[README_SUPABASE.md](README_SUPABASE.md)** ·
[BACKEND_SETUP.md](BACKEND_SETUP.md) ·
[GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md)

Apply the migrations **in order** in the Supabase SQL editor:

```
supabase/migrations/0001_init.sql          -- tables, RLS, storage, RPCs
supabase/migrations/0002_photo_proofs.sql  -- proof verification + point caps
```

**Tables**

`profiles` · `communities` · `community_members` · `task_logs` · `footprints` ·
`points_ledger` · `solar_assessments` · `survey_requests` · `leaderboard` ·
`push_tokens`

Every table has Row Level Security with per-owner policies; `anon` has no read
or write access to user data. Profiles are protected by a `SECURITY DEFINER`
guard trigger so a client cannot edit its own `points` or `role`.

**Storage:** one private bucket, `bill-proofs`, with per-uid folder policies.

---

## 🔑 Admin setup

Deploying does not make anyone an admin. The app reads `profiles.role`.

1. Sign up in the app with the email you want to use.
2. In the Supabase **SQL Editor**:

```sql
update public.profiles
set role = 'admin'
where email = 'you@example.com';

-- verify
select email, role from public.profiles where role = 'admin';
```

3. Sign in at **[/#/admin/login](https://hackcult.antideploy.app/#/admin/login)**.

Without step 2 the screen reports *"This account is not a GEDA admin."* — that is
the role gate working, not a bug.

<details>
<summary>Legacy Firebase mode: admin uses a custom claim instead</summary>

```bash
cd functions
npm install
npm run set-admin -- you@example.com
```

</details>

---

## 🗺️ Screens & routes

The app uses **hash URLs** on web, so every route is prefixed with `/#`.

<details>
<summary><b>Citizen routes</b> (click to expand)</summary>

<br>

| Route | Screen |
|---|---|
| `/#/splash` | Splash |
| `/#/login` · `/#/signup` · `/#/forgot` | Auth (Citizen · Admin toggle) |
| `/#/onboarding/:step` · `/#/onboarding/result` | 5-step onboarding + baseline result |
| `/#/home` | Home dashboard |
| `/#/home/gas` | Add LPG / PNG connection |
| `/#/tasks` · `/#/tasks/:id` | Eco-Tasks list + detail |
| `/#/impact` · `/#/impact/add-month` | Analytics + monthly bill entry |
| `/#/community` | Leaderboard · challenges · noticeboard |
| `/#/community/join` · `/#/community/create` · `/#/community/goals/:id` | Community actions |
| `/#/hub` · `/#/hub/solar` · `/#/hub/solar/result/:id` | Scheme Hub + solar calculator |
| `/#/hub/vendors` · `/#/hub/schemes/:id` | Vendors + scheme detail |
| `/#/profile` · `/#/profile/edit` | Profile |
| `/#/profile/badges` · `/#/profile/points` · `/#/profile/notifications` | Rewards + settings |
| `/#/legal/privacy` · `/#/legal/terms` | Legal |

Bottom nav: **Home · Tasks · Impact · Community · Profile**

</details>

<details>
<summary><b>Admin routes</b></summary>

<br>

| Route | Screen |
|---|---|
| `/#/admin/login` | Admin sign-in |
| `/#/admin` | Overview |
| `/#/admin/leads` | Solar leads pipeline |
| `/#/admin/content` | Content editing |
| `/#/admin/campaigns` | Campaigns |

Citizens can never open `/#/admin/*` — the router redirects them to `/#/home`.

</details>

---

## 🧪 Testing

```bash
flutter analyze
flutter test test/
```

**Current status on the deployed source:**

| Check | Result |
|---|---|
| `flutter analyze` | ✅ **No issues found** |
| `flutter test test/` | ✅ **28 / 28 passing** |
| `flutter build web --release` | ✅ **Built** |

| Suite | Covers |
|---|---|
| `calculators_test.dart` | Footprint, solar sizing, subsidy, payback maths |
| `supabase_layer_test.dart` | Row → model mapping, RPC payloads, friendly error mapping |
| `proof_picker_test.dart` | Picker sheet, preview, retake, confirm-disabled state |
| `flow_test.dart` | Onboarding → task → points flow |
| `widget_test.dart` | Widget rendering |

**Live backend was also verified** against the hosted Supabase project:
anonymous reads denied (`42501`), anonymous storage upload denied (RLS), proof
RPCs auth-guarded, realtime subscribes, both migrations applied.

---

## 🚢 Deployment

### Antideploy (current)

Flutter is not a framework Antideploy builds from source, so the **release build
output is pushed as a static site** — which is free and unlimited on every plan.

```bash
bash deploy-antideploy.sh
```

Runs `pub get → analyze → test → build web → trim → push → watch`.

The trim step matters: a full `build/web` is ~46 MB against a 28 MB push ceiling.
This build declares a single target (`dart2js` + `canvaskit`), so the unused
`skwasm*` / `wimp*` variants and `*.symbols` debug files are dropped → ~25 MB.
Details in **[ANTIDEPLOY.md](ANTIDEPLOY.md)**.

### Firebase Hosting (mirror)

```bash
npm i -g firebase-tools
firebase login
flutter build web --release
firebase deploy --only hosting --project green-energy-fb652
```

`firebase.json` is already configured (`public: build/web`, SPA rewrites,
`no-cache` headers). A GitHub Actions workflow is included at
`.github/workflows/deploy-web.yml` — add a `FIREBASE_SERVICE_ACCOUNT` repository
secret and every push to `main` deploys automatically.

### Android

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

Attach it to a GitHub release — that is how `v1.0.0` was published.

---

## 🔒 Security

| Control | Where |
|---|---|
| Row Level Security on every table | `0001_init.sql` |
| `SECURITY DEFINER` guard on profile writes | cannot self-edit `points` / `role` |
| Private storage, per-uid folder policies | `bill-proofs/<uid>/…` |
| Server-side proof verification | `verify_proof_path()` in `0002` |
| Point caps enforced in Postgres | 100 / task, 50 without proof |
| Admin-only proof review, `anon` revoked | `admin_task_proofs()` |
| Signed URLs, 1 h expiry | proof viewing |
| Role-gated admin routes | `app_router.dart` |

**About the keys in this repo.** The Firebase Web `apiKey` and the Supabase
**publishable** key are **public identifiers, not secrets** — they are compiled
into every client app by design and cannot be hidden. Access is controlled by
Security Rules and Row Level Security, both verified to deny anonymous access.
GitHub's secret scanner flags the Firebase key as a false positive;
`.github/secret_scanning.yml` documents the exclusion.

**Never commit:** a Firebase Admin service-account JSON, a Supabase
`service_role` key, an FCM server key, or any SMTP / payment secret.
Full notes: **[SECURITY_NOTES.md](SECURITY_NOTES.md)**.

> This is a hackathon prototype, not a production service. Please do not enter
> sensitive personal information.

---

## 📁 Project structure

```
lib/
├── app.dart                  # root widget, backend selection
├── main.dart                 # entry point
├── core/
│   ├── services/             # proof_picker, push_service
│   ├── theme/                # AppTheme — flat institutional design
│   └── widgets/              # shared UI, proof_picker_sheet
├── data/
│   ├── app_state.dart        # AppState + AppScope
│   ├── models.dart           # AppUser, UserRole, …
│   └── supabase/             # config + repository
├── features/
│   ├── auth/  onboarding/  home/  impact/
│   ├── community/  hub/  profile/  legal/
│   └── admin/                # admin_screens.dart
└── router/app_router.dart    # go_router + role redirects

supabase/migrations/          # 0001_init.sql, 0002_photo_proofs.sql
test/                         # 28 tests
functions/                    # legacy Cloud Functions (not deployed)
web/                          # index.html, FCM service worker, icons
firestore.rules               # legacy Firebase access control
storage.rules
firebase.json                 # Hosting + rules config
```

**Docs:** [README_SUPABASE.md](README_SUPABASE.md) ·
[PHOTO_VERIFICATION.md](PHOTO_VERIFICATION.md) ·
[ANTIDEPLOY.md](ANTIDEPLOY.md) ·
[DEPLOY_WEB.md](DEPLOY_WEB.md) ·
[SECURITY_NOTES.md](SECURITY_NOTES.md) ·
[TEAM_HANDOFF.md](TEAM_HANDOFF.md)

---

## 🚧 Limitations & roadmap

Be aware of these before judging or demoing.

**Known limitations**

- Admin **Overview** analytics, **content editing** and **campaigns** are not
  wired to live data yet.
- Survey requests are stored and visible to admins; they are **not dispatched to
  vendors** automatically.
- `task_logs` RLS is `for all`, so a client can still update its own
  `points_awarded` row. `profiles.points` is protected, so the leaderboard is
  safe — but the ledger row is not yet immutable.
- `GasConnection` is in-memory only until the profile whitelist is extended.
- Gujarati / Hindi localisation is scaffolded, not complete.
- End-to-end signup → task → points has not been walked through with a live
  session on a physical device.

**Roadmap**

- [ ] Fix `main` (see below) and add CI for analyze + test on every PR
- [ ] Wire admin Overview to real aggregates
- [ ] Task / scheme content editing
- [ ] FCM push + campaign delivery on Supabase
- [ ] Gujarati + Hindi localisation
- [ ] Make `points_ledger` append-only and tighten `task_logs` to insert-only
- [ ] Firebase App Check / Supabase captcha for auth-abuse protection
- [ ] iOS release build

---

## ⚠️ Repository status

> **`main` currently contains unresolved merge-conflict markers and does not
> compile.**
>
> Commit `e764d57 "Merge final branch into main"` was committed with the conflict
> markers still in the files — **297 markers across 11 files**, concentrated in
> `lib/data/app_state.dart` (147), `home_screens.dart` (42),
> `impact_screens.dart` (39) and `admin_screens.dart` (27). `flutter build web`
> fails with errors such as `The getter 'AppScope' isn't defined`.
>
> The **deployed app and the `v1.0.0` APK are built from the correct, verified
> source** — `flutter analyze` clean, 28/28 tests passing. Only the `main`
> branch's working tree is affected.
>
> **Fix:** replace `main`'s `lib/` with the verified source rather than
> hand-merging 297 markers. Remove this section once that lands.

---

## 👥 Team

| | |
|---|---|
| **Project** | LiFE Mitra Gujarat |
| **Problem statement** | `HC26-GEDA01` — Mission LiFE citizen engagement |
| **Repository** | [smeet-jari18/HackCult](https://github.com/smeet-jari18/HackCult) |
| **Team name** | _to be added_ |
| **Members** | Smeet Jariwala , Shivansh Gupta , Prafull mayanksingh , Swapnil Dhodi |
| **Organisation** | _to be added_ |

---

<div align="center">

### 🌱 Every unit saved is a unit not generated.

**[📱 Get the Android app](https://github.com/smeet-jari18/HackCult/releases/latest)** ·
**[🌐 Open the web app](https://hackcult.antideploy.app)** ·
**[🔐 Admin login](https://hackcult.antideploy.app/#/admin/login)**

<sub>Built with Flutter & Supabase for Mission LiFE.</sub>

</div>
