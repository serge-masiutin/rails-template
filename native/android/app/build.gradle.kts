import java.net.URI
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
}

val productionUrl = providers.gradleProperty("starterapp.productionUrl")
val developmentUrl = providers.gradleProperty("starterapp.developmentUrl").orElse("http://10.0.2.2:3000")
fun quotedUrl(value: String): String {
    val uri = URI(value)
    require(uri.scheme in listOf("http", "https") && !uri.host.isNullOrBlank()) { "Некорректный URL StarterApp" }
    require(uri.rawUserInfo == null && uri.rawQuery == null && uri.rawFragment == null) { "URL должен содержать только адрес сервера" }
    return "\"$value\""
}

android {
    namespace = "com.example.starterapp"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.example.starterapp"
        minSdk = 28
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.0"
    }
    // Включаем только опубликованные языки, в том числе для ресурсов SDK.
    androidResources { localeFilters += setOf("en") }
    buildFeatures { buildConfig = true }
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            buildConfigField("String", "BASE_URL", quotedUrl(developmentUrl.get()))
        }
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            if (productionUrl.isPresent) {
                buildConfigField("String", "BASE_URL", quotedUrl(productionUrl.get()))
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }
dependencyLocking { lockAllConfigurations() }

tasks.register("validateProductionUrl") {
    doLast {
        check(productionUrl.isPresent) { "Задайте -Pstarterapp.productionUrl=https://ваш-домен" }
        check(URI(productionUrl.get()).scheme == "https") { "Release требует HTTPS" }
    }
}
tasks.matching { it.name == "preReleaseBuild" }.configureEach { dependsOn("validateProductionUrl") }

dependencies {
    constraints {
        implementation("com.google.errorprone:error_prone_annotations:2.50.0") {
            because("Старые аннотации с javax.lang.model.element.Modifier ломают Android R8; google/error-prone#5386")
        }
    }
    implementation("dev.hotwire:core:1.3.1")
    implementation("dev.hotwire:navigation-fragments:1.3.1")
    implementation("com.google.android.material:material:1.14.0")
}
