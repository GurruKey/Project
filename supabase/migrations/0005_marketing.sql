-- 0005_marketing.sql — промокоды и рефералы (MVP, исправлено)

-- a) Промокоды (каталог правил — без логики начислений на MVP)
create table if not exists public.promos (
  id           bigserial primary key,
  code         text unique not null,          -- UPPER_SNAKE_CASE
  title        text not null,
  description  text,
  is_active    boolean not null default true,
  starts_at    timestamptz,
  ends_at      timestamptz,
  meta         jsonb not null default '{}'::jsonb,  -- плейсхолдер: ограничения/типы
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  -- чтобы окно действий было валидно (если оба заданы)
  constraint promos_time_window_chk
    check (starts_at is null or ends_at is null or starts_at <= ends_at)
);

create or replace function public.promos_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_promos_updated on public.promos;
create trigger trg_promos_updated
before update on public.promos
for each row execute function public.promos_set_updated_at();

alter table public.promos enable row level security;

-- Чтение:
--  a) Публичное чтение активных промо (анон и аутентифицированные)
drop policy if exists promos_read_public on public.promos;
create policy promos_read_public
  on public.promos
  for select
  to anon, authenticated
  using (
    is_active = true
    and (starts_at is null or now() >= starts_at)
    and (ends_at   is null or now() <= ends_at)
  );

--  b) Staff (owner/admin) видят всё, включая неактивные
drop policy if exists promos_read_staff_all on public.promos;
create policy promos_read_staff_all
  on public.promos
  for select
  to authenticated
  using ( public.is_admin_or_owner(auth.uid()) );

-- Запись/изменение — только admin/owner (ОТДЕЛЬНЫЕ ПОЛИТИКИ)
drop policy if exists promos_admin_write   on public.promos; -- старая объединённая, на всякий
drop policy if exists promos_admin_insert  on public.promos;
drop policy if exists promos_admin_update  on public.promos;
drop policy if exists promos_admin_delete  on public.promos;

create policy promos_admin_insert
  on public.promos
  for insert
  to authenticated
  with check ( public.is_admin_or_owner(auth.uid()) );

create policy promos_admin_update
  on public.promos
  for update
  to authenticated
  using     ( public.is_admin_or_owner(auth.uid()) )
  with check( public.is_admin_or_owner(auth.uid()) );

create policy promos_admin_delete
  on public.promos
  for delete
  to authenticated
  using ( public.is_admin_or_owner(auth.uid()) );

-- Индексы
create index if not exists idx_promos_active_window on public.promos(is_active, starts_at, ends_at);
-- отдельный индекс на code не нужен — UNIQUE уже создаёт индекс
-- create index if not exists idx_promos_code on public.promos(code);


-- b) Рефералы (кто кого пригласил)
create table if not exists public.referrals (
  id            bigserial primary key,
  referrer_id   uuid not null references auth.users(id) on delete cascade,
  referee_id    uuid not null references auth.users(id) on delete cascade,
  created_at    timestamptz not null default now(),
  unique (referee_id),                     -- один пригласивший на пользователя
  constraint referrals_no_self_invite_chk
    check (referrer_id <> referee_id)      -- нельзя пригласить самого себя
);

alter table public.referrals enable row level security;

-- Чтение: владелец видит свои записи (как приглашённый или как пригласивший);
-- staff (owner/admin/moderator) читает всё
drop policy if exists referrals_read_owner_or_staff on public.referrals;
create policy referrals_read_owner_or_staff
  on public.referrals
  for select
  to authenticated
  using (
    referrer_id = auth.uid()
    or referee_id = auth.uid()
    or public.is_staff(auth.uid())
  );

-- Создание: разрешаем только «самопривязку» — когда текущий пользователь = referee_id
drop policy if exists referrals_insert_self on public.referrals;
create policy referrals_insert_self
  on public.referrals
  for insert
  to authenticated
  with check ( referee_id = auth.uid() );

-- Правка/удаление: пользователям запрещено; админ — через service role
create index if not exists idx_referrals_referrer on public.referrals(referrer_id);
create index if not exists idx_referrals_referee  on public.referrals(referee_id);
create index if not exists idx_referrals_created  on public.referrals(created_at desc);
