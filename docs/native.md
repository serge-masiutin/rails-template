# Android

**StarterApp** uses Hotwire Native and the shared Rails UI.
Release ID: `com.example.starterapp`. Debug ID: `com.example.starterapp.debug`.

The APK bundles Martian Mono for native UI; WebView uses the Rails [font layer](architecture.md#typography).
Use `Theme.StarterApp` and `TextAppearance.StarterApp.*` for new native elements.

## Build

Install JDK 21 and Android SDK 36. Set `ANDROID_HOME` to the SDK directory.
A running web app is required for device verification. On macOS:

```sh
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
cd native/android
./gradlew assembleDebug lintDebug
```

Debug uses `http://10.0.2.2:3000` from the emulator. For a physical device, build with your computer's LAN address:

```sh
./gradlew assembleDebug -Pstarterapp.developmentUrl=http://192.168.1.20:3000
```

Replace the example address with your own. From the project root, start the server on that interface:

```sh
WEB_HOST=192.168.1.20 ANYCABLE_BIND=192.168.1.20 IMGPROXY_BIND_ADDRESS=192.168.1.20 mise exec -- bin/dev
```

Rails listens on `0.0.0.0:3000`; AnyCable exposes 8080 and imgproxy 8082 on the specified interface.
Image redirects preserve the Android host. Use a trusted network shared by the computer and device.
HTTP is allowed only in Debug. Release requires HTTPS:

```sh
./gradlew assembleRelease -Pstarterapp.productionUrl=https://app.your-domain.com
```

APKs are in `app/build/outputs/apk`. Configure your own keystore before publishing.
AGP 9 uses built-in Kotlin; do not apply `org.jetbrains.kotlin.android` separately.
The compiler is pinned in root `buildscript`; the Gradle wrapper includes its SHA-256.
Upgrade AGP, compiler, and wrapper together using the
[compatibility table](https://developer.android.com/build/releases/agp-9-4-0-release-notes)
and [Kotlin migration guide](https://developer.android.com/build/migrate-to-built-in-kotlin).
Versions are recorded in build files and `app/gradle.lockfile`. Regenerate locks with `--write-locks`
and review changes. The Error Prone constraint prevents an R8 failure
([upstream fix](https://github.com/google/error-prone/pull/5386)).

## Navigation

[android_v1.json](../public/configurations/android_v1.json) is public and defines navigation rules.
Profile and password-reset forms open modally without pull-to-refresh. After edits, run from the root:

```sh
mise exec -- bin/native sync
mise exec -- bin/native check
```

The SDK starts with the bundled configuration, then uses its cache and the remote version.
This does not make application data available offline. Publish incompatible rules as v2 and retain v1
for installed clients.

## Device verification

WebView uses the same [AnyCable client](realtime.md) and cookies as the browser.
Release connects to `wss://<domain>/cable`. Check reconnection and fresh content after returning
from the background. Delivery to a closed app requires FCM; WebSocket does not replace push.
FCM is not configured.

Check sign-in, incorrect password, profile, modal dismissal, sign-out, password reset,
system Back, and recovery after network loss. APK builds and Native User-Agent tests do not replace this pass.

Native strings live in `res/values/strings.xml`. Only English is shipped; the resource filter
also excludes SDK translations. Coordinate additional languages with [Rails i18n](architecture.md#interface-languages).
