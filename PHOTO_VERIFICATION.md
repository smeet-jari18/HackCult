# Photo / Bill Proof Verification — Setup

Real camera + gallery capture, upload to Supabase Storage, and **server-side
verification** before any bonus points are awarded.

## Kya naya hai

| Pehle | Ab |
|---|---|
| "Photo verification is not available for online accounts yet" | Real camera/gallery picker |
| Bill photo sirf ek dummy toggle tha | Actual photo attach + preview + upload |
| `has_proof` client jo bole woh | DB `storage.objects` mein file exist check karta hai |
| +50 bill bonus bina proof ke mil sakta tha | Bonus sirf verified upload par |
| Points client jitna bheje utna | Per-task hard cap 100 pts |

## Setup (5 minute)

### 1. SQL migration chalao

Supabase Dashboard → **SQL Editor → New query** → `supabase/migrations/0002_photo_proofs.sql`
ka pura content paste → **Run**.

> Order: `0001_init.sql` → `supabase-security-fix.sql` → `0002_photo_proofs.sql`

Yeh karta hai:
- `task_logs.proof_path` + `footprints.proof_path` columns
- `verify_proof_path()` — path apne folder mein hai + file really uploaded
- `award_task_points()` naya signature (`p_proof_path`) — photo task bina proof ke **fail**
- `award_footprint_points()` — +50 bonus sirf verified bill par
- `admin_task_proofs()` — admin moderation list
- Admin ko `bill-proofs` bucket read access

### 2. App chalao

```bash
flutter pub get
flutter run
```

`image_picker` package add ho gaya hai. Android permissions (`CAMERA`,
`READ_MEDIA_IMAGES`) aur iOS usage descriptions manifest mein add hain.

### 3. Test karo

**Task photo proof:**
1. Koi photo-verification task kholo (e.g. "Swap 3 bulbs to LED")
2. **Complete task** → camera/gallery sheet khulega
3. Photo lo → preview dikhega → **Complete task**
4. "Uploading proof…" → phir points credit
5. DB check:
   ```sql
   select task_id, has_proof, proof_path, points_awarded
   from task_logs order by id desc limit 5;
   ```

**Bill proof:**
1. Impact → **Add month**
2. Units daalo → **Add bill photo** → photo lo
3. **Save entry** → upload + points
4. DB check:
   ```sql
   select month, source, proof_path, points_awarded
   from footprints where not is_baseline order by id desc limit 5;
   ```

## Security — client jhooth nahi bol sakta

```sql
-- Photo task bina proof → error
select public.award_task_points('led_swap', 30, 'photo');
-- ERROR: A photo proof is required for this task.

-- Fake path → error
select public.award_task_points('led_swap', 30, 'photo',
                                p_proof_path => 'someone-else-uid/x.jpg');
-- ERROR: Proof photo not found. Please upload the photo again.
```

`verify_proof_path()` teen cheezein check karta hai:
1. Path `<your-uid>/...` se shuru hota hai
2. `..` path traversal nahi hai
3. `storage.objects` mein woh file **actually exist** karti hai

Iske alawa per-task 100-point hard cap hai, taaki tampered client 9999 points
na bhej sake.

## Admin moderation

```sql
select * from public.admin_task_proofs(50);
```

Ya app se:
```dart
final rows = await SupabaseConfig.client.rpc('admin_task_proofs', params: {'p_limit': 50});
```

Photo dekhne ke liye signed URL:
```dart
final url = await supabaseRepo.proofSignedUrl(row['proof_path']);
```

## Files changed

| File | Change |
|---|---|
| `supabase/migrations/0002_photo_proofs.sql` | **new** — columns, verification, RPCs |
| `lib/core/services/proof_picker.dart` | **new** — camera/gallery capture + validation |
| `lib/core/widgets/proof_picker_sheet.dart` | **new** — reusable picker sheet with preview |
| `lib/data/supabase/supabase_repo.dart` | `proofPath` params, upload returns path, `proofSignedUrl()` |
| `lib/data/app_state.dart` | `completeTask(proofPath:)`, `addMonth(proofPath:)` |
| `lib/features/home/home_screens.dart` | Real picker + upload in `completeTaskFlow` |
| `lib/features/impact/impact_screens.dart` | Real bill picker + preview in Add month |
| `android/app/src/main/AndroidManifest.xml` | Camera + media permissions |
| `ios/Runner/Info.plist` | Camera + photo library usage strings |
| `pubspec.yaml` | `image_picker: ^1.1.2` |
| `test/proof_picker_test.dart` | **new** — 4 tests |

## Validation

```bash
flutter analyze     # No issues found
flutter test test/  # 28/28 passed
```

## Note

Firebase mode (`--dart-define=LIFE_BACKEND=firebase`) mein photo proof abhi
bhi purane behaviour par hai — verification sirf Supabase mode mein
server-side enforce hoti hai. Demo mode mein photo attach hota hai par upload
nahi (offline demo ke liye).
