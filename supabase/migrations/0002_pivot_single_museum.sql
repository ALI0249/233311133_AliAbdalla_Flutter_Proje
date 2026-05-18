-- ============================================================
-- Müzem — Migration 0002
-- Pivot: single-museum focus (Topkapı), add artifacts catalog,
-- add admin role, add visits/occupancy.
-- Run this AFTER 0001 in the same Supabase project.
-- ============================================================

-- --------- Trim to one museum (Topkapı) ---------------------
delete from public.exhibitions where museum_id in (
  select id from public.museums where name <> 'Topkapi Sarayi Muzesi'
);
delete from public.museums where name <> 'Topkapi Sarayi Muzesi';

-- --------- Add admin role ----------------------------------
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('ziyaretci', 'personel', 'admin'));

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- Grant admin full visibility into profiles (so staff CRUD works)
drop policy if exists "profiles_admin_all" on public.profiles;
create policy "profiles_admin_all" on public.profiles
  for all
  using (public.is_admin())
  with check (public.is_admin());

-- --------- Museum capacity for occupancy gauge --------------
alter table public.museums add column if not exists capacity int not null default 500;
update public.museums set capacity = 1500 where name = 'Topkapi Sarayi Muzesi';

-- --------- ARTIFACTS (Eserler) ------------------------------
create table if not exists public.artifacts (
  id uuid primary key default gen_random_uuid(),
  museum_id uuid not null references public.museums(id) on delete cascade,
  name text not null,
  category text not null check (category in
    ('Sanat', 'Tarih', 'Heykel', 'Arkeoloji', 'Etnografya', 'El Yazmasi')),
  era text,
  description text,
  location_in_museum text,
  image_url text,
  qr_payload text unique not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_artifacts_museum on public.artifacts(museum_id);
create index if not exists idx_artifacts_category on public.artifacts(category);

alter table public.artifacts enable row level security;

drop policy if exists "artifacts_read_all" on public.artifacts;
create policy "artifacts_read_all" on public.artifacts
  for select using (auth.role() = 'authenticated');

drop policy if exists "artifacts_staff_write" on public.artifacts;
create policy "artifacts_staff_write" on public.artifacts
  for all
  using (public.is_personel() or public.is_admin())
  with check (public.is_personel() or public.is_admin());

-- --------- VISITS (entry events for occupancy) --------------
create table if not exists public.visits (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references public.tickets(id) on delete cascade,
  visitor_id uuid not null references public.profiles(id) on delete cascade,
  museum_id uuid not null references public.museums(id) on delete cascade,
  entered_at timestamptz not null default now(),
  exited_at timestamptz,
  entered_by_staff uuid references public.profiles(id) on delete set null,
  exited_by_staff uuid references public.profiles(id) on delete set null
);

create index if not exists idx_visits_active on public.visits(museum_id, exited_at);
create index if not exists idx_visits_visitor on public.visits(visitor_id);

alter table public.visits enable row level security;

drop policy if exists "visits_select_own_or_staff" on public.visits;
create policy "visits_select_own_or_staff" on public.visits
  for select using (
    visitor_id = auth.uid() or public.is_personel() or public.is_admin()
  );

drop policy if exists "visits_staff_insert" on public.visits;
create policy "visits_staff_insert" on public.visits
  for insert with check (public.is_personel() or public.is_admin());

drop policy if exists "visits_staff_update" on public.visits;
create policy "visits_staff_update" on public.visits
  for update using (public.is_personel() or public.is_admin());

-- --------- Occupancy view (count of unfinished visits today) -
create or replace view public.occupancy as
select
  m.id as museum_id,
  m.name,
  m.capacity,
  coalesce(count(v.id) filter (
    where v.exited_at is null and v.entered_at::date = current_date
  ), 0)::int as current_visitors
from public.museums m
left join public.visits v on v.museum_id = m.id
group by m.id, m.name, m.capacity;

grant select on public.occupancy to authenticated;

-- --------- Seed artifacts for Topkapı (12 pieces) -----------
with t as (select id from public.museums where name = 'Topkapi Sarayi Muzesi' limit 1)
insert into public.artifacts (museum_id, name, category, era, description, location_in_museum, qr_payload)
select t.id, a.name, a.category, a.era, a.description, a.location, a.qr
from t
cross join (values
  ('Topkapi Hancer-i',                  'Sanat',      '17. yuzyil',
    'Zumrut ve elmaslarla suslenmis, Osmanli sarayinda sembolik onem tasiyan toren hanceri.',
    '2. Avlu, Hazine Dairesi',          'art-topkapi-hancer'),
  ('Kasikci Elmasi',                    'Sanat',      '17. yuzyil',
    '86 karatlik dunyaca unlu pirlanta. Hazine Dairesi vitrinindeki en degerli parcalardan.',
    '2. Avlu, Hazine Dairesi',          'art-kasikci-elmas'),
  ('Hirka-i Saadet',                    'Tarih',      'Asr-i Saadet',
    'Hz. Muhammed (s.a.v.) tarafindan giyildigine inanilan kutsal hirka.',
    'Hirka-i Saadet Dairesi',           'art-hirka-saadet'),
  ('Kuran-i Kerim El Yazmasi',          'El Yazmasi', '15. yuzyil',
    'Altin yaldizla suslenmis hat sanati orneklerinden biri.',
    'Kutuphane Salonu',                 'art-kuran-elyaz'),
  ('Fatih Sultan Mehmet Portresi',      'Sanat',      '15. yuzyil',
    'Italyan ressam Bellini tarafindan yapilmis unlu portre.',
    'Has Oda',                          'art-fatih-portre'),
  ('Selcuklu Donemi Cinileri',          'Arkeoloji',  '13. yuzyil',
    'Konya cevresinden getirilmis Selcuklu cini calismalari.',
    '1. Avlu Sergi Salonu',             'art-selcuklu-cini'),
  ('Anadolu Halisi',                    'Etnografya', '19. yuzyil',
    'Geleneksel motiflerle el dokumasi olarak uretilmis Anadolu halisi.',
    'Etnografya Bolumu',                'art-anadolu-hali'),
  ('Hitit Tunc Heykeli',                'Heykel',     'M.O. 1500',
    'Hitit imparatorluk donemine ait dini ritueller icin yapilmis tunc heykel.',
    'Antik Eserler Salonu',             'art-hitit-heykel'),
  ('Sumer Cuneiform Tableti',           'Arkeoloji',  'M.O. 3000',
    'Mezopotamya kokenli, ticari kayitlar iceren killi tablet.',
    'Antik Eserler Salonu',             'art-sumer-tablet'),
  ('Bizans Donemi Mozaik Parcasi',      'Sanat',      '6. yuzyil',
    'Ayasofya cevresinden cikarilmis mozaik panel parcasi.',
    'Bizans Sanati Salonu',             'art-bizans-mozayik'),
  ('Osmanli Padisah Tugrasi',           'Tarih',      '18. yuzyil',
    'Tezhipli orijinal padisah tugrasi ornegi.',
    'Has Oda',                          'art-padisah-tugra'),
  ('Yenicerilere Ait Kilic',            'Tarih',      '17. yuzyil',
    'Yeniceri ocagina ait toren kilici, kabzasi gumus islemeli.',
    'Silah Mudahir Salonu',             'art-yenicerikilic')
) as a(name, category, era, description, location, qr);
