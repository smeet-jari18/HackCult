# Supabase Setup — LiFE Mitra Gujarat

This build talks to **Supabase (Postgres + Auth + Storage + Realtime)**.
The old Firebase backend is still in the repo and still works — it just isn't
used when Supabase is configured.

```
AppState
 ├── useSupabase = true  → SupabaseRepo  (Postgres + RLS + RPC + Realtime)   ← new, default
 ├── useFirebase = true  → Firestore + Firebase Auth (legacy, untouched)
 └── both false          → in-memory demo data (tests / offline demo)
```

`main.dart` picks the backend automatically:

| Situation | Backend |
|---|---|
| `SUPABASE_URL` + `SUPABASE_ANON_KEY` provided | **Supabase** |
| `--dart-define=LIFE_BACKEND=firebase` | Firebase |
| `--dart-define=LIFE_BACKEND=demo` | Demo data |
| nothing provided | Firebase if it initialises, else demo |

---

## 1. Create the Supabase project (2 min)

1. <https://supabase.com/dashboard> → **New project**.
2. Region: **Mumbai / ap-south-1** (closest to Gujarat).
3. Copy from **Project Settings → API**:
   - **Project URL** → `https://xxxxxxxx.supabase.co`
   - **anon public** key (`eyJhbGciOi...`)

> The anon key is a *public* client key. It is safe in the app bundle — all
> protection comes from Row Level Security (RLS), which is enabled on every
> table.

## 2. Run the database migration (1 min)

**SQL Editor → New query → paste → Run**

```
supabase/migrations/0001_init.sql
```

That single file creates everything:

- tables: `profiles`, `communities`, `community_members`, `task_logs`,
  `footprints`, `points_ledger`, `solar_assessments`, `survey_requests`,
  `leaderboard`, `push_tokens` + view `community_goal_progress`
- sign-up trigger that creates the profile row (replaces `createUserProfile`)
- **points engine** `award_task_points()` — daily self cap 150, streak,
  badges (`first_step`, `peak_shifter`, `led_legend`, `streak_7`, `streak_30`),
  lifetime totals, points ledger, community-goal contribution — one atomic
  transaction (replaces `awardTaskPoints`)
- `award_footprint_points()` — 2 pts/unit saved + 50 for a bill upload +
  `bill_verified` badge (replaces `awardFootprintPoints`)
- `join_community()`, `admin_survey_requests()`, `reset_weekly_points()`
  (replaces `syncLeaderboard`, `resetWeeklyPoints`)
- leaderboard projection trigger + RLS policies on every table
- realtime publication for `profiles`, `communities`, `leaderboard`,
  `survey_requests`

Safe to re-run. It is idempotent.

## 3. Enable file uploads (30 s)

**Storage → New bucket → name `bill-proofs` → Private → Create.**

## 4. Enable sign-in methods (2 min)

**Authentication → Providers**

- **Email** → enable. For a hackathon demo, turn **off**
  *"Confirm email"* (Authentication → Sign In / Providers → Email), otherwise
  new users must click a mail link before their first sign-in.
- **Google** → enable, paste the OAuth *Client ID* + *Client Secret* from
  [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
  (OAuth client type **Web application**), and under *Authorised redirect URIs*
  add:

  ```
  https://<your-project-ref>.supabase.co/auth/v1/callback
  ```

**Authentication → URL Configuration**

- Site URL: `http://localhost:5000` (or your deployed web URL)
- Redirect URLs: add
  ```
  http://localhost:5000
  http://localhost:*
  https://<your-web-domain>
  io.lifemitra://login-callback
  ```
  The last one is the Android deep link already registered in
  `AndroidManifest.xml`.

## 5. Connect the app

Pick ONE:

**A. Command line (recommended, no code edit)**

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...

# web release build
flutter build web --release \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

**B. Edit two constants** — `lib/data/supabase/supabase_config.dart`:

```dart
static const String _urlFallback  = 'https://xxxxxxxx.supabase.co';
static const String _anonFallback = 'eyJhbGciOi...';
```

(Great for handing the zip to a teammate — keys are baked in.)

**C. IDE** — VS Code `launch.json`:

```json
{
  "name": "LiFE Mitra (Supabase)",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": [
    "--dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co",
    "--dart-define=SUPABASE_ANON_KEY=eyJhbGciOi..."
  ]
}
```

## 6. Make yourself an admin

Sign up once in the app, then in the SQL Editor:

```sql
update public.profiles set role = 'admin' where email = 'you@example.com';
```

Sign out / sign in again (or just reload) → `/#/admin/login` now works and
*Solar leads* loads every survey request.

---

## Smoke test (2 min) — do this before the demo

1. **Sign up** with a new email → onboarding wizard appears.
2. Complete onboarding → baseline row appears in `footprints`
   (`is_baseline = true`), profile `onboarding_complete = true`.
3. **Complete a task** → points increase ~1 s later (Realtime), a row lands in
   `task_logs` + `points_ledger`. Complete 10 quick tasks → self-points stop at
   150 for the day (the cap is server-side).
4. **Add a monthly bill** → `footprints` row + points = 2 × units saved (+50 if
   uploaded as a bill) and the `bill_verified` badge.
5. **Create/join a community** with a join code → `communities` +
   `community_members`, goal progress aggregates over members.
6. **Solar estimate → save request** → `survey_requests` row.
7. **Admin portal** (`/#/admin/login`) → *Solar leads* lists the request; change
   its status → the row updates in the table.
8. **Leaderboard** tab → shows other citizens (never your own row twice).

Quick SQL check:

```sql
select display_name, role, points, weekly_points, streak, badges
from public.profiles order by points desc;

select * from public.task_logs order by id desc limit 5;
select * from public.points_ledger order by id desc limit 5;
select * from public.community_goal_progress;
```

---

## Security model (same guarantees as the old Cloud Functions)

- RLS is ON for every table. A user can only read/write their own rows.
- `profiles.points`, `weekly_points`, `streak`, `badges`, … are **server-owned**:
  the `guard_profile_writes()` trigger silently reverts any client attempt to
  change them. Only `award_task_points()` / `award_footprint_points()`
  (`security definer`) may write them — exactly like the old Cloud Functions.
- `role` can only be changed by an existing admin.
- The leaderboard exposes only name / district / points / streak.
- Admin lead access goes through `admin_survey_requests()`, which checks
  `is_admin()` server-side.

## What is *not* on Supabase yet

| Feature | Status |
|---|---|
| Push notifications (FCM campaigns) | still Firebase. `PushService` is untouched; in Supabase mode device **local** reminders (peak hour 17:30, streak 20:30, bill reminder) keep working. The admin "send nudge" button shows a message instead of calling `sendCampaign`. Moving to Supabase Edge Functions + `pg_net`/FCM v1 is a follow-up. |
| Programme-wide admin analytics | unchanged (demo data, hidden for live accounts) |
| Task/scheme content editing | unchanged (bundled content) |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Database table missing — run supabase/migrations/0001_init.sql` | Run step 2. |
| `Permission denied. Check the Row Level Security policies.` | You ran the tables but not the RLS section — re-run the whole file; also confirm you're signed in. |
| Sign-up says *"Please confirm your email"* | Turn off email confirmation (step 4) or click the mail link. |
| Google button opens a page and returns with no session | Add the URL to **Authentication → URL Configuration → Redirect URLs**; check the Google Cloud redirect URI matches `https://<ref>.supabase.co/auth/v1/callback`. |
| Points don't move after a task | Check `select * from public.task_logs`; if the row exists but points are 0 you hit the 150/day self cap. |
| Realtime numbers don't update | Database → Replication → make sure `profiles` is in the `supabase_realtime` publication (section 20 does this). |
| Admin portal says "Administrator access is required" | Step 6 (`update profiles set role='admin'`), then reload. |
| App opens in demo mode | `SUPABASE_URL`/`SUPABASE_ANON_KEY` didn't reach the build — run `flutter run --dart-define=...` again; check `SupabaseConfig.isConfigured`. |

## Roll back to Firebase

Nothing was deleted. Run:

```bash
flutter run -d chrome --dart-define=LIFE_BACKEND=firebase
```

`lib/firebase_options.dart`, `firestore.rules`, `functions/` and `PushService`
are unchanged.
