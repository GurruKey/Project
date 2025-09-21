-- 0001_init.sql — базовые таблицы + RLS (минимум)
-- Предполагаем Supabase (есть auth.users)

-- 1) users_meta — профиль пользователя (минимальный набор)
create table if not exists public.users_meta (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.users_meta_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_users_meta_updated on public.users_meta;
create trigger trg_users_meta_updated
before update on public.users_meta
for each row execute function public.users_meta_set_updated_at();

alter table public.users_meta enable row level security;

-- Политики: владелец читает/пишет только свою запись
-- заменить объединённую политику на три раздельные
drop policy if exists users_meta_owner_modify on public.users_meta;
drop policy if exists users_meta_owner_insert on public.users_meta;
drop policy if exists users_meta_owner_update on public.users_meta;
drop policy if exists users_meta_owner_delete on public.users_meta;

create policy users_meta_owner_insert
  on public.users_meta
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy users_meta_owner_update
  on public.users_meta
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy users_meta_owner_delete
  on public.users_meta
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- 2) roles/permissions/user_roles — каркас RBAC (управляются сервис-ключом/админом)
create table if not exists public.roles (
  id bigserial primary key,
  code text unique not null,      -- 'owner' | 'admin' | 'moderator' | 'user'
  name text not null
);

create table if not exists public.permissions (
  id bigserial primary key,
  code text unique not null,      -- 'user_mgmt', 'role_mgmt', ...
  name text not null
);

create table if not exists public.role_permissions (
  role_id bigint references public.roles(id) on delete cascade,
  permission_id bigint references public.permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table if not exists public.user_roles (
  user_id uuid references auth.users(id) on delete cascade,
  role_id bigint references public.roles(id) on delete cascade,
  primary key (user_id, role_id)
);

alter table public.roles            enable row level security;
alter table public.permissions      enable row level security;
alter table public.role_permissions enable row level security;
alter table public.user_roles       enable row level security;

-- Политики: по умолчанию НИКТО (кроме service role) писать не может.
-- Разрешим только чтение аутентифицированным (админка будет работать через service role).
drop policy if exists roles_read_all on public.roles;
create policy roles_read_all
  on public.roles
  for select
  to authenticated
  using ( true );

drop policy if exists permissions_read_all on public.permissions;
create policy permissions_read_all
  on public.permissions
  for select
  to authenticated
  using ( true );

drop policy if exists role_permissions_read_all on public.role_permissions;
create policy role_permissions_read_all
  on public.role_permissions
  for select
  to authenticated
  using ( true );

drop policy if exists user_roles_read_own on public.user_roles;
create policy user_roles_read_own
  on public.user_roles
  for select
  to authenticated
  using ( user_id = auth.uid() );

-- 3) полезные индексы
create index if not exists idx_user_roles_user   on public.user_roles(user_id);
create index if not exists idx_user_roles_role   on public.user_roles(role_id);


