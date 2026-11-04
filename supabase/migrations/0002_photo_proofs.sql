-- ============================================================================
-- LiFE Mitra — 0002: real photo / bill proof verification
-- ============================================================================
-- Run AFTER 0001_init.sql and after supabase-security-fix.sql.
-- Supabase Dashboard → SQL Editor → New query → paste → Run.
-- Idempotent: safe to re-run.
--
-- Kya karta hai:
--   1. task_logs + footprints mein `proof_path` column
--   2. award_task_points() ab photo tasks ke liye REAL uploaded file maangta
--      hai (storage.objects mein exist karni chahiye, apne hi folder mein)
--   3. award_footprint_points() +50 bill bonus sirf tab jab proof uploaded ho
--   4. Client jhooth bol kar points nahi badha sakta (per-task hard cap)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Columns
-- ---------------------------------------------------------------------------
alter table public.task_logs
  add column if not exists proof_path text;

alter table public.footprints
  add column if not exists proof_path text;

comment on column public.task_logs.proof_path is
  'Storage object path in bucket bill-proofs: <uid>/<file>. Server-verified.';
comment on column public.footprints.proof_path is
  'Storage object path in bucket bill-proofs: <uid>/<file>. Server-verified.';

-- ---------------------------------------------------------------------------
-- 2. Storage bucket (bill-proofs already 0001 mein bana hai) — ensure exists
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('bill-proofs', 'bill-proofs', false)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 3. Helper: proof path valid + file actually uploaded?
-- ---------------------------------------------------------------------------
create or replace function public.verify_proof_path(p_path text, p_uid uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if p_path is null or btrim(p_path) = '' then
    return false;
  end if;
  -- Path must live inside the caller's own folder: <uid>/....
  if split_part(p_path, '/', 1) <> p_uid::text then
    return false;
  end if;
  -- No path traversal
  if p_path like '%..%' then
    return false;
  end if;
  -- The object must really exist in Storage (client cannot fake this).
  return exists (
    select 1 from storage.objects
    where bucket_id = 'bill-proofs' and name = p_path
  );
end;
$$;

revoke execute on function public.verify_proof_path(text, uuid) from public, anon;

-- ---------------------------------------------------------------------------
-- 4. award_task_points — new signature with p_proof_path
-- ---------------------------------------------------------------------------
-- Purana 6-arg version drop karna zaroori hai, warna Postgres do overload
-- bana dega aur PostgREST confuse ho jayega.
drop function if exists public.award_task_points(text, int, text, double precision, double precision, boolean);

create or replace function public.award_task_points(
  p_task_id      text,
  p_points       int,
  p_verification text default 'self',
  p_est_units    double precision default 0,
  p_est_co2      double precision default 0,
  p_with_photo   boolean default false,
  p_proof_path   text default null
)
returns table (
  points_awarded int,
  capped         boolean,
  total_points   int,
  streak         int,
  new_badges     text[],
  leveled_up     text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid          uuid := auth.uid();
  v_today        date := (now() at time zone 'Asia/Kolkata')::date;
  v_profile      public.profiles;
  v_self_today   int;
  v_tasks_today  int;
  v_points       int;
  v_capped       boolean := false;
  v_streak       int;
  v_longest      int;
  v_badges       text[];
  v_total        int;
  v_new_level    text;
  v_old_level    text;
  v_verification text := coalesce(p_verification, 'self');
  v_has_proof    boolean := false;
  v_proof_path   text := nullif(btrim(coalesce(p_proof_path, '')), '');
  v_contribution double precision := 0;
  v_goal         public.communities;
  v_existing     public.task_logs;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;
  if p_task_id is null or p_task_id = '' then
    raise exception 'task id required';
  end if;

  -- ---- PROOF VERIFICATION (server-side, cannot be spoofed) ----
  if v_proof_path is not null then
    if not public.verify_proof_path(v_proof_path, v_uid) then
      raise exception 'Proof photo not found. Please upload the photo again.';
    end if;
    v_has_proof := true;
  end if;

  -- A "photo" task is only accepted with a real uploaded proof.
  if v_verification = 'photo' and not v_has_proof then
    raise exception 'A photo proof is required for this task.';
  end if;

  select * into v_profile from public.profiles where id = v_uid for update;
  if not found then
    raise exception 'profile missing';
  end if;

  -- Idempotency: already done today → no double award.
  select * into v_existing from public.task_logs
   where user_id = v_uid and task_id = p_task_id and log_date = v_today;
  if found and v_existing.status = 'done' then
    return query select 0, false, v_profile.points, v_profile.streak,
                        v_profile.badges, null::text;
    return;
  end if;

  -- Daily counters reset at midnight IST
  if v_profile.daily_day is distinct from v_today then
    v_self_today := 0;
    v_tasks_today := 0;
  else
    v_self_today := coalesce(v_profile.daily_self_points, 0);
    v_tasks_today := coalesce(v_profile.daily_tasks_done, 0);
  end if;

  v_points := greatest(0, coalesce(p_points, 0));

  -- Hard per-task cap so a tampered client cannot inflate points.
  -- Sabse bada genuine task 50 pts (upload_bill) + 5 photo bonus = 55.
  if v_points > 100 then
    v_points := 100;
    v_capped := true;
  end if;

  -- Photo bonus sirf tab jab proof actually uploaded ho.
  if not v_has_proof and v_verification <> 'self' then
    v_points := least(v_points, 50);
  end if;

  if v_verification = 'self' then
    declare
      v_remaining int := greatest(0, 150 - v_self_today);
    begin
      if v_points > v_remaining then
        v_points := v_remaining;
        v_capped := true;
      end if;
    end;
  end if;

  -- Streak: the first completed task of the day extends it.
  v_streak := coalesce(v_profile.streak, 0);
  v_longest := coalesce(v_profile.longest_streak, 0);
  if v_tasks_today = 0 then
    if v_profile.last_task_day = v_today - 1 then
      v_streak := v_streak + 1;
    elsif v_profile.last_task_day = v_today then
      v_streak := v_streak;
    else
      v_streak := 1;
    end if;
    v_longest := greatest(v_longest, v_streak);
  end if;

  -- Badges
  v_badges := coalesce(v_profile.badges, '{}');
  if coalesce(v_profile.total_tasks_done, 0) + 1 = 1
     and not ('first_step' = any (v_badges)) then
    v_badges := v_badges || 'first_step';
  end if;
  if p_task_id = 'load_shift_wm' and not ('peak_shifter' = any (v_badges)) then
    v_badges := v_badges || 'peak_shifter';
  end if;
  if p_task_id = 'led_swap' and not ('led_legend' = any (v_badges)) then
    v_badges := v_badges || 'led_legend';
  end if;
  if v_streak >= 7 and not ('streak_7' = any (v_badges)) then
    v_badges := v_badges || 'streak_7';
  end if;
  if v_streak >= 30 and not ('streak_30' = any (v_badges)) then
    v_badges := v_badges || 'streak_30';
  end if;

  v_old_level := public.level_for(v_profile.points);
  v_total := coalesce(v_profile.points, 0) + v_points;
  v_new_level := public.level_for(v_total);

  -- Write task log (unique per day/task)
  insert into public.task_logs
    (user_id, task_id, log_date, status, points_awarded, has_proof, proof_path)
  values
    (v_uid, p_task_id, v_today, 'done', v_points, v_has_proof, v_proof_path)
  on conflict (user_id, task_id, log_date) do update
    set status = 'done',
        points_awarded = excluded.points_awarded,
        has_proof = excluded.has_proof,
        proof_path = coalesce(excluded.proof_path, public.task_logs.proof_path);

  -- Community goal contribution
  if v_profile.community_id is not null then
    select * into v_goal from public.communities where id = v_profile.community_id;
    if found then
      v_contribution := case v_goal.goal_metric
        when 'tasks' then 1
        when 'units' then coalesce(p_est_units, 0)
        else coalesce(p_est_co2, 0)
      end;
      if v_contribution > 0 then
        insert into public.community_members (community_id, user_id, goal_contribution)
        values (v_profile.community_id, v_uid, v_contribution)
        on conflict (community_id, user_id) do update
          set goal_contribution = least(v_goal.goal_target,
                                        public.community_members.goal_contribution + excluded.goal_contribution),
              updated_at = now();
      end if;
    end if;
  end if;

  -- Update profile (definer → guard trigger allows it)
  update public.profiles set
    points            = v_total,
    weekly_points     = coalesce(weekly_points, 0) + v_points,
    streak            = v_streak,
    longest_streak    = v_longest,
    badges            = v_badges,
    last_task_day     = v_today,
    total_tasks_done  = coalesce(total_tasks_done, 0) + 1,
    daily_day         = v_today,
    daily_self_points = v_self_today + (case when v_verification = 'self' then v_points else 0 end),
    daily_tasks_done  = v_tasks_today + 1,
    total_units_saved = coalesce(total_units_saved, 0) + coalesce(p_est_units, 0),
    updated_at        = now()
  where id = v_uid;

  insert into public.points_ledger (user_id, delta, reason, task_id)
  values (v_uid, v_points, 'Task · ' || p_task_id, p_task_id);

  return query select v_points, v_capped, v_total, v_streak, v_badges,
                      case when v_new_level <> v_old_level then v_new_level else null end;
end;
$$;

revoke execute on function
  public.award_task_points(text, int, text, double precision, double precision, boolean, text)
  from public, anon;
grant execute on function
  public.award_task_points(text, int, text, double precision, double precision, boolean, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 5. award_footprint_points — +50 bonus only with a real uploaded bill proof
-- ---------------------------------------------------------------------------
create or replace function public.award_footprint_points(p_footprint_id bigint)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_row      public.footprints;
  v_points   int;
  v_badges   text[];
  v_profile  public.profiles;
  v_verified boolean := false;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  select * into v_row from public.footprints
   where id = p_footprint_id and user_id = v_uid for update;
  if not found then raise exception 'footprint not found'; end if;
  if v_row.is_baseline or v_row.points_awarded > 0 then return 0; end if;

  -- Bill bonus + badge sirf jab proof file actually upload hui ho.
  v_verified := v_row.source = 'bill'
                and public.verify_proof_path(v_row.proof_path, v_uid);

  v_points := round(greatest(v_row.units_saved, 0) * 2)
              + case when v_verified then 50 else 0 end;
  if v_points <= 0 then return 0; end if;

  select * into v_profile from public.profiles where id = v_uid for update;
  v_badges := coalesce(v_profile.badges, '{}');
  if v_verified and not ('bill_verified' = any (v_badges)) then
    v_badges := v_badges || 'bill_verified';
  end if;

  update public.footprints set points_awarded = v_points where id = v_row.id;
  update public.profiles set
    points            = coalesce(points, 0) + v_points,
    weekly_points     = coalesce(weekly_points, 0) + v_points,
    badges            = v_badges,
    total_units_saved = coalesce(total_units_saved, 0) + greatest(v_row.units_saved, 0),
    updated_at        = now()
  where id = v_uid;

  insert into public.points_ledger (user_id, delta, reason)
  values (v_uid, v_points,
          case when v_verified then 'Bill verified · units saved'
               else 'Monthly entry · units saved' end);

  return v_points;
end;
$$;

revoke execute on function public.award_footprint_points(bigint) from public, anon;
grant execute on function public.award_footprint_points(bigint) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Admin: proof dekhne ke liye signed URL (server-side, admin only)
-- ---------------------------------------------------------------------------
create or replace function public.admin_task_proofs(p_limit int default 100)
returns table (
  log_id      bigint,
  user_id     uuid,
  citizen     text,
  task_id     text,
  log_date    date,
  proof_path  text,
  points      int
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access is required.';
  end if;
  return query
    select l.id, l.user_id, p.display_name, l.task_id, l.log_date,
           l.proof_path, l.points_awarded
    from public.task_logs l
    join public.profiles p on p.id = l.user_id
    where l.proof_path is not null
    order by l.log_date desc, l.id desc
    limit greatest(1, least(p_limit, 500));
end;
$$;

revoke execute on function public.admin_task_proofs(int) from public, anon;
grant execute on function public.admin_task_proofs(int) to authenticated;

-- Admin ko bill-proofs bucket padhne ki permission (moderation ke liye)
drop policy if exists "bill_proofs_admin_select" on storage.objects;
create policy "bill_proofs_admin_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'bill-proofs' and public.is_admin());

-- ---------------------------------------------------------------------------
-- VERIFY
-- ---------------------------------------------------------------------------
-- select column_name from information_schema.columns
--  where table_name in ('task_logs','footprints') and column_name = 'proof_path';
--
-- Photo task bina proof ke ab fail hona chahiye:
--   select public.award_task_points('led_swap', 30, 'photo');
--   → ERROR: A photo proof is required for this task.
-- ============================================================================
