# Supabase backend — LiFE Mitra Gujarat

Everything the app needs lives in `migrations/0001_init.sql`:

| Firestore (old) | Supabase (new) |
|---|---|
| `users/{uid}` | `profiles` (1 row per auth user) |
| `communities/{id}` + `members/{uid}` | `communities` + `community_members` (+ `community_goal_progress` view) |
| `users/{uid}/taskLogs` | `task_logs` |
| `users/{uid}/footprints` | `footprints` |
| `users/{uid}/pointsLedger` | `points_ledger` |
| `users/{uid}/solarAssessments` | `solar_assessments` |
| `users/{uid}/surveyRequests` | `survey_requests` |
| `leaderboard/{uid}` | `leaderboard` (trigger-maintained) |
| Cloud Functions (`awardTaskPoints`, `awardFootprintPoints`, `syncLeaderboard`, `createUserProfile`, `resetWeeklyPoints`) | Postgres functions + triggers + `pg_cron` |
| Firebase Storage `users/{uid}/bill-proofs` | Storage bucket `bill-proofs` |

## Run order

1. SQL Editor → paste `migrations/0001_init.sql` → Run.
2. Storage → New bucket → `bill-proofs` (private).
3. (Optional) Database → Extensions → enable `pg_cron`, then re-run the
   `do $$ ... $$` block at the end of section 18 to schedule the weekly reset.
4. App: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Make a user an admin

```sql
update public.profiles set role = 'admin' where email = 'you@example.com';
```

RLS is enforced everywhere, so points/streak/badges can only be changed by the
`award_task_points()` / `award_footprint_points()` RPCs — clients cannot edit
their own score (same guarantee as the old Cloud Functions).
