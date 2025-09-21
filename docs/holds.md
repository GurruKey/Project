# Holds 01  дорожная карта (коротко)

## Hold 1  Репозиторий и правила
Цель: каркас и дисциплина PR/коммитов.
Готово: CONTRIBUTING.md принят, CI/линт  ок.

## Hold 2  Сборка/окружения
Цель: Vite+TS, правила .env (префикс VITE_).
Готово: docs/architecture.md обновлён.

## Hold 3  Архитектура фич и роутинг
Цель: feature-based структура, маршруты /, /profile, /admin (заглушка).
Готово: схема закреплена в docs/architecture.md.

## Hold 4  UI-примитивы и токены (тонко)
Цель: Button/Card/Input/Label/Heading/Skeleton + токены.
Готово: docs/ui-guidelines.md заполнен.

## Hold 5  Supabase проект
Цель: создать проект; подготовить VITE_SUPABASE_URL/ANON_KEY.
Готово: значения внесены локально в .env.local (не в git).

## Hold 6  RLS с первого дня
Цель: включать RLS для всех пользовательских таблиц; policy.
Готово: правило описано в docs/security.md.

## Hold 7  RBAC и аудит
Цель: Owner/Admin/Moderator/User + группы прав; audit_logs события.
Готово: docs/rbac.md + раздел в docs/security.md.

## Hold 8  Профиль и баланс (MVP)
Цель: сценарии /profile; баланс/промо/реферал  плейсхолдеры.
Готово: описано в docs/product-brief.md.

## Hold 9  Безопасность токенов
Цель: TTL, refresh, запрет чувствит. данных в JWT, куки-режим позже.
Готово: зафиксировано в docs/security.md.

## Hold 10  Честность/комплаенс
Цель: RNG/RTP, Responsible Gaming, privacy/GDPR, PCI  план.
Готово: docs/compliance.md заполнен.

## Hold 11  План данных
Цель: перечислить сущности и доступ (без DDL).
Готово: docs/data-model.md заполнен.

## Hold 12  Чек-лист MVP готов
Цель: единая точка готово.
Готово: docs/mvp-checklist.md создан.

 На каждом холде: обсуждаем  вносим правки в соответствующий файл  двигаем дальше.
