buildscript {
    repositories { mavenCentral() }
    dependencies {
        // AGP 9 компилирует Kotlin сам; версия компилятора задаётся без kotlin-android plugin.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.20")
    }
}

plugins {
    id("com.android.application") version "9.4.1" apply false
}
