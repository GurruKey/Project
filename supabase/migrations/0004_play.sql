-- 0004_play.sql — ставки и раунды (MVP-плейсхолдер) [исправлено]

-- Таблица ставок
create table if not exists public.bets (
  id         bigserial primary key,
  user_id    uuid   not null references auth.users(id) on delete cascade,
  game_id    bigint not null references public.games(id) on delete restrict,
  amount     numeric(14,2) not null check (amount >= 0),
  currency   text not null default 'USD' check (currency ~ '^[A-Z]{3}$'),
  placed_at  timestamptz not null default now()
);

-- Таблица результатов раундов
create table if not exists public.game_rounds (
  id         bigserial primary key,
  bet_id     bigint not null references public.bets(id) on delete cascade,
  user_id    uuid   not null references auth.users(id) on delete cascade,
  game_id    bigint not null references public.games(id) on delete restrict,
  result     jsonb  not null default '{}'::jsonb,  -- плейсхолдер (комбинации и пр.)
  payout     numeric(14,2) not null default 0,
  created_at timestamptz   not null default now()
);

-- Индексы
create index if not exists idx_bets_user        on public.bets(user_id);
create index if not exists idx_bets_game_time   on public.bets(game_id, placed_at desc);
create index if not exists idx_bets_placed_at   on public.bets(placed_at desc);

create index if not exists idx_rounds_user      on public.game_rounds(user_id);
create index if not exists idx_rounds_bet       on public.game_rounds(bet_id);
create index if not exists idx_rounds_created_at on public.game_rounds(created_at desc);

-- Включаем RLS
alter table public.bets        enable row level security;
alter table public.game_rounds enable row level security;

-- Политики: владелец читает свои записи; staff читает всё.
-- is_staff(uid) определён в 0002_audit.sql

-- bets: чтение владельцем или staff
drop policy if exists bets_read_owner_or_staff on public.bets;
create policy bets_read_owner_or_staff
  on public.bets
  for select
  to authenticated
  using (user_id = auth.uid() or public.is_staff(auth.uid()));

-- bets: вставка только «за себя»
drop policy if exists bets_owner_insert on public.bets;
create policy bets_owner_insert
  on public.bets
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Обновление/удаление ставок не разрешаем (история неизменна).
-- Админские операции выполнять через service role.

-- game_rounds: чтение владельцем или staff
drop policy if exists rounds_read_owner_or_staff on public.game_rounds;
create policy rounds_read_owner_or_staff
  on public.game_rounds
  for select
  to authenticated
  using (user_id = auth.uid() or public.is_staff(auth.uid()));

-- game_rounds: вставка только «за себя» (MVP-режим)
drop policy if exists rounds_owner_insert on public.game_rounds;
create policy rounds_owner_insert
  on public.game_rounds
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Апдейты/удаления раундов не разрешаем (по умолчанию блокированы RLS).
