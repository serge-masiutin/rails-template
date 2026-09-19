buildscript {
    repositories { mavenCentral() }
    dependencies {
        // AGP 9 compiles Kotlin directly; set the compiler version without kotlin-android.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.20")
    }
}

plugins {
    id("com.android.application") version "9.4.1" apply false
}
