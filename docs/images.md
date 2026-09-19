# Изображения

Изменение размера и формата выполняет imgproxy. Rails хранит оригиналы через Active Storage
и подписывает URL; веб и Android используют один HTML. Версии — в Gemfile.lock и compose.yml.

## Запуск и проверка

`bin/setup` создаёт локальные ключи и таблицы Active Storage. `bin/dev` запускает imgproxy
через Overmind вместе с приложением. После обновления существующего checkout:

```sh
mise exec -- bin/images setup
mise exec -- bin/rails db:prepare
mise exec -- bin/dev
```

Ключи лежат в игнорируемом `config/imgproxy.local.yml` с правами 0600.
Healthcheck — `http://localhost:8082/images/health`, метрики — `http://localhost:8083/metrics`.
Оба порта по умолчанию доступны только с компьютера разработчика.
Для физического Android-устройства настрой LAN-адрес по [инструкции Android](native.md).

```sh
mise exec -- bin/rails test test/lib/image_variant_url_test.rb
mise exec -- bin/image-test
```

Первая команда проверяет генерацию ссылок и контракты. Вторая запускает отдельный контейнер
на портах 8382/8383: загружает тестовый PNG через Active Storage, получает WebP 32×16,
проверяет подпись, срок ссылки и запрет внешнего источника, затем удаляет blob и контейнер.
Метрики остаются в `tmp/images/imgproxy.prom`; CI сохраняет их в артефактах.
Проверки входят в `bin/ci`. Исходный PNG — синтетическая одноцветная картинка 128×64 в `test/fixtures/files`.

## Использование в экранах

У модели с `has_one_attached :photo` используй стандартный variant:

```erb
<%= image_tag record.photo.variant(resize_to_limit: [800, 600], format: :webp),
      alt: "Описание изображения", loading: "lazy" %>
```

Название поля и alt принадлежат конкретному экрану. Перед выдачей ссылки проверь доступ к записи.
Форму загрузки и доменное поле добавляй вместе с реальной функцией: проверяй пользователя,
принадлежность blob, размер и распознанный MIME; не доверяй имени файла и Content-Type клиента.
Direct uploads требуют отдельного решения по аутентификации и ограничениям загрузки.

Не вызывай `.processed` и не включай `preprocessed: true`: они запускают локальные Rails variants.
Операции преобразования задавай в коде, не передавай сырой params в variant или imgproxy_options.
`Images::VariantUrl` использует преобразователь imgproxy-rails, сохраняет `format`, отклоняет
неизвестные Rails-преобразования и не изменяет исходный hash. Дополнительные опции — через
`imgproxy_options`; они имеют приоритет, кроме обязательного срока ссылки.

`image_processing` и libvips остаются для штатного анализа метаданных Active Storage.
PDF/video previews не настроены: для них требуется отдельный сценарий и, в случае imgproxy, Pro.

## Хранение и доступ

В development контейнер читает `storage/`, в production — том `starterapp_storage`, только для чтения.
Источники imgproxy ограничены `local:///`; HTTP, metadata endpoints и произвольные внешние URL запрещены.
Переход на S3 или несколько серверов требует общей object storage и изменения `Images::VariantUrl`.

Ссылки подписаны HMAC и действуют 15 минут; кеширование результата ограничено минутой.
Это bearer-ссылки: знающий URL может читать изображение до истечения срока, даже после выхода.
Не используй их для документов, которым нужен немедленный отзыв доступа; для таких файлов
проектируй авторизованную выдачу отдельно. Не кешируй HTML с этими ссылками дольше их срока.

Ограничения сервиса: исходник до 20 MiB и 25 мегапикселей, результат до 4096 пикселей по стороне,
один кадр анимации, два обработчика и очередь до 16 запросов. Это стартовые ограничения;
перед изменением измеряй время обработки и память.

В production Kamal направляет `/images` в imgproxy на том же HTTPS-домене.
В development Rails перенаправляет на порт 8082 того же hostname — работает для браузера и адреса Android.
Настройка ключей и обновление accessory — в [деплое](deployment.md).

## Диагностика

Панели imgproxy и alert доступности добавлены в [Prometheus/Grafana](observability.md).
Смотри частоту кодов ответа, p95, `imgproxy_errors_total` и загрузку обработчиков.
Локальный процесс — `overmind connect images`; production — `bin/kamal image-logs`.
Сервис пишет JSON уровня error. Логи сервиса могут содержать краткоживущие подписанные URL;
доступ к ним должен быть ограничен, перед внешней передачей URL и IP нужно удалить.

Источники: [imgproxy-rails](https://github.com/imgproxy/imgproxy-rails),
[настройки imgproxy](https://docs.imgproxy.net/configuration/options),
[стек Evil Martians](https://evilmartians.com/rails-startup-stack#image-processing).
