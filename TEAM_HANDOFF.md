# LiFE Mitra Gujarat — Team Handoff (Status + Ready-to-use Prompts)

> Branch analysed: `prafull` (commit `d77b2d2`) · Live web: https://green-energy-fb652.web.app · Firebase project: `green-energy-fb652`
> Order of work: **📱 Mobile app first → 🖥️ Admin web after.**
> Har task ke saath ek **copy-paste prompt** diya hai (Cursor / Copilot Chat / Claude / ChatGPT mein paste karo). Pehle **Section 5.0 Master Context** paste karo, phir task prompt.

---

## 1. Snapshot

| Item | Value |
|---|---|
| Stack | Flutter 3.47+ / Dart 3.13+, go_router, Firebase (Auth, Firestore, Storage, Hosting, Functions-not-deployed) |
| Entry | `lib/main.dart` → `LifeMitraApp(useFirebase: true)`; all data logic in `lib/data/app_state.dart` (1818 lines) |
| Android id | `gov.gujarat.geda.lifemitra` |
| Admin access | Custom claim `admin: true` → `cd functions && npm i && npm run set-admin -- <email>` |
| Commands | `flutter pub get` · `flutter analyze` · `flutter test` · `flutter run` · `flutter build web --release && firebase deploy --only hosting` · `firebase deploy --only firestore:rules,storage,firestore:indexes` |
| Overall progress | **≈ 72 %** (Mobile ≈ 70 %, Admin web ≈ 55 %, Backend/rules ≈ 80 %) |

```
📱 MOBILE                          🖥️ WEB
P1  Foundation        95% ✅       P10 Admin console   55% 🟡
P2  Auth              90% ✅
P3  Footprint         95% ✅
P4  Tasks             70% 🟡
P5  Notifications     35% 🔴
P6  Gamification      30% 🔴
P7  Community         85% 🟡
P8  Solar             90% ✅
P9  Impact            80% 🟡
P11 Release           55% 🟡
```

---

## 2. ✅ What is DONE (verified in source)

| Phase | Done |
|---|---|
| 1 Foundation | `firebase_options.dart`, `Firebase.initializeApp`, `google-services.json`, logo / splash / adaptive icons, theme, go_router with `authChanges` refresh, responsive shell |
| 2 Auth | Email/password sign-in, sign-up, reset via `firebase_auth`; Google Sign-In code (web works); `users/{uid}` auto-create on first login; admin via custom claim; onboarding writes profile + baseline footprint |
| 3 Footprint | Calculators (tested), `footprints/baseline_YYYY-MM` write |
| 4 Tasks | `users/{uid}/taskLogs/{YYYY-MM-DD_taskId}` done / skipped / notApplicable; transaction updates `communities/{id}/members/{uid}.goalContribution`; `notApplicableTaskIds` on user |
| 5 Notifications | Toggles `peakNudge / weatherNudge / communityUpdates / streakReminders` persisted to `users` |
| 6 Gamification | `points / weeklyPoints / streak / longestStreak / badges` **read** from user doc; level/badge UI |
| 7 Community | Create (joinCode, goal fields), join by code, `members` sub-collection, goal progress aggregated |
| 8 Solar | `solarAssessments` write + history; `surveyRequests` lead (phone + slot validated by rules) |
| 9 Impact | `footprints/entry_YYYY-MM` write; charts read from Firestore |
| 10 Admin | Login (claim check), **Solar leads** page live (collectionGroup + index), status update; Hosting deployed |
| 11 Hardening | `firestore.rules` (owner/admin, strict field whitelists), `storage.rules` (≤10 MB images at `users/{uid}/bill-proofs/`), `firestore.indexes.json`, Firestore offline persistence, `BillProofStorage` class, Cloud Functions source (`createUserProfile`, `setUserRole`), 3 test files |

---

## 3. ❌ What is REMAINING (priority order)

### 📱 Mobile (do first) — ≈ 18.5 h

| # | Task | Phase | Why it matters | Est. |
|---|---|---|---|---|
| T1 | **Google Sign-In on Android** — `google-services.json` has empty `oauth_client` → add SHA-1 (debug + release) in Firebase console, re-download | 2 | Login demo on phone fails without it | 0.5 h |
| T2 | **Enable rewards in Firebase mode** — points, weeklyPoints, streak, badges, `pointsLedger`; remove "Online rewards are not enabled yet" | 4, 6 | Core gamification currently dead | 4 h |
| T3 | **Leaderboard from Firestore** (community / district / state × weekly / all-time) | 6, 7 | "Online points rankings are not enabled yet" | 2 h |
| T4 | **Photo proof upload** — add `image_picker`, call existing `BillProofStorage.uploadBillProof()` from bill sheet and photo-task sheet, store `proofPath` | 4, 9 | Verification story for judges | 2.5 h |
| T5 | **Local notifications** — `flutter_local_notifications` + `timezone`, 17:30 daily peak nudge, "Trigger now" button | 5 | Nudge is the PS's main behaviour-change lever | 3 h |
| T6 | **url_launcher + share_plus** — Call / WhatsApp / official site / share card | 7, 8 | Replace 4 placeholder snackbars | 1.5 h |
| T7 | **Clean-up** — remove `Demo: nisha@demo.com` hint, delete stale `kotlin/gov/gujarat/geda/life_mitra/MainActivity.kt`, fix `web/manifest.json`, offline banner | 1, 11 | Polish | 1 h |
| T8 | **Release signing + APK + QR** | 11 | Submission | 1.5 h |
| T9 | **Demo accounts in Firebase** (`nisha@demo.com`, admin) + seeded 45-day history | 11 | Smooth demo | 1.5 h |
| T10 | **Deploy Cloud Functions** (needs Blaze) — optional if T2 uses rules approach | 2, 6 | Trusted writes | 1 h |

### 🖥️ Web + polish (after mobile) — ≈ 12 h

| # | Task | Phase | Est. |
|---|---|---|---|
| T11 | Admin **Overview KPIs** from aggregate `count()` / `sum()` queries + fl_chart | 10 | 3 h |
| T12 | Tasks / vendors / schemes in Firestore + **content CRUD** (admin-only rules) | 10 | 3 h |
| T13 | **Campaigns** — save draft to `campaigns`; optional FCM topic push | 10 | 2 h |
| T14 | `.arb` localisation (en / gu / hi) + demo video + README | 1, 11 | 4 h |

---

## 4. Team split & timeline (3 people, ~1.25 days)

| | Person A — Backend | Person B — Device | Person C — Release / Web |
|---|---|---|---|
| **Day 1 AM** | T1 → T2 | T5 (notifications) | T7 → T9 (demo accounts) |
| **Day 1 PM** | T3 → T10 | T4 (photo upload) → T6 | T8 (signed APK, QR) → T11 start |
| **Day 2 AM** | help T12 rules | T13 | T11 → T12 → T14 |

**Sync points:** T2 done → T4 can award photo bonus · T9 seeded → T3/T11 have data · Rules deploy after T2/T4/T12, then full demo run on phone + Chrome.

---

## 5. Copy-paste prompts

### 5.0 MASTER CONTEXT (paste this first in every new chat)

```
You are helping finish a Flutter + Firebase hackathon app "LiFE Mitra Gujarat" (Mission LiFE citizen app + GEDA admin web).
Repo facts:
- Flutter 3.47 / Dart 3.13, go_router, fl_chart, google_fonts, intl, firebase_core, firebase_auth, cloud_firestore, firebase_storage, cloud_functions, google_sign_in.
- lib/main.dart runs LifeMitraApp(useFirebase: true). ALL data logic lives in lib/data/app_state.dart (class AppState extends ChangeNotifier, field `useFirebase`, getters `_auth`, `_firestore`, `user` (AppUser), `authChanges.bump()`). Mock branch (useFirebase == false) must keep working for tests.
- Models in lib/data/models.dart (AppUser, TaskItem, TaskLog, PointsEntry, BadgeItem, Community, CommunityGoal, Lead, SolarAssessment, LeaderboardEntry). Static content in lib/data/mock_data.dart (MockData.tasks, badges, vendors, schemes, leaderboardNames, districtMetrics).
- Screens: lib/features/{auth,onboarding,home,impact,community,hub,profile,admin}/*_screens.dart. Shared widgets in lib/core/widgets/widgets.dart (SafeBackButton, context.safePop(), PhoneFrame, BrandPill). Theme in lib/core/theme/app_theme.dart. Calculators in lib/core/logic/calculators.dart (FootprintCalculator, SolarCalculator, LevelEngine).
- Firestore layout: users/{uid} (points, weeklyPoints, streak, longestStreak, badges[], district, communityId, peakNudge…), users/{uid}/footprints/{baseline_|entry_YYYY-MM}, users/{uid}/taskLogs/{YYYY-MM-DD_taskId} {taskId,date,status}, users/{uid}/solarAssessments, users/{uid}/surveyRequests, communities/{id} {name,type,district,joinCode,memberCount,goal*}, communities/{id}/members/{uid} {goalContribution}.
- Security: firestore.rules uses strict field whitelists (hasOnly) and request.auth.token.admin == true for admin. storage.rules allows users/{uid}/bill-proofs/* images ≤10 MB. Any new field written by the client MUST be added to the rules whitelist.
- Gamification constants (lib/core/logic + AppConfig): tasks 5–30 pts, photo bonus, daily self-verified cap 150 pts, streak 7/30/100 → 50/250/1000 bonus, solar lead 200 pts, levels Seedling 0 / Sapling 200 / Tree 600 / Grove 1500 / Forest 4000 / Champion 10000.
- Navigation rule: never Navigator.pop with the screen context from inside dialogs (use builder ctx); use context.safePop(); keep authChanges.bump() after auth changes.
Rules for your output: give complete, compilable Dart (null-safe, no TODO stubs), show every file path you change, keep existing UI untouched unless asked, run-through `flutter analyze` mentally (no unused imports), and list the exact firestore.rules / pubspec changes needed. Do not use Riverpod/Bloc — stay with the existing ChangeNotifier AppState.
```

---

### T1 — Google Sign-In on Android (Person A, 0.5 h) — *manual steps, no prompt needed*
1. `cd android && ./gradlew signingReport` → copy **SHA-1** and **SHA-256** of `debug` (and of release keystore after T8).
2. Firebase console → Project settings → Android app `gov.gujarat.geda.lifemitra` → *Add fingerprint* → paste both → **Download `google-services.json`** → replace `android/app/google-services.json` (it must now contain an `oauth_client` entry with `client_type: 1`).
3. Authentication → Sign-in method → Google **Enabled** (support email set).
4. `flutter clean && flutter run` → test Google button on a real phone.

---

### T2 — Enable rewards in Firebase mode (Person A, 4 h)

```
TASK: Enable the gamification write-path when useFirebase == true in lib/data/app_state.dart. Today the Firebase branch of completeTask() returns `TaskCompletion(points: 0, capped: false)` and the UI shows "Task progress saved. Online rewards are not enabled yet." Streak, badges and pointsLedger are only handled in the mock branch (see lines ~1016-1085: points cap, ledger.insert, u.points += …, award('first_step'), etc.).

Implement, keeping the mock branch unchanged:
1. Extract the mock-branch reward math into a pure function `RewardOutcome computeReward({required AppUser u, required TaskItem task, required bool withPhoto, required int pointsTodaySelf, required int tasksDoneToday, required List<TaskLog> taskLogs, required AppConfig config})` returning {points, capped, newBadgeIds, streakIncrement, leveledUpName}. Use it in BOTH branches so logic is identical.
2. Firebase branch of completeTask(): inside the existing runTransaction (or a new one when the user has no community), additionally:
   - users/{uid}: FieldValue.increment(points) on `points` and `weeklyPoints`; set `streak`, `longestStreak`, `lastTaskDate` (Timestamp, day start), `badges` = FieldValue.arrayUnion(newBadgeIds), `updatedAt` serverTimestamp. Streak: +1 only if lastTaskDate is yesterday or today-first-task; reset to 1 if gap > 1 day.
   - users/{uid}/pointsLedger/{auto}: {delta, reason: 'Task · <title>', taskId, createdAt serverTimestamp, icon: task.theme.name}.
   - taskLog doc gets extra fields `pointsAwarded`, `hasProof`.
   - idempotent: if the taskLog already has status 'done' do nothing and return points 0.
3. After the transaction update the in-memory `user` object and `ledger` list so Home/Profile refresh via notifyListeners(). Remove the "Online rewards are not enabled yet" snackbar in lib/features/home/home_screens.dart and show the normal points toast.
4. Load `pointsLedger` (orderBy createdAt desc, limit 50) in `_applyAuthUser` so /profile/points shows history.
5. Weekly reset: on load, if users.weekKey != current ISO week key (yyyy-Www), set weeklyPoints 0 and weekKey.
6. Also award solar-lead points (config.solarLeadPoints, badge 'solar_pioneer_lead') in `_saveSurveyRequest`, community badge 'community_builder' in `_createFirestoreCommunity`, and bill points + 'bill_verified' in addMonth() when a proofPath exists — all through the same ledger/increment helper `_awardPoints(int delta, String reason, {List<String> badges = const []})`.
7. firestore.rules: update users/{uid} `allow update` so the owner may change ONLY these additional keys with validation: points (int, increase ≤ 300 per write), weeklyPoints (int, ≥0, increase ≤ 300 or reset to 0), streak (int ≥0), longestStreak (int ≥0), lastTaskDate (timestamp ≤ request.time), badges (list ≤ 50), weekKey (string). Add `match /pointsLedger/{entryId} { allow read: if isOwner(uid) || isAdmin(); allow create: if isOwner(uid) && keys hasOnly [delta, reason, taskId, createdAt, icon] && delta is int && delta >= -1000 && delta <= 300; allow update, delete: if false; }`. Extend taskLogs whitelist with pointsAwarded (int 0..300) and hasProof (bool). Print the full updated rule blocks.
8. Add a unit test test/reward_test.dart for computeReward (cap at 150, photo bonus, first_step badge).
Output: full modified functions (not diffs) for app_state.dart, new helper file lib/data/rewards.dart, rules blocks, and the exact commands to deploy rules.
```

---

### T3 — Leaderboard from Firestore (Person A, 2 h)

```
TASK: Replace the empty Firebase leaderboard in lib/data/app_state.dart (`leaderboard(String scope, {bool weekly})` currently does `useFirebase ? [] : MockData.leaderboardNames`).
Implement:
1. New async method `Future<List<LeaderboardEntry>> loadLeaderboard(String scope /* 'community'|'district'|'state' */, {bool weekly = false})` that queries the `users` collection: orderBy(weekly ? 'weeklyPoints' : 'points', descending: true).limit(20); for 'district' add where('district', isEqualTo: user.district); for 'community' add where('communityId', isEqualTo: user.communityId). Map to LeaderboardEntry(rank, name = displayName, district, points, isMe = uid == user.uid). If the current user is not in the top 20, append their own entry with rank = '20+' (use rank 21).
2. Cache results per (scope, weekly) in a Map with a 60 s TTL; expose `List<LeaderboardEntry> leaderboard(scope, weekly:)` synchronously from the cache so lib/features/community/community_screens.dart keeps compiling; trigger loadLeaderboard() from the leaderboard widget's initState and on tab change (show a small CircularProgressIndicator while empty). Remove the "Online points rankings are not enabled yet" empty-state text.
3. Security: current rules only allow `read` of users/{uid} by owner/admin, which blocks list queries. Change to: `allow get: if isOwner(uid) || isAdmin(); allow list: if signedIn() && request.query.limit <= 20;` and explain that list results expose displayName/district/points — acceptable for the hackathon leaderboard; note the privacy trade-off in README.
4. firestore.indexes.json: add composite indexes (collectionGroup "users", queryScope COLLECTION) for [district ASC, points DESC], [district ASC, weeklyPoints DESC], [communityId ASC, points DESC], [communityId ASC, weeklyPoints DESC].
5. Also compute community podium (top 3) for the community tab from the same query.
Output full code + rules + index JSON + `firebase deploy --only firestore:indexes,firestore:rules` command.
```

---

### T4 — Photo proof upload (Person B, 2.5 h)

```
TASK: Wire real photo upload. lib/data/bill_proof_storage.dart already has `BillProofStorage.uploadBillProof({required Uint8List bytes, required String contentType}) → Future<String path>` (uploads to users/{uid}/bill-proofs/{id}.{ext}, 10 MB limit, jpeg/png/webp) and AppState exposes `billProofStorage`. storage.rules already allows this path. Nothing calls it yet; photo sheets in the UI are placeholders ("Photo picker (image_picker) opens here").
Implement:
1. pubspec: add image_picker ^1.1.2 and flutter_image_compress ^2.3.0. Android: no extra permission needed for the photo picker on API 33+; add <uses-permission android:name="android.permission.CAMERA"/> and the <queries> block for image capture in android/app/src/main/AndroidManifest.xml. iOS Info.plist: NSCameraUsageDescription, NSPhotoLibraryUsageDescription.
2. New lib/core/services/photo_service.dart: `Future<PickedProof?> pick({required ImageSource source})` → picks, compresses to max 1280 px / quality 80 JPEG (skip compression on web, use bytes directly), returns bytes + contentType 'image/jpeg' + size. Must work on web too (image_picker web returns XFile; read bytes).
3. Replace the placeholder photo sheet in lib/features/home/home_screens.dart (task with Verification.photo) and the bill-photo step in lib/features/impact/impact_screens.dart (add-month flow) with a bottom sheet: Camera / Gallery buttons → preview thumbnail → "Upload" with progress → on success call `appState.completeTask(task, withPhoto: true, proofPath: path)` / `appState.addMonth(..., proofPath: path)`. Show friendly errors (too large, wrong type, offline).
4. AppState: add optional `String? proofPath` params; in Firebase mode write `proofPath` and `hasProof: true` into the taskLog / footprint doc (set `source: 'bill'` for footprints when proofPath != null).
5. firestore.rules: add `proofPath` (string ≤ 200 chars, must start with 'users/' + uid + '/bill-proofs/') and `hasProof` (bool) to the taskLogs and footprints whitelists. Print the updated blocks.
6. Generalise the storage path: rename nothing, but allow `kind` ('bill' | 'task') in the file name, e.g. users/{uid}/bill-proofs/task_{taskId}_{ts}.jpg so rules stay unchanged.
Output complete code for all files touched and the manifest/plist snippets.
```

---

### T5 — Local notifications + 17:30 peak nudge (Person B, 3 h)

```
TASK: Implement real local notifications. Currently lib/features/profile/profile_screens.dart (/profile/notifications) only saves toggles peakNudge/weatherNudge/communityUpdates/streakReminders to Firestore, and the "Trigger peak nudge now" button shows a snackbar.
Implement:
1. pubspec: flutter_local_notifications ^18.0.1, timezone ^0.10.0, flutter_timezone ^3.0.1 (to get local tz; fallback 'Asia/Kolkata').
2. lib/core/services/notification_service.dart (singleton): init() (Android channel id 'nudges' name 'Peak-hour nudges' importance high, channel 'general'; iOS/macOS permission request; Android 13+ POST_NOTIFICATIONS runtime permission via requestNotificationsPermission()), schedulePeakNudge({required bool enabled}) → zonedSchedule id 1001 daily at 17:30 local with matchDateTimeComponents: DateTimeComponents.time, title "Peak hour starts at 6 PM ⚡", body "Shift washing machine / geyser to after 10 PM and earn 20 points", payload '/home'; cancelPeakNudge(); showNow(title, body, payload); scheduleStreakReminder at 20:30 when streakReminders is on and no task done today (id 1002); onTap → GoRouter go(payload). Guard every call with `if (kIsWeb) return;` (web: show a SnackBar instead) so the web build keeps compiling.
3. Call NotificationService.instance.init() in main.dart after Firebase init; after sign-in / onboarding complete, call schedulePeakNudge(enabled: user.peakNudge). When the toggle changes in /profile/notifications, re-schedule/cancel. Wire "Trigger peak nudge now" to showNow(...). Add a "Test in 10 seconds" debug button only in kDebugMode.
4. AndroidManifest: add RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, POST_NOTIFICATIONS permissions and the ScheduledNotificationBootReceiver / ScheduledNotificationReceiver receivers required by flutter_local_notifications v18; enable core library desugaring in android/app/build.gradle.kts (isCoreLibraryDesugaringEnabled = true, coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")). Use a white 24dp status-bar icon @drawable/ic_stat_leaf (describe how to generate it from assets/images/logo.png or use @mipmap/ic_launcher as fallback).
5. Log each nudge interaction locally (list in AppState: nudgeHistory with time + action) so the Notifications screen can show "Last nudge: today 17:30 — Done".
Output: complete service file, all edits (main.dart, profile_screens.dart, app.dart router hook, manifest, gradle), and a manual test checklist (set phone time to 17:29, etc.).
```

---

### T6 — url_launcher + share_plus (Person B, 1.5 h)

```
TASK: Replace placeholder snackbars with real actions.
Placeholders: lib/features/hub/hub_screens.dart line ~342 'Calling ${vendor.phone}…', ~593 'Estimate PDF shared (demo)', community share card snackbar 'Share sheet would open here (share_plus)' in lib/features/community/community_screens.dart, and any 'Open official site' button for PM Surya Ghar.
Implement:
1. pubspec: url_launcher ^6.3.1, share_plus ^10.1.2, screenshot ^3.0.0 (for share card image).
2. lib/core/services/link_service.dart: call(phone) → tel:, whatsapp(phone, text) → https://wa.me/91XXXXXXXXXX?text=…, openWeb(url) → launchUrl(mode: LaunchMode.externalApplication); official links: https://pmsuryaghar.gov.in , https://geda.gujarat.gov.in . Normalise Indian numbers (strip spaces, +91). Show a SnackBar if canLaunchUrl is false. Android manifest <queries> for tel, https, whatsapp intents.
3. Share: community card and impact summary → wrap the existing card widget in a Screenshot controller, capture at pixelRatio 2, save to temp file (path_provider) and Share.shareXFiles([XFile(path)], text: 'I saved 42 units with LiFE Mitra Gujarat 🌱 Join: <joinCode>'). On web fall back to Share.share(text) only.
4. Solar estimate "share": share plain text with size, net cost, subsidy numbers.
Output complete code and the exact lines replaced.
```

---

### T7 — Clean-up (Person C, 1 h)

```
TASK: Polish items, no behaviour change:
1. lib/features/auth/auth_screens.dart ~line 380: remove the 'Demo: nisha@demo.com / Demo@1234' hint widget when AppScope.of(context).useFirebase is true (keep it in mock mode for tests).
2. Delete the stale duplicate android/app/src/main/kotlin/gov/gujarat/geda/life_mitra/MainActivity.kt (correct one is .../lifemitra/MainActivity.kt, package gov.gujarat.geda.lifemitra).
3. web/manifest.json: name 'LiFE Mitra Gujarat', short_name 'LiFE Mitra', description 'Mission LiFE citizen app by GEDA — track, save and earn for a greener Gujarat', theme_color '#1B5E20', background_color '#F1FCF4', display standalone.
4. Offline banner: add connectivity_plus ^6.1.0; in lib/app.dart listen to onConnectivityChanged and show the existing OfflineBanner widget (lib/core/widgets/widgets.dart) at the top of MainShell when offline; hide when back online. Web-safe.
5. Update README.md "Hackathon details" with team name/members placeholder table and the feature↔requirement matrix skeleton.
Output exact edits.
```

---

### T8 — Release signing + APK + QR (Person C, 1.5 h)

```
TASK: Produce a signed release APK.
1. Generate keystore: keytool -genkey -v -keystore ~/life-mitra-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lifemitra
2. android/key.properties (git-ignored already): storePassword, keyPassword, keyAlias=lifemitra, storeFile=/absolute/path/life-mitra-release.jks
3. android/app/build.gradle.kts: load key.properties, add signingConfigs.create("release"), set buildTypes.release.signingConfig = signingConfigs.getByName("release"), isMinifyEnabled = true, isShrinkResources = true, proguard-rules.pro with keep rules for Firebase/Flutter; versionCode 2, versionName "1.0.1".
4. Run `./gradlew signingReport`, add the RELEASE SHA-1/SHA-256 to Firebase (see T1), re-download google-services.json.
5. flutter build apk --release --split-per-abi (or single: flutter build apk --release); output in build/app/outputs/flutter-apk/.
6. Upload APK as a GitHub Release asset; generate QR codes (python: `pip install qrcode[pil]`; qrcode.make(url).save('qr_apk.png')) for the APK URL and https://green-energy-fb652.web.app; add both to README.
Give me the exact Kotlin DSL gradle code and the proguard rules.
```

---

### T9 — Demo accounts + seeded history (Person C, 1.5 h)

```
TASK: Create realistic demo data in Firebase project green-energy-fb652 so the judge demo is not empty.
Write a Node script functions/scripts/seed-demo.cjs (firebase-admin, run with GOOGLE_APPLICATION_CREDENTIALS or `firebase login` ADC):
1. Auth users: nisha@demo.com / Demo@1234 (displayName 'Nisha Patel'), ravi@demo.com / Demo@1234, admin@geda.demo / Admin@1234 (set custom claim admin:true and users.role 'admin').
2. users/{nisha}: onboardingComplete true, district 'Ahmedabad', pincode '380015', householdSize 4, homeType 'flat', roofAccess 'shared', baselineUnits 250, baselineCo2Kg 177.5, goalPercent 10, points 1240, weeklyPoints 180, streak 5, longestStreak 12, badges ['first_step','peak_shifter','bill_verified','streak_7'], communityId <c1>, weekKey current.
3. 45 days of users/{nisha}/taskLogs (ids YYYY-MM-DD_taskId, status 'done', pointsAwarded 10-30, date Timestamp at day start, random 2-3 tasks/day from ids: load_shift_wm, led_swap, ac_26, cycle_short_trip, bucket_bath, lpg_simmer) and matching pointsLedger entries; 3 monthly footprints (baseline_2026-08, entry_2026-09, entry_2026-10 with unitsSaved 18/27, source 'bill', pointsAwarded 36/54).
4. communities: c1 'Shanti Nagar Society' (Society, Ahmedabad, 380015, joinCode 'SHANTI1', memberCount 24, goalTitle 'Save 100 units this month', goalMetric 'units', goalTarget 100, goalEndDate end of month) with 24 members docs (fake uids ok) summing goalContribution ≈ 62; c2 'Kalali Village' (Village, Vadodara); c3 'Kendriya Vidyalaya Gandhinagar' (School).
5. 20 extra users docs across districts (Ahmedabad, Surat, Vadodara, Rajkot, Gandhinagar) with points 200-3000 for the leaderboard.
6. 12 surveyRequests under various users (status new/contacted/survey_done/quoted/installed) for the admin leads page.
Use batched writes (≤500 per batch), serverTimestamp for createdAt, and make the script idempotent (set with merge). Print run instructions.
```

---

### T10 — Deploy Cloud Functions (Person A, 1 h) — *manual*
1. Upgrade project to **Blaze** (free tier is enough). 2. `cd functions && npm i && npm run build` 3. `firebase deploy --only functions` (region asia-south1). 4. Verify `createUserProfile` trigger by creating a new user. If Blaze is not possible, skip — client-side profile creation already works.

---

### T11 — Admin Overview KPIs (Person C, 3 h)

```
TASK: Replace the `_LiveAdminUnavailable('Live programme reporting is not connected')` branch in AdminOverviewScreen (lib/features/admin/admin_screens.dart ~line 932) with real aggregates when useFirebase == true. Keep the mock branch for tests.
Implement AdminRepository in lib/data/admin_repository.dart using Firestore aggregate queries (cloud_firestore ≥5 supports count()/sum()/average()):
- totalCitizens = users.count(); activeToday = users.where('lastTaskDate', >= today).count(); onboarded = users.where('onboardingComplete', ==, true).count()
- totalPoints = users.aggregate(sum('points')); unitsSaved = collectionGroup('footprints').where('isBaseline', ==, false).aggregate(sum('unitsSaved')); co2 = unitsSaved * 0.71 kg
- leads by status: 6 count() queries on collectionGroup('surveyRequests')
- per-district table: for the 8 main districts run users.where('district', ==, d).count() and sum('points') in parallel (Future.wait)
- communities: count() + sum('memberCount')
- monthly trend: collectionGroup('footprints').where('month', >=, 6 months ago).get() → group by month → unitsSaved (limit 2000 docs, fine for hackathon).
UI: reuse the existing KPI tile / fl_chart widgets of the mock branch (same look), add a refresh button and a 'Last updated' label, show shimmer while loading, graceful error card on PERMISSION_DENIED.
Rules: admins already have `read` on users/footprints/surveyRequests; add `allow list` for collectionGroup footprints: `match /{path=**}/footprints/{id} { allow read: if isAdmin(); }`. Add indexes if Firestore errors ask for them (print the collectionGroup field overrides for footprints.month and footprints.isBaseline).
Output full repository + modified screen code + rules.
```

---

### T12 — Content CRUD (Person C, 3 h)

```
TASK: Move static content to Firestore and enable admin editing. Currently tasks/vendors/schemes come from lib/data/mock_data.dart and AdminContentScreen shows `_LiveAdminUnavailable('Live task and scheme editing is not connected')`.
Implement:
1. Collections: tasks/{taskId}, vendors/{id}, schemes/{id} with fields matching TaskItem / Vendor / Scheme models (+ isActive bool, order int, updatedAt, updatedBy). Add toMap()/fromMap() to the models.
2. AppState: on start (Firebase mode) load tasks/vendors/schemes where isActive == true ordered by order; fall back to MockData if the collection is empty so the app never looks blank. Expose `List<TaskItem> get tasks` and use it everywhere MockData.tasks was used in lib/features (list those places).
3. One-time "Seed from bundled content" button in AdminContentScreen (admin only) that batch-writes MockData.tasks/vendors/schemes to Firestore.
4. AdminContentScreen (Firebase branch): tabs Tasks / Vendors / Schemes; table with inline edit dialog (title, points, theme, verification, estUnitsSaved, estCo2Kg, isActive, order), add/duplicate/deactivate (no hard delete).
5. firestore.rules: `match /tasks/{id} { allow read: if signedIn(); allow write: if isAdmin(); }` same for vendors, schemes.
6. Replace the hard-coded SunGujarat vendor constant in lib/features/hub/hub_screens.dart with vendors from AppState filtered by district.
Output complete code and rules.
```

---

### T13 — Campaigns draft (Person B, 2 h)

```
TASK: Make AdminCampaignsScreen (`_LiveAdminUnavailable('Campaign delivery is not configured')`) functional at draft level.
1. campaigns/{id}: {title, body, audience: 'all'|'district:<name>'|'community:<id>', scheduledAt, status: 'draft'|'scheduled'|'sent', createdBy, createdAt, sentCount}. Rules: admin only read/write.
2. UI: form (title, body ≤ 140 chars, audience dropdown fed from districts list and communities collection, schedule date-time), list of campaigns with status chips, 'Send now' sets status 'sent' + sentAt.
3. Citizen side: on Home load, query campaigns where status == 'sent' and audience in ['all', 'district:<myDistrict>', 'community:<myCommunityId>'] orderBy sentAt desc limit 3 → show as in-app nudge cards (dismissible, dismissed ids stored locally). Rules: `allow read: if signedIn() && resource.data.status == 'sent'` for citizens.
4. Optional (if firebase_messaging is added later): note the topic names all / district_<slug> / community_<id> so a Cloud Function can push.
Output complete code and rules.
```

---

### T14 — Localisation + video + README (Person C, 4 h)

```
TASK: Add proper localisation with flutter_localizations + intl .arb files.
1. l10n.yaml (arb-dir lib/l10n, template app_en.arb, output AppLocalizations), pubspec `generate: true`, flutter_localizations sdk.
2. Create lib/l10n/app_en.arb, app_gu.arb, app_hi.arb with keys for all P0 screens: splash, login/signup (title, subtitle, email, password, forgot, google, create account), onboarding steps, home (greeting, today's tasks, points, streak, peak banner), task sheet (done/skip/not applicable), impact (units saved, CO2, rupees), community (join, create, leaderboard), solar (estimate, subsidy, net cost, request survey), profile (settings, language, notifications, sign out). Provide real Gujarati and Hindi translations (not transliterations). Keep numbers with intl NumberFormat('en_IN').
3. Wire MaterialApp.router localizationsDelegates/supportedLocales [en, gu, hi]; the existing language switcher (users.language) sets a ValueNotifier<Locale> in AppState; persist choice.
4. Replace inline ternaries like `g == 'gu' ? '…' : 'Welcome back'` in auth_screens.dart and profile_screens.dart with AppLocalizations.of(context)!.key. List every string you replaced.
5. Add test/l10n_test.dart asserting all three arb files have identical key sets.
Also draft: (a) a 2–3 minute demo video script (scene list with what to click, 20–25 s each: login → onboarding → footprint → task done with photo → points/leaderboard → solar estimate → survey request → admin leads/overview), (b) README sections: feature ↔ problem-statement requirement matrix, architecture diagram (mermaid), setup, demo accounts, known limitations.
```

---

## 6. Definition of done / demo checklist

- [ ] Phone: Google + email login works; onboarding → Home shows real baseline.
- [ ] Task done → points toast → Profile points history → leaderboard rank changes (no "not enabled" text anywhere).
- [ ] Photo task / bill photo uploads; file visible in Storage; `proofPath` in Firestore.
- [ ] 17:30 nudge fires on phone; "Trigger now" works; toggles persist.
- [ ] Call / WhatsApp / official site / share buttons open real apps.
- [ ] Solar estimate saved; survey request appears in admin leads within seconds.
- [ ] Admin Overview shows real counts; content editing works; campaign card appears on citizen Home.
- [ ] `flutter analyze` 0 issues; `flutter test` green; rules deployed (anonymous REST read → 403).
- [ ] Signed APK + QR, web URL, demo accounts, README matrix, video submitted.


## Update (v2 de-clutter, Nov 2026)
- Larger type scale (body 15, captions 13), card padding 18, page gutters 20.
- Single header per screen; Home brand bar subtitle = district · Citizen.
- Android/gesture back: any tab → Home → exit (PopScope in `MainShell`); pushed pages pop normally. Covered by `test/flow_test.dart`.
- Google Sign-In hardened (popup on web, native picker → provider-flow fallback on mobile, readable errors). **Console setup still required** → see `GOOGLE_SIGNIN_SETUP.md`.

## Update (v3 redesign — DESIGN-3 / Stitch screens, 2 Nov 2026)

- Whole citizen app re-skinned to the 14 new Stitch screenshots + `DESIGN-3.md` tokens (canvas `#F7FAF7`, Deep Banyan `#1B5E20`, Emerald `#2E9E4F`, Amber `#F5A623`, Plus Jakarta Sans, 20 px cards, pill buttons).
- **Plus Jakarta Sans now ships offline** in `assets/fonts/` (OFL) — no runtime font fetch needed.
- New shared widgets: `lib/core/widgets/v3.dart` (Eyebrow, SoftChip, IconBubble, MetricTile, SettingsRow, GroupCard, CapsuleBar, RingGauge, TrendLineChart, DemandBars, LegalSection, Callout, MistBackground).
- New screens/routes: `/tasks/:id` (Task Details), `/legal/privacy`, `/legal/terms` (public — reachable from Sign-up & Profile). `/tasks` is now a pushed page (Home → History) with a back button.
- Bottom nav: **Home · Impact · Community · Hub · Profile**.
- Login keeps the compact **Citizen / Admin (GEDA)** pill; Forgot password = email reset link (no OTP).
- Verified: `flutter analyze` clean, `flutter test test/` 17/17, screenshot harness 32 shots with 0 overflows (`tool/screenshots/shots_test.dart`).
- Still pending for the team: `flutter build web --release && firebase deploy --only hosting` (deployed site is the 29-Oct build), Android SHA-1 for Google Sign-In (see `GOOGLE_SIGNIN_SETUP.md`), real url_launcher for helpline/PDF buttons, Gujarati strings.

## Update (backend + notifications wired, 2 Nov 2026)

- **Local reminders** (flutter_local_notifications + timezone): 17:30 peak nudge, 20:30 streak, 1st-of-month bill — `lib/core/services/notification_service.dart`, toggled from Profile / Notifications; Home "Set reminder" schedules it; test button in Notifications screen.
- **FCM push** (`firebase_messaging`): token → `users/{uid}.fcmToken`, topics `all_citizens` / `district_*` / `community_*` / `peak_nudge`; foreground shown via local channel — `lib/core/services/push_service.dart`. Admin → Campaigns now really sends via `sendCampaign` Cloud Function (incl. "Send test to me").
- **Cloud Functions added** (`functions/src/index.ts`, compiles with `tsc`): `awardTaskPoints`, `awardFootprintPoints`, `syncLeaderboard`, `resetWeeklyPoints`, `sendCampaign`, `dailyPeakNudge`. Points / streak / badges in Firebase mode are now server-authoritative; app listens to `users/{uid}` live and loads `pointsLedger`.
- **Online leaderboard**: `leaderboard` collection (public projection) + composite indexes; Community screen loads it per scope.
- **url_launcher**: helpline call (Hub + Profile), vendor call, scheme official links, "Email me this estimate" on solar result.
- Rules/indexes updated (`firestore.rules`, `firestore.indexes.json`); Android manifest + Gradle (desugaring, minSdk 23, permissions, receivers, FCM meta-data); `web/firebase-messaging-sw.js`.
- Full deploy order in **`BACKEND_SETUP.md`**. Verified: analyze clean, 17/17 tests, 32 screenshots 0 overflow.
