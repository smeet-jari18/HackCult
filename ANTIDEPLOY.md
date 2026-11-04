# Antideploy — LiFE Mitra / HackCult web

**Live:** https://hackcult.antideploy.app
**Admin panel:** https://hackcult.antideploy.app/#/admin/login
**Dashboard:** https://antideploy.com/app/11041026-ffad-4127-9ad3-00642b3b2230
**Antideploy account:** prafullmayanksingh@gmail.com (signs in with Google)
**Application id:** `11041026-ffad-4127-9ad3-00642b3b2230`
**Deployed:** 2026-11-04 · task `4892c332-801a-42ed-8f1b-98e5b3bedede` · 38 files

---

## ⚠️ Read this first: GitHub `main` is broken

The commit `e764d57 "Merge final branch into main"` was committed **with the merge
conflicts still in the files**. `main` does not compile.

- **297 conflict markers across 11 files**, including `lib/data/app_state.dart`
  (147 markers), `lib/features/home/home_screens.dart` (42),
  `lib/features/impact/impact_screens.dart` (39),
  `lib/features/admin/admin_screens.dart` (27), plus `lib/app.dart`,
  `lib/main.dart`, `auth_screens.dart`, `community_screens.dart`,
  `hub_screens.dart`, `gas_screen.dart`, `mock_data.dart`.
- `flutter build web` fails with errors like
  `The getter 'AppScope' isn't defined` and
  `Constructor is marked 'const' so all fields must be final`.
- The `final` branch has since been **deleted from the remote**, so it can no
  longer be fetched as a fallback.

**What was deployed instead:** the verified photo-verification codebase
(the same content that was on `final`). On this source:

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test test/` | 28/28 passed |
| `flutter build web --release` | ✓ Built build/web |

**To fix `main`:** replace its contents with this folder's source and commit.
Do not try to hand-merge the 297 markers — this source is already the intended
result of that merge, and it is tested.

---

## How this deploys

Flutter is **not** a framework Antideploy recognises, so the repo cannot be
built from source there. Instead the **release build output** (`build/web`) is
pushed as a **static site**.

That is the better arrangement anyway:

- Static sites are **unlimited and free on every plan** — they never count
  against live-application, deploy-per-month, or database limits.
- No container, no port to listen on, no cold starts.
- It is the same artefact Firebase Hosting serves.

### Backend was deliberately left alone

The project already uses **Supabase** for auth, Postgres and file storage, and
the `0001`/`0002` migrations are already applied to
`zaljyzpxcnrugmyjlhuc.supabase.co`. So **no** Antideploy database, storage
bucket, sign-in service or email relay was created. Nothing was replaced.

The Supabase URL and publishable key are compiled into the web build from
`lib/data/supabase/supabase_config.dart`. That key is public by design and every
table is behind Row Level Security.

---

## Redeploying

```bash
bash deploy-antideploy.sh
```

That runs `pub get → analyze → test → build web → trim → push → watch`.

### The trim step matters

A full `build/web` is **46 MB**; Antideploy's ceiling is **28 MB** per push.
The build emits renderer variants this app never loads. This build's
`flutter_bootstrap.js` declares exactly one target:

```
builds: [{ compileTarget: dart2js, renderer: canvaskit }]
```

So these are removed before pushing (25.0 MB, 38 files):

| Removed | Why safe |
|---|---|
| `*.symbols` | Debug symbols, never fetched at runtime |
| `skwasm*`, `skwasm_heavy*` | Only used by a `dart2wasm` build |
| `wimp*` | Only used by a `dart2wasm` build |

If you ever build with `--wasm`, **do not** trim those — the loader will need
them, and you will have to split the deploy or host CanvasKit from the CDN.

### Token

Read from `~/.antideploy/config.json` (mode 0600) or `ANTIDEPLOY_TOKEN`.
It is never printed. Revoke any time at https://antideploy.com/tokens.

---

## Admin login still needs the role set

Deploying does not make anyone an admin. The app reads Supabase
`profiles.role`. In the Supabase SQL editor:

```sql
update public.profiles set role = 'admin' where email = 'you@example.com';
select email, role from public.profiles where role = 'admin';
```

Sign up with that email in the app first, or there is no row to update.
Without it, `/#/admin/login` reports *"This account is not a GEDA admin."*

---

## Post-deploy verification (all passed)

| Request | Result |
|---|---|
| `/` | 200, `<title>LiFE Mitra Gujarat</title>` |
| `/main.dart.js` | 200, 4,206,254 bytes |
| `/flutter_bootstrap.js` | 200, 13,091 bytes |
| `/canvaskit/canvaskit.wasm` | 200, 7,284,602 bytes |
| `/assets/AssetManifest.bin.json` | 200 |
| `/.env` | 404 |
| `/.antideploy.json` | 404 |

Antideploy's automatic security scan: **no public-facing issues**, 1 low
("Missing security headers"). Report:
https://antideploy.com/security/scan/5697e217-f1b1-4c59-9424-a218f03749a3

---

## Two deployments now exist

| Host | URL | Source |
|---|---|---|
| Antideploy | https://hackcult.antideploy.app | verified photo-verification code |
| Firebase Hosting | https://green-energy-fb652.web.app | older build (3 Nov) |

Both point at the same Supabase backend, so accounts and data are shared.
Pick one as the demo URL so you are not showing two different versions.
