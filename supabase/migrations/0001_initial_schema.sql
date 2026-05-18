-- ============================================================
-- Müzem — initial database schema for Supabase (PostgreSQL)
-- Run this entire file once in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- ============== TABLES ======================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  role text not null default 'ziyaretci' check (role in ('ziyaretci', 'personel')),
  created_at timestamptz not null default now()
);

create table if not exists public.museums (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text,
  address text,
  opening_hours text,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.exhibitions (
  id uuid primary key default gen_random_uuid(),
  museum_id uuid not null references public.museums(id) on delete cascade,
  title text not null,
  start_date date,
  end_date date,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.ticket_types (
  id serial primary key,
  name text not null unique,
  price numeric(10, 2) not null
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  visitor_id uuid not null references public.profiles(id) on delete cascade,
  museum_id uuid not null references public.museums(id) on delete restrict,
  ticket_type_id int not null references public.ticket_types(id) on delete restrict,
  visit_date date not null,
  status text not null default 'aktif' check (status in ('aktif', 'kullanildi', 'iptal')),
  qr_payload text not null,
  price_paid numeric(10, 2) not null,
  created_at timestamptz not null default now(),
  used_at timestamptz
);

create table if not exists public.logs (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_tickets_visitor on public.tickets(visitor_id);
create index if not exists idx_tickets_museum on public.tickets(museum_id);
create index if not exists idx_tickets_status on public.tickets(status);
create index if not exists idx_exhibitions_museum on public.exhibitions(museum_id);
create index if not exists idx_logs_user on public.logs(user_id);

-- ============== AUTO-CREATE PROFILE ON SIGN-UP ==============
-- When a new user signs up via Supabase Auth, a row is auto-inserted into
-- public.profiles with role='ziyaretci'. The full_name and phone come from
-- the raw_user_meta_data the app passes during register.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Yeni Ziyaretçi'),
    new.raw_user_meta_data->>'phone',
    'ziyaretci'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============== ROW LEVEL SECURITY ==========================

alter table public.profiles enable row level security;
alter table public.museums enable row level security;
alter table public.exhibitions enable row level security;
alter table public.ticket_types enable row level security;
alter table public.tickets enable row level security;
alter table public.logs enable row level security;

-- Helper: is the calling user a staff member?
create or replace function public.is_personel()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'personel'
  );
$$;

-- ---------- profiles ----------
drop policy if exists "profiles_self_select" on public.profiles;
create policy "profiles_self_select" on public.profiles
  for select using (auth.uid() = id or public.is_personel());

drop policy if exists "profiles_self_update" on public.profiles;
create policy "profiles_self_update" on public.profiles
  for update using (auth.uid() = id);

drop policy if exists "profiles_self_insert" on public.profiles;
create policy "profiles_self_insert" on public.profiles
  for insert with check (auth.uid() = id);

-- ---------- museums ----------
drop policy if exists "museums_read_all" on public.museums;
create policy "museums_read_all" on public.museums
  for select using (auth.role() = 'authenticated');

drop policy if exists "museums_personel_write" on public.museums;
create policy "museums_personel_write" on public.museums
  for all using (public.is_personel()) with check (public.is_personel());

-- ---------- exhibitions ----------
drop policy if exists "exhibitions_read_all" on public.exhibitions;
create policy "exhibitions_read_all" on public.exhibitions
  for select using (auth.role() = 'authenticated');

drop policy if exists "exhibitions_personel_write" on public.exhibitions;
create policy "exhibitions_personel_write" on public.exhibitions
  for all using (public.is_personel()) with check (public.is_personel());

-- ---------- ticket_types ----------
drop policy if exists "ticket_types_read_all" on public.ticket_types;
create policy "ticket_types_read_all" on public.ticket_types
  for select using (auth.role() = 'authenticated');

drop policy if exists "ticket_types_personel_write" on public.ticket_types;
create policy "ticket_types_personel_write" on public.ticket_types
  for all using (public.is_personel()) with check (public.is_personel());

-- ---------- tickets ----------
drop policy if exists "tickets_own_or_personel_select" on public.tickets;
create policy "tickets_own_or_personel_select" on public.tickets
  for select using (visitor_id = auth.uid() or public.is_personel());

drop policy if exists "tickets_own_insert" on public.tickets;
create policy "tickets_own_insert" on public.tickets
  for insert with check (visitor_id = auth.uid());

drop policy if exists "tickets_personel_update" on public.tickets;
create policy "tickets_personel_update" on public.tickets
  for update using (public.is_personel());

-- ---------- logs ----------
drop policy if exists "logs_authenticated_insert" on public.logs;
create policy "logs_authenticated_insert" on public.logs
  for insert with check (auth.role() = 'authenticated');

drop policy if exists "logs_personel_select" on public.logs;
create policy "logs_personel_select" on public.logs
  for select using (public.is_personel());

-- ============== SEED DATA ===================================

insert into public.ticket_types (name, price) values
  ('Yetiskin', 200.00),
  ('Ogrenci', 100.00),
  ('Cocuk', 50.00),
  ('Grup', 150.00),
  ('Muzekart', 0.00)
on conflict (name) do nothing;

insert into public.museums (name, city, address, opening_hours, description) values
  ('Topkapi Sarayi Muzesi', 'Istanbul', 'Cankurtaran, Fatih', '09:00 - 18:00', 'Osmanli padisahlarinin yasadigi saray.'),
  ('Mevlana Muzesi', 'Konya', 'Aziziye Mah., Karatay', '09:00 - 19:00', 'Mevlana Celaleddin-i Rumi turbesi ve dergahi.'),
  ('Konya Arkeoloji Muzesi', 'Konya', 'Sahip Ata Caddesi', '08:30 - 17:00', 'Selcuklu donemine ait eserler.'),
  ('Anadolu Medeniyetleri Muzesi', 'Ankara', 'Gozcu Sokak, Altindag', '08:30 - 18:30', 'Hitit ve Frig medeniyetlerine ait eserler.'),
  ('Ayasofya-i Kebir Camii Muzesi', 'Istanbul', 'Sultanahmet, Fatih', '00:00 - 24:00', 'Bizans ve Osmanli mimari mirasi.'),
  ('Antalya Muzesi', 'Antalya', 'Konyaalti Caddesi', '09:00 - 19:00', 'Antik Pamfilya ve Likya eserleri.'),
  ('Catalhoyuk Acik Hava Muzesi', 'Konya', 'Cumra Ilcesi', '09:00 - 17:00', 'Neolitik donem yerlesimi.');

with m as (select id, name from public.museums)
insert into public.exhibitions (museum_id, title, start_date, end_date, description)
select m.id, e.title, e.start_date::date, e.end_date::date, e.description
from m
join (values
  ('Topkapi Sarayi Muzesi', 'Osmanli Hazineleri', '2026-04-01', '2026-12-31', 'Padisahlara ait kilic, hilat ve takilar.'),
  ('Topkapi Sarayi Muzesi', 'Harem Daireleri', '2026-05-01', '2026-09-30', 'Harem dairelerinin tarihce ve mimarisi.'),
  ('Mevlana Muzesi', 'El Yazmasi Eserler', '2026-03-15', '2026-08-15', 'Mesnevi-i Manevi nin tarihi nushalari.'),
  ('Konya Arkeoloji Muzesi', 'Selcuklu Cinileri', '2026-05-01', '2026-11-30', 'Selcuklu donemi cini sanati.'),
  ('Anadolu Medeniyetleri Muzesi', 'Hitit Krallari', '2026-04-10', '2026-10-10', 'Hitit imparatorluk donemine ait stel ve eserler.'),
  ('Antalya Muzesi', 'Perge Antik Kenti', '2026-06-01', '2026-12-31', 'Perge kazilarindan cikan heykel ve mozaikler.')
) as e(museum_name, title, start_date, end_date, description) on m.name = e.museum_name;
