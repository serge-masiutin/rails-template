# Android

**StarterApp** использует Hotwire Native и общий Rails-интерфейс.
Release ID — `com.example.starterapp`, Debug — `com.example.starterapp.debug`.

Martian Mono встроен в APK для нативного интерфейса; WebView использует общий
[шрифтовой слой Rails](architecture.md#типографика). Для новых нативных элементов
используй `Theme.StarterApp` и `TextAppearance.StarterApp.*`.

## Сборка

Нужны JDK 21, Android SDK 36 и запущенное веб-приложение для проверки на устройстве.
Задай `ANDROID_HOME` — путь к установленному SDK. На macOS:

```sh
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
cd native/android
./gradlew assembleDebug lintDebug
```

Debug обращается к `http://10.0.2.2:3000` из эмулятора.
Для физического устройства собери APK с LAN-адресом компьютера:

```sh
./gradlew assembleDebug -Pstarterapp.developmentUrl=http://192.168.1.20:3000
```

Адрес в примере замени на свой. Из корня проекта запусти сервер для этого адреса:

```sh
WEB_HOST=192.168.1.20 ANYCABLE_BIND=192.168.1.20 IMGPROXY_BIND_ADDRESS=192.168.1.20 mise exec -- bin/dev
```

Rails слушает `0.0.0.0:3000`; AnyCable открывает порт 8080, imgproxy — 8082 на указанном LAN-интерфейсе.
Изображения используют тот же HTML; сервер сохраняет hostname Android при локальном перенаправлении.
Устройство и компьютер должны быть в одной доверенной сети.
HTTP разрешён только в Debug. Release требует HTTPS-адрес:

```sh
./gradlew assembleRelease -Pstarterapp.productionUrl=https://app.your-domain.com
```

APK находятся в `app/build/outputs/apk`. Перед публикацией Release настрой подпись своим keystore.
Версии — в build files и `app/gradle.lockfile`; при обновлении зависимостей пересоздай lockfile
с `--write-locks` и проверь diff. Constraint для Error Prone устраняет сбой R8
([исправление библиотеки](https://github.com/google/error-prone/pull/5386)).

## Навигация

[android_v1.json](../public/configurations/android_v1.json) доступен без входа и задаёт правила переходов.
Профиль и формы восстановления пароля открываются модально без pull-to-refresh.
После изменения выполни из корня проекта:

```sh
mise exec -- bin/native sync
mise exec -- bin/native check
```

SDK начинает с конфигурации из APK, затем использует кэш и серверную версию.
Это не обеспечивает доступ к данным без сети. Несовместимые правила выпускай как v2,
сохраняя v1 для установленных клиентов.

## Проверка на устройстве

WebView использует тот же [клиент AnyCable](realtime.md) и cookie, что и веб.
В Release WebSocket доступен по `wss://<домен>/cable`. После возвращения из фона
проверь восстановление соединения и актуальность экрана. Доставка сообщений в закрытое
приложение требует FCM; WebSocket не заменяет push, FCM пока не подключён.

Проверь вход, неверный пароль, профиль, закрытие модального экрана, выход,
сброс пароля, системную кнопку back и восстановление после потери сети.
Сборка APK и серверный тест с Native User-Agent не заменяют этот проход.
Последние выполненные проверки — в [журнале](intent-log.md).
