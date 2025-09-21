-- 0003_catalog.sql — каталог слотов

-- Хелпер: только admin/owner
create or replace function public.is_admin_or_owner(uid uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = uid
      and r.code in ('owner','admin')
  );
$$;

-- Таблица игр (метаданные; без механики)
create table if not exists public.games (
  id           bigserial primary key,
  slug         text unique not null,      -- человекочитаемый идентификатор
  title        text not null,
  cover_url    text,                      -- обложка
  rtp          numeric(5,2),              -- RTP, плейсхолдер
  volatility   text,                      -- low/medium/high — плейсхолдер
  tags         text[] default '{}',
  is_active    boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create or replace function public.games_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_games_updated on public.games;
create trigger trg_games_updated
before update on public.games
for each row execute function public.games_set_updated_at();

-- Включаем RLS
alter table public.games enable row level security;

-- Политики:
-- a) Публичное чтение (гостям и аутентифицированным)
drop policy if exists games_read_public on public.games;
create policy games_read_public
  on public.games
  for select
  to anon, authenticated
  using (is_active = true);

-- b) Создание/изменение/удаление — только admin/owner (отдельные политики)
drop policy if exists games_admin_write on public.games; -- старая объединённая
drop policy if exists games_admin_insert on public.games;
drop policy if exists games_admin_update on public.games;
drop policy if exists games_admin_delete on public.games;

create policy games_admin_insert
  on public.games
  for insert
  to authenticated
  with check (public.is_admin_or_owner(auth.uid()));

create policy games_admin_update
  on public.games
  for update
  to authenticated
  using (public.is_admin_or_owner(auth.uid()))    -- кто может трогать существующую строку
  with check (public.is_admin_or_owner(auth.uid())); -- каким должен быть "новый" ряд

create policy games_admin_delete
  on public.games
  for delete
  to authenticated
  using (public.is_admin_or_owner(auth.uid()));

-- Индексы
create index if not exists idx_games_active on public.games(is_active);
-- уникальный индекс по slug уже существует (из unique-ограничения), второй не создаём
-- create index if not exists idx_games_slug on public.games(slug);
