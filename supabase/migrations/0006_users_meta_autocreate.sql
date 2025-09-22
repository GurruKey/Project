-- 0006_users_meta_autocreate.sql

-- 1) Функция: при создании пользователя в auth.users добавляем строку в users_meta
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users_meta (user_id, display_name, phone)
  values (new.id, split_part(coalesce(new.email, ''), '@', 1), null)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

-- 2) Триггер на системную таблицу аутентификации
drop trigger if exists on_auth_user_added on auth.users;
create trigger on_auth_user_added
after insert on auth.users
for each row execute function public.handle_new_user();

-- 3) Базовые RLS-политики (если не настроены)
alter table public.users_meta enable row level security;

drop policy if exists users_meta_owner_select on public.users_meta;
create policy users_meta_owner_select
on public.users_meta
for select
using (auth.uid() = user_id);

drop policy if exists users_meta_owner_upsert on public.users_meta;
create policy users_meta_owner_upsert
on public.users_meta
for insert
with check (auth.uid() = user_id);

drop policy if exists users_meta_owner_update on public.users_meta;
create policy users_meta_owner_update
on public.users_meta
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
