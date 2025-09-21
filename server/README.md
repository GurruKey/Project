# Server  план (черновик)

## 1) Роль сервера на MVP
- Пока без толстой логики: прокладка для будущих edge-функций и вебхуков.
- Вся приватная логика/ключи  только здесь (или в Supabase Edge Functions), не в клиенте.

## 2) Эндпоинты (черновик)
- /health  проверка живости.
- /webhooks/supabase  события (например, auth).
- /webhooks/payments  платёжный провайдер (пост-MVP).
- /admin/*  защищённые серверные операции (Role=Admin/Owner).

## 3) Безопасность
- Куки для SSR/edge (в будущем): HttpOnly, Secure, SameSite=Lax/Strict.
- Валидация входящих вебхуков: подпись провайдера + idempotency key.
- Ограничения частоты (rate limit) на чувствительные ручки.
- Заголовки: CSP, HSTS, X-Frame-Options, X-Content-Type-Options.

## 4) Конфигурация окружений
- SUPABASE_SERVICE_ROLE_KEY  только здесь/на edge, в секретах.
- Разные ключи для dev/stage/prod.
- Логи и трейсинг (подключим позже).

## 5) Структура (план)
server/
  README.md
  (позже)
  routes/
    health.(ts/js)
    webhooks/
      supabase.(ts/js)
      payments.(ts/js)
  lib/
    supabaseClient.(ts/js)
    auth.(ts/js)
    logger.(ts/js)

## 6) Ошибки и аудит
- Любая админская операция  запись в udit_logs.
- Ответы сервера без утечки деталей (стандартизованные ошибки).

## 7) Дальше
- Реализовать /health и заглушки вебхуков после инициализации кода.
