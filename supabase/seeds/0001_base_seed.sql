-- 0001_base_seed.sql  базовые роли/права и пара игр (для проверки RLS)
-- Выполнять из SQL-консоли Supabase ИЛИ через psql (не хранит секреты).

-- Роли
insert into public.roles (code, name) values
  ('owner','Owner'),
  ('admin','Admin'),
  ('moderator','Moderator'),
  ('user','User')
on conflict (code) do nothing;

-- Права (минимальный набор из docs/rbac.md)
insert into public.permissions (code, name) values
  ('user_mgmt','User management'),
  ('role_mgmt','Role management'),
  ('slots_mgmt','Slots catalog management'),
  ('promo_mgmt','Promotions management'),
  ('finance_view','Finance view'),
  ('finance_approve','Finance approve'),
  ('settings_write','Settings write'),
  ('audit_view','Audit view')
on conflict (code) do nothing;

-- Маппинг ролейправ (пример: admin почти всё; owner  всё; moderator  audit_view)
with r as (select id, code from public.roles),
     p as (select id, code from public.permissions)
insert into public.role_permissions(role_id, permission_id)
select r.id, p.id
from r join p on 1=1
where (r.code in ('owner','admin') and p.code in ('user_mgmt','role_mgmt','slots_mgmt','promo_mgmt','finance_view','audit_view'))
   or (r.code = 'owner' and p.code in ('finance_approve','settings_write'))
   or (r.code = 'moderator' and p.code in ('audit_view'))
on conflict do nothing;

-- Пара демо-игр
insert into public.games (slug, title, cover_url, rtp, volatility, tags)
values
  ('star-fruits','Star Fruits','https://example.com/covers/star-fruits.png', 96.50, 'medium', array['fruits','classic']),
  ('pyramid-wilds','Pyramid Wilds','https://example.com/covers/pyramid-wilds.png', 95.10, 'high',   array['egypt','wild'])
on conflict (slug) do nothing;
