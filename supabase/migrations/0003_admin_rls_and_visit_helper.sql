-- ============================================================
-- Müzem — Migration 0003
-- Extend RLS so admins can do everything personel can do.
-- (0002 only added admin policies for profiles, artifacts, visits.
--  This fills in tickets, museums, exhibitions, ticket_types, logs.)
-- Also adds a helper RPC for processing a ticket scan transactionally.
-- ============================================================

-- ---------- tickets: staff or admin can mark as used ---------
drop policy if exists "tickets_personel_update" on public.tickets;
create policy "tickets_staff_update" on public.tickets
  for update using (public.is_personel() or public.is_admin());

-- ---------- logs: staff or admin can read --------------------
drop policy if exists "logs_personel_select" on public.logs;
create policy "logs_staff_select" on public.logs
  for select using (public.is_personel() or public.is_admin());

-- ---------- museums: staff or admin can write ----------------
drop policy if exists "museums_personel_write" on public.museums;
create policy "museums_staff_write" on public.museums
  for all
  using (public.is_personel() or public.is_admin())
  with check (public.is_personel() or public.is_admin());

-- ---------- exhibitions: staff or admin can write ------------
drop policy if exists "exhibitions_personel_write" on public.exhibitions;
create policy "exhibitions_staff_write" on public.exhibitions
  for all
  using (public.is_personel() or public.is_admin())
  with check (public.is_personel() or public.is_admin());

-- ---------- ticket_types: staff or admin can write -----------
drop policy if exists "ticket_types_personel_write" on public.ticket_types;
create policy "ticket_types_staff_write" on public.ticket_types
  for all
  using (public.is_personel() or public.is_admin())
  with check (public.is_personel() or public.is_admin());

-- ============== Transactional ticket scan helper =============
-- Called by the staff scanner. Given a ticket_id, this RPC:
--   - if the ticket has no active visit -> create a visit row (ENTRY),
--     mark the ticket as kullanildi, return 'entered'.
--   - if there IS an open visit (entered, not exited) -> stamp
--     exited_at on it, return 'exited'.
--   - if the ticket is iptal or visit_date != today, raise.
-- This sidesteps round-trips and keeps occupancy correct.

create or replace function public.process_ticket_scan(p_ticket_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text;
  v_visit_date date;
  v_visitor uuid;
  v_museum uuid;
  v_open_visit uuid;
  v_staff uuid := auth.uid();
begin
  if not (public.is_personel() or public.is_admin()) then
    raise exception 'YETKI_YOK';
  end if;

  select status, visit_date, visitor_id, museum_id
    into v_status, v_visit_date, v_visitor, v_museum
  from public.tickets
  where id = p_ticket_id;

  if v_status is null then
    raise exception 'BILET_BULUNAMADI';
  end if;
  if v_status = 'iptal' then
    raise exception 'BILET_IPTAL';
  end if;
  if v_visit_date <> current_date then
    raise exception 'BILET_BUGUN_DEGIL';
  end if;

  -- already has an open visit -> this is the exit scan
  select id into v_open_visit
  from public.visits
  where ticket_id = p_ticket_id and exited_at is null
  limit 1;

  if v_open_visit is not null then
    update public.visits
      set exited_at = now(), exited_by_staff = v_staff
      where id = v_open_visit;
    return 'exited';
  end if;

  -- entry path
  insert into public.visits
    (ticket_id, visitor_id, museum_id, entered_at, entered_by_staff)
  values
    (p_ticket_id, v_visitor, v_museum, now(), v_staff);

  update public.tickets
    set status = 'kullanildi', used_at = now()
    where id = p_ticket_id;

  return 'entered';
end;
$$;

grant execute on function public.process_ticket_scan(uuid) to authenticated;
