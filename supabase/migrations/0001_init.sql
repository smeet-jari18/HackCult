-- ============================================================================
-- LiFE Mitra Gujarat — Supabase schema (replaces Firestore)
-- Run this ONCE in Supabase → SQL Editor (or `supabase db push`).
-- Safe to re-run: everything is idempotent.
-- ============================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- 1. COMMUNITIES (+ goals + members)  (was: communities/{id} + members/{uid})
-- ---------------------------------------------------------------------------
create table if not exists public.communities (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  type              text not null default 'Society',
  district          text not null default 'Ahmedabad',
  pincode           text not null default '',
  join_code         text not null unique,
  created_by        uuid references auth.users(id) on delete set null,
  member_count      int not null default 1,
  total_units_saved double precision not null default 0,
  goal_title        text not null default 'Save 100 units this month',
  goal_metric       text not null default 'units' check (goal_metric in ('units','co2','tasks')),
  goal_target       double precision not null default 100,
  goal_end_date     timestamptz not null default (now() + interval '30 days'),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id      uuid not null references public.communities(id) on delete cascade,
  user_id           uuid not null references auth.users(id) on delete cascade,
  goal_contribution double precision not null default 0,
  joined_at         timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (community_id, user_id)
);

-- ---------------------------------------------------------------------------
-- 2. PROFILES  (was: Firestore users/{uid})
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id                  uuid primary key references auth.users(id) on delete cascade,
  email               text not null default '',
  display_name        text not null default 'Citizen',
  photo_url           text,
  role                text not null default 'citizen'
                        check (role in ('citizen', 'captain', 'admin')),
  language            text not null default 'en',
  district            text not null default 'Ahmedabad',
  pincode             text not null default '380015',
  household_size      int  not null default 4,
  home_type           text not null default 'flat',
  roof_access         text not null default 'yes',
  appliances          text[] not null default array['ac','fridge','washing_machine','geyser'],
  travel_mode         text not null default 'two_wheeler',
  weekly_km           double precision not null default 70,
  baseline_units      double precision not null default 250,
  baseline_co2_kg     double precision not null default 226.9,
  goal_percent        int  not null default 15,
  onboarding_complete boolean not null default false,
  community_id        uuid references public.communities(id) on delete set null,

  -- gamification (server-writable only, see guard trigger)
  points              int not null default 0,
  weekly_points       int not null default 0,
  streak              int not null default 0,
  longest_streak      int not null default 0,
  freeze_tokens       int not null default 1,
  badges              text[] not null default '{}',
  last_task_day       date,
  daily_self_points   int  not null default 0,
  daily_tasks_done    int  not null default 0,
  daily_day           date,
  total_tasks_done    int  not null default 0,
  total_units_saved   double precision not null default 0,

  -- misc client-writable blobs
  gas_connection      jsonb,
  not_applicable_task_ids text[] not null default '{}',

  -- notification preferences
  peak_nudge          boolean not null default true,
  weather_nudge       boolean not null default true,
  community_updates   boolean not null default true,
  streak_reminders    boolean not null default true,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3. TASK LOGS  (was: users/{uid}/taskLogs/{yyyy-mm-dd_taskId})
-- ---------------------------------------------------------------------------
create table if not exists public.task_logs (
  id             bigserial primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  task_id        text not null,
  log_date       date not null default ((now() at time zone 'Asia/Kolkata')::date),
  status         text not null check (status in ('pending','done','skipped','not_applicable')),
  points_awarded int not null default 0,
  has_proof      boolean not null default false,
  created_at     timestamptz not null default now(),
  unique (user_id, task_id, log_date)
);
create index if not exists task_logs_user_date_idx on public.task_logs (user_id, log_date desc);

-- ---------------------------------------------------------------------------
-- 3b. STORAGE — bill proof uploads (replaces Firebase Storage rules)
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('bill-proofs', 'bill-proofs', false)
on conflict (id) do nothing;

drop policy if exists "bill_proofs_insert" on storage.objects;
create policy "bill_proofs_insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'bill-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "bill_proofs_select" on storage.objects;
create policy "bill_proofs_select" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'bill-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "bill_proofs_update" on storage.objects;
create policy "bill_proofs_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'bill-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "bill_proofs_delete" on storage.objects;
create policy "bill_proofs_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'bill-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- 4. FOOTPRINTS  (was: users/{uid}/footprints/{baseline_yyyy-mm | entry_yyyy-mm})
-- ---------------------------------------------------------------------------
create table if not exists public.footprints (
  id               bigserial primary key,
  user_id          uuid not null references auth.users(id) on delete cascade,
  month            date not null,   -- always first day of month
  electricity_units double precision not null default 0,
  electricity_kg    double precision not null default 0,
  cooking_kg        double precision not null default 0,
  transport_kg      double precision not null default 0,
  source            text not null default 'manual',
  is_baseline       boolean not null default false,
  units_saved       double precision not null default 0,
  rupees_saved      double precision not null default 0,
  percent_change    double precision not null default 0,
  points_awarded    int not null default 0,
  lpg_cylinders     double precision,
  created_at        timestamptz not null default now(),
  unique (user_id, month, is_baseline)
);
create index if not exists footprints_user_month_idx on public.footprints (user_id, month desc);

-- ---------------------------------------------------------------------------
-- 5. POINTS LEDGER  (was: users/{uid}/pointsLedger)
-- ---------------------------------------------------------------------------
create table if not exists public.points_ledger (
  id          bigserial primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  delta       int not null,
  reason      text not null default 'Points',
  task_id     text,
  created_at  timestamptz not null default now()
);
create index if not exists points_ledger_user_idx on public.points_ledger (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 6. SOLAR ASSESSMENTS + SURVEY REQUESTS (leads)
-- ---------------------------------------------------------------------------
create table if not exists public.solar_assessments (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  monthly_units     double precision not null,
  roof_area_m2      double precision not null,
  category          text not null default 'general',
  size_kw           double precision not null,
  annual_gen_units  double precision not null,
  gross_cost        double precision not null,
  central_subsidy   double precision not null,
  state_subsidy     double precision not null,
  net_cost          double precision not null,
  annual_savings    double precision not null,
  payback_years     double precision,
  co2_avoided_25y_kg double precision not null,
  created_at        timestamptz not null default now()
);

create table if not exists public.survey_requests (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  user_name      text not null default '',
  district       text not null default '',
  size_kw        double precision not null default 2,
  net_cost       double precision not null default 0,
  type           text not null default 'survey',
  vendor_name    text,
  status         text not null default 'new'
                   check (status in ('new','contacted','survey_done','quoted','installed','dropped')),
  phone          text,
  preferred_slot text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index if not exists survey_requests_created_idx on public.survey_requests (created_at desc);
create index if not exists survey_requests_user_idx on public.survey_requests (user_id);

-- ---------------------------------------------------------------------------
-- 7. LEADERBOARD — public projection, maintained by trigger (was: CF syncLeaderboard)
-- ---------------------------------------------------------------------------
create table if not exists public.leaderboard (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  display_name  text not null default 'Citizen',
  district      text not null default '',
  community_id  uuid,
  points        int not null default 0,
  weekly_points int not null default 0,
  streak        int not null default 0,
  updated_at    timestamptz not null default now()
);
create index if not exists leaderboard_points_idx on public.leaderboard (points desc);
create index if not exists leaderboard_district_points_idx on public.leaderboard (district, points desc);
create index if not exists leaderboard_community_points_idx on public.leaderboard (community_id, points desc);

-- ---------------------------------------------------------------------------
-- 8. PUSH TOKENS (was: users/{uid}.fcmToken)
-- ---------------------------------------------------------------------------
create table if not exists public.push_tokens (
  token      text primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  platform   text not null default 'web',
  updated_at timestamptz not null default now()
);
create index if not exists push_tokens_user_idx on public.push_tokens (user_id);

-- ---------------------------------------------------------------------------
-- 9. Helper: is the caller an admin?
-- ---------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role = 'admin' from public.profiles where id = auth.uid()),
    false
  );
$$;

-- ---------------------------------------------------------------------------
-- 10. Build the initial profile on sign-up (was: CF createUserProfile)
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
begin
  v_name := coalesce(
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'name',
    split_part(coalesce(new.email, 'citizen@life'), '@', 1)
  );
  insert into public.profiles (id, email, display_name, photo_url)
  values (
    new.id,
    coalesce(new.email, ''),
    v_name,
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Safety net: if an auth user somehow has no profile, create it on read.
create or replace function public.ensure_profile()
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.profiles;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  insert into public.profiles (id, email, display_name)
  values (
    auth.uid(),
    coalesce((select email from auth.users where id = auth.uid()), ''),
    coalesce((select split_part(coalesce(email,'citizen'), '@', 1) from auth.users where id = auth.uid()), 'Citizen')
  )
  on conflict (id) do nothing;
  select * into p from public.profiles where id = auth.uid();
  return p;
end;
$$;

-- ---------------------------------------------------------------------------
-- 11. Guard: clients may not grant themselves points/role/badges.
--     Only SECURITY DEFINER functions (which run as the owner) may change
--     these columns, so we detect "is this update coming from a definer fn?"
--     by comparing the current role: definer functions run with
--     current_user = postgres, client updates run as authenticated.
-- ---------------------------------------------------------------------------
create or replace function public.guard_profile_writes()
returns trigger
language plpgsql
as $$
begin
  if current_user in ('postgres', 'supabase_admin', 'service_role') then
    new.updated_at := now();
    return new;
  end if;

  -- Immutable identity columns
  new.id := old.id;
  new.email := old.email;
  new.created_at := old.created_at;

  -- Server-owned gamification columns
  new.points := old.points;
  new.weekly_points := old.weekly_points;
  new.streak := old.streak;
  new.longest_streak := old.longest_streak;
  new.freeze_tokens := old.freeze_tokens;
  new.badges := old.badges;
  new.last_task_day := old.last_task_day;
  new.daily_self_points := old.daily_self_points;
  new.daily_tasks_done := old.daily_tasks_done;
  new.daily_day := old.daily_day;
  new.total_tasks_done := old.total_tasks_done;
  new.total_units_saved := old.total_units_saved;

  -- Role changes only by an admin (used by the admin portal)
  if new.role is distinct from old.role and not public.is_admin() then
    new.role := old.role;
  end if;

  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists guard_profile_writes_trg on public.profiles;
create trigger guard_profile_writes_trg
  before update on public.profiles
  for each row execute function public.guard_profile_writes();

-- ---------------------------------------------------------------------------
-- 12. Mirror profiles → leaderboard (was: CF syncLeaderboard)
-- ---------------------------------------------------------------------------
create or replace function public.sync_leaderboard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role = 'admin' then
    delete from public.leaderboard where user_id = new.id;
    return new;
  end if;
  insert into public.leaderboard (user_id, display_name, district, community_id, points, weekly_points, streak, updated_at)
  values (new.id, new.display_name, new.district, new.community_id, new.points, new.weekly_points, new.streak, now())
  on conflict (user_id) do update set
    display_name = excluded.display_name,
    district     = excluded.district,
    community_id = excluded.community_id,
    points       = excluded.points,
    weekly_points= excluded.weekly_points,
    streak       = excluded.streak,
    updated_at   = now();
  return new;
end;
$$;

drop trigger if exists sync_leaderboard_trg on public.profiles;
create trigger sync_leaderboard_trg
  after insert or update on public.profiles
  for each row execute function public.sync_leaderboard();

-- ---------------------------------------------------------------------------
-- 13. POINTS ENGINE — task completion.
--     Was: Cloud Function awardTaskPoints (Firestore write trigger).
--     Now: called by the client via RPC *before* it can read the new score,
--     and the actual scoring happens here, server-side, atomically.
--     Daily self-verification cap = 150, streak, badges, lifetime totals,
--     community goal contribution and points ledger — all in one transaction.
-- ---------------------------------------------------------------------------
-- Level ladder (mirror of lib/core/logic LevelEngine / functions/src/index.ts)
create or replace function public.level_for(p_points int)
returns text
language sql
immutable
as $$
  select case
    when p_points >= 10000 then 'Champion'
    when p_points >= 4000  then 'Forest'
    when p_points >= 1500  then 'Grove'
    when p_points >= 600   then 'Tree'
    when p_points >= 200   then 'Sapling'
    else 'Seedling'
  end;
$$;

create or replace function public.award_task_points(
  p_task_id     text,
  p_points      int,
  p_verification text default 'self',
  p_est_units   double precision default 0,
  p_est_co2     double precision default 0,
  p_with_photo  boolean default false
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
  v_uid        uuid := auth.uid();
  v_today      date := (now() at time zone 'Asia/Kolkata')::date;
  v_profile    public.profiles;
  v_self_today int;
  v_tasks_today int;
  v_points     int;
  v_capped     boolean := false;
  v_streak     int;
  v_longest    int;
  v_badges     text[];
  v_total      int;
  v_new_level  text;
  v_old_level  text;
  v_verification text := coalesce(p_verification, 'self');
  v_contribution double precision := 0;
  v_goal       public.communities;
  v_existing   public.task_logs;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;
  if p_task_id is null or p_task_id = '' then
    raise exception 'task id required';
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
  insert into public.task_logs (user_id, task_id, log_date, status, points_awarded, has_proof)
  values (v_uid, p_task_id, v_today, 'done', v_points, coalesce(p_with_photo, false))
  on conflict (user_id, task_id, log_date) do update
    set status = 'done', points_awarded = excluded.points_awarded,
        has_proof = excluded.has_proof;

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

-- ---------------------------------------------------------------------------
-- 14. POINTS ENGINE — monthly bill / footprint entry (was: awardFootprintPoints)
-- ---------------------------------------------------------------------------
create or replace function public.award_footprint_points(p_footprint_id bigint)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_row     public.footprints;
  v_points  int;
  v_badges  text[];
  v_profile public.profiles;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  select * into v_row from public.footprints where id = p_footprint_id and user_id = v_uid for update;
  if not found then raise exception 'footprint not found'; end if;
  if v_row.is_baseline or v_row.points_awarded > 0 then return 0; end if;

  v_points := round(greatest(v_row.units_saved, 0) * 2)
              + case when v_row.source = 'bill' then 50 else 0 end;
  if v_points <= 0 then return 0; end if;

  select * into v_profile from public.profiles where id = v_uid for update;
  v_badges := coalesce(v_profile.badges, '{}');
  if v_row.source = 'bill' and not ('bill_verified' = any (v_badges)) then
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
  values (v_uid, v_points, 'Monthly bill · units saved');

  return v_points;
end;
$$;

-- ---------------------------------------------------------------------------
-- 15. Community join (atomic: member row + counter + profile link)
-- ---------------------------------------------------------------------------
create or replace function public.join_community(p_community_id uuid)
returns public.communities
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_c   public.communities;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  select * into v_c from public.communities where id = p_community_id for update;
  if not found then raise exception 'This community no longer exists.'; end if;

  if exists (select 1 from public.community_members
              where community_id = p_community_id and user_id = v_uid) then
    raise exception 'You are already a member of this community.';
  end if;

  insert into public.community_members (community_id, user_id) values (p_community_id, v_uid);
  update public.communities set member_count = member_count + 1, updated_at = now()
   where id = p_community_id returning * into v_c;
  update public.profiles set community_id = p_community_id, updated_at = now()
   where id = v_uid;

  return v_c;
end;
$$;

-- ---------------------------------------------------------------------------
-- 16. Community goal progress (aggregate over members)
-- ---------------------------------------------------------------------------
create or replace view public.community_goal_progress as
select
  c.id as community_id,
  c.goal_title,
  c.goal_metric,
  c.goal_target,
  c.goal_end_date,
  coalesce(sum(m.goal_contribution), 0) as progress,
  count(m.user_id)::int as member_total
from public.communities c
left join public.community_members m on m.community_id = c.id
group by c.id;

-- ---------------------------------------------------------------------------
-- 17. Admin: all survey requests (was collectionGroup query)
-- ---------------------------------------------------------------------------
create or replace function public.admin_survey_requests(p_limit int default 200)
returns setof public.survey_requests
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access is required.';
  end if;
  return query
    select * from public.survey_requests order by created_at desc limit greatest(1, p_limit);
end;
$$;

-- ---------------------------------------------------------------------------
-- 18. Weekly leaderboard reset (pg_cron; Monday 00:05 IST)
-- ---------------------------------------------------------------------------
create or replace function public.reset_weekly_points()
returns void
language sql
security definer
set search_path = public
as $$
  update public.profiles set weekly_points = 0 where weekly_points > 0;
$$;

-- pg_cron is available on Supabase; ignore errors if not enabled yet.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.unschedule('reset-weekly-points');
    exception when others then
      null;  -- job did not exist yet
    end;
    perform cron.schedule('reset-weekly-points', '5 0 * * 1',
      'select public.reset_weekly_points();');
  end if;
exception when others then
  raise notice 'pg_cron not configured: %', sqlerrm;
end;
$$;

-- ---------------------------------------------------------------------------
-- 19. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------------
alter table public.profiles          enable row level security;
alter table public.communities       enable row level security;
alter table public.community_members enable row level security;
alter table public.task_logs         enable row level security;
alter table public.footprints        enable row level security;
alter table public.points_ledger     enable row level security;
alter table public.solar_assessments enable row level security;
alter table public.survey_requests   enable row level security;
alter table public.leaderboard       enable row level security;
alter table public.push_tokens       enable row level security;

-- profiles: owner reads/writes own row; admins read all
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
  for update using (id = auth.uid() or public.is_admin())
  with check (id = auth.uid() or public.is_admin());

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles
  for insert with check (id = auth.uid());

-- communities: any signed-in citizen can read; creator can insert; members update counters via RPC only
drop policy if exists communities_select on public.communities;
create policy communities_select on public.communities
  for select using (auth.uid() is not null);

drop policy if exists communities_insert on public.communities;
create policy communities_insert on public.communities
  for insert with check (auth.uid() is not null and created_by = auth.uid());

drop policy if exists communities_update on public.communities;
create policy communities_update on public.communities
  for update using (created_by = auth.uid() or public.is_admin());

-- community members: read members of your own community (needed for goal progress)
drop policy if exists members_select on public.community_members;
create policy members_select on public.community_members
  for select using (true);

drop policy if exists members_insert on public.community_members;
create policy members_insert on public.community_members
  for insert with check (user_id = auth.uid());

drop policy if exists members_update on public.community_members;
create policy members_update on public.community_members
  for update using (user_id = auth.uid());

-- per-user tables: strictly own rows
do $$
declare t text;
begin
  foreach t in array array['task_logs','footprints','solar_assessments','points_ledger','push_tokens']
  loop
    execute format('drop policy if exists %I_owner on public.%I', t, t);
    execute format(
      'create policy %I_owner on public.%I for all
         using (user_id = auth.uid() or public.is_admin())
         with check (user_id = auth.uid())', t, t);
  end loop;
end;
$$;

-- survey requests: owner CRUD; admins read + update status
drop policy if exists survey_select on public.survey_requests;
create policy survey_select on public.survey_requests
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists survey_insert on public.survey_requests;
create policy survey_insert on public.survey_requests
  for insert with check (user_id = auth.uid());

drop policy if exists survey_update on public.survey_requests;
create policy survey_update on public.survey_requests
  for update using (public.is_admin()) with check (public.is_admin());

-- leaderboard: readable by any signed-in user, written only by trigger/RPC
drop policy if exists leaderboard_select on public.leaderboard;
create policy leaderboard_select on public.leaderboard
  for select using (auth.uid() is not null);

-- ---------------------------------------------------------------------------
-- 20. Realtime (live profile + leads updates in the app)
-- ---------------------------------------------------------------------------
do $$
begin
  begin execute 'alter publication supabase_realtime add table public.profiles'; exception when others then null; end;
  begin execute 'alter publication supabase_realtime add table public.survey_requests'; exception when others then null; end;
  begin execute 'alter publication supabase_realtime add table public.communities'; exception when others then null; end;
  begin execute 'alter publication supabase_realtime add table public.leaderboard'; exception when others then null; end;
end;
$$;

-- ---------------------------------------------------------------------------
-- 21. Grants
-- ---------------------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select on public.communities, public.leaderboard to authenticated;
grant select on public.community_goal_progress to authenticated;
grant execute on function public.award_task_points(text,int,text,double precision,double precision,boolean) to authenticated;
grant execute on function public.award_footprint_points(bigint) to authenticated;
grant execute on function public.join_community(uuid) to authenticated;
grant execute on function public.ensure_profile() to authenticated;
grant execute on function public.admin_survey_requests(int) to authenticated;
