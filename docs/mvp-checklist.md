# MVP Checklist  Casino Slots

## Репозиторий и структура
- [ ] README.md актуален
- [ ] .gitignore содержит локальные env
- [ ] .env.example присутствует
- [ ] client/, server/, supabase/, docs/ созданы

## Архитектура/безопасность (доки)
- [ ] docs/architecture.md заполнен
- [ ] docs/security.md заполнен
- [ ] docs/rbac.md заполнен
- [ ] docs/product-brief.md заполнен

## Supabase (подготовка)
- [ ] Создан проект в Supabase
- [ ] Взяты VITE_SUPABASE_URL и VITE_SUPABASE_ANON_KEY
- [ ] RLS включается с первого дня для пользовательских таблиц

## Фронт (каркас, без логики)
- [ ] client/src/app/ существует (роутинг запланирован)
- [ ] client/src/features/ существует (slots, profile, admin)
- [ ] client/src/shared/{ui,api,types,hooks,lib} существуют

## Администрирование и аудит
- [ ] Роли/права согласованы (Owner/Admin/Moderator/User)
- [ ] Минимальный набор событий аудита определён

## Критерии готовности MVP
- [ ] Пользователь может зарегистрироваться/войти/выйти (позже)
- [ ] Может менять e-mail/телефон/пароль (позже)
- [ ] Видит витрину слотов и карточку игры (плейсхолдер)
- [ ] Нет секретов в репозитории
