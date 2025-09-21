-- 0002_audit.sql — журнал действий + RLS

-- 0) Хелпер: is_staff() → Owner/Admin/Moderator = true
create or replace function public.is_staff(uid uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = uid
      and r.code in ('owner','admin','moderator')
  );
$$;

-- 1) Журнал аудита
create table if not exists public.audit_logs (
  id           bigserial primary key,
  user_id      uuid null references auth.users(id) on delete set null,
  action       text not null,           -- e.g. "auth.login", "profile.update"
  entity       text null,               -- e.g. "users_meta"
  entity_id    text null,               -- строковый PK цели (uuid, bigint, и т.п.)
  meta         jsonb default '{}'::jsonb, -- контекст (без секретов!)
  ip           inet null,
  user_agent   text null,
  created_at   timestamptz not null default now()
);

-- индексы
create index if not exists idx_audit_logs_user   on public.audit_logs(user_id);
create index if not exists idx_audit_logs_action on public.audit_logs(action);
create index if not exists idx_audit_logs_time   on public.audit_logs(created_at);

-- включаем RLS
alter table public.audit_logs enable row level security;

-- Политики:
--  a) ЧТЕНИЕ: только staff (owner/admin/moderator)
drop policy if exists audit_logs_read_staff on public.audit_logs;
create policy audit_logs_read_staff
  on public.audit_logs
  for select
  to authenticated
  using ( public.is_staff(auth.uid()) );

--  b) ЗАПИСЬ: владелец может писать события про себя (например, "profile.update")
drop policy if exists audit_logs_write_self on public.audit_logs;
create policy audit_logs_write_self
  on public.audit_logs
  for insert
  to authenticated
  with check (
    -- разрешаем, если событие связано с самим пользователем
    user_id = auth.uid()
  );

-- Примечание:
--  - Системные/админские записи (про других пользователей) писать через сервер/edge c service_role,
--    который обходит RLS по определению (или добавить отдельную policy под роль).
