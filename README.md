# LiFE Mitra Gujarat

A Flutter hackathon prototype for Mission LiFE citizens and a GEDA-style admin portal. The prototype demonstrates sustainability tracking, community goals, solar estimates, survey requests, and Firebase-backed data persistence.

<<<<<<< HEAD
> **Backend now runs on Supabase** (Postgres + Auth + Storage + Realtime).
> Setup takes ~5 minutes: see **[README_SUPABASE.md](README_SUPABASE.md)**.
> The Firebase backend is still in the repo and can be selected with
> `--dart-define=LIFE_BACKEND=firebase`.

=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
## Run locally

```bash
flutter pub get
<<<<<<< HEAD
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
=======
flutter run
flutter run -d chrome
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
```

Open `/#/admin/login` in the browser to view the admin portal. Use Flutter 3.47+ and Dart 3.13+.

### Demo mode

When Firebase is not enabled, the app uses local mock accounts:

| Role | Email | Password |
|---|---|---|
| Citizen | `nisha@demo.com` | `Demo@1234` |
| GEDA admin | `admin@geda.demo` | `Admin@1234` |

These are prototype-only credentials. They do not sign in to the deployed Firebase app.

## Firebase prototype

The deployed web prototype is available at [green-energy-fb652.web.app](https://green-energy-fb652.web.app). Firebase Auth and Firestore persist citizen profiles/settings, task status, monthly impact, community goals, solar estimates, and survey requests.

The admin portal requires a Firebase account with the `admin` custom claim. Admins can view saved survey requests and update their status. The Overview, content editing, and campaigns pages explain which prototype functions are not connected rather than presenting demo values as live data.

## Prototype limitations

- Survey requests are saved to the user's account; they are not dispatched to vendors.
- Programme-wide analytics, content publishing, push notifications, and SMS campaigns are not connected.
- Firebase-mode rewards and photo verification are not issued/verified by a trusted server.
- Android and iOS device sign-in/testing are not covered by the deployed web demo.

This is a hackathon prototype, not a production service. Do not enter sensitive personal information.

## Validation

```bash
flutter analyze
flutter test test/flow_test.dart
flutter build web
```

## Project layout

- `lib/data/`: app state, models, and demo data
- `lib/features/`: citizen and admin screens
- `firestore.rules`: Firestore access controls
- `firestore.indexes.json`: Firestore query indexes
- `functions/`: Cloud Functions source (not deployed)
- `test/`: calculator, widget, and flow tests

## Hackathon details

- Hackathon name / organizer: to be filled in by the team
- Team and members: to be filled in by the team
- Problem statement: Mission LiFE sustainability engagement
- Demo: [green-energy-fb652.web.app](https://green-energy-fb652.web.app)

## Design v2 (Stitch screens, Nov 2026)

The citizen app now follows `DESIGN-2.md` (flat institutional utility look — mint `#F0FDF3`
canvas, white cards with 1 px `#D7DED9` borders, Deep Banyan Green `#1B5E20`, Inter type,
no gradients/glass).

| Screen | File | Route |
|---|---|---|
| Splash / Login (Citizen · Admin role toggle) / Privacy sheet / Create account / Forgot password | `lib/features/auth/auth_screens.dart` | `/splash` `/login` `/signup` `/forgot` |
| Onboarding (5 steps, step 2 = Home profile) + Baseline result | `lib/features/onboarding/onboarding_screens.dart` | `/onboarding/:step` `/onboarding/result` |
| Home dashboard | `lib/features/home/home_screens.dart` | `/home` |
| Eco-Tasks tab | `lib/features/home/tasks_screen.dart` | `/tasks` |
| Add Gas Connection (LPG / PNG) | `lib/features/home/gas_screen.dart` | `/home/gas` |
| Impact Analytics | `lib/features/impact/impact_screens.dart` | `/impact` |
| Community (Leaderboard · Ward Challenges · Noticeboard) | `lib/features/community/community_screens.dart` | `/community` |
| Citizen Profile | `lib/features/profile/profile_screens.dart` | `/profile` |

Bottom navigation: **Home · Tasks · Impact · Community · Profile** (Solar/Scheme Hub is reachable
from Impact → "Claim Subsidy Code" and Profile → "Link Another Utility", route `/hub`).

`GasConnection` (LPG/PNG) is stored in memory only for now — add the fields to the Firestore
`users` rules whitelist before persisting (see `mission_life_docs/TEAM_HANDOFF.md`).
