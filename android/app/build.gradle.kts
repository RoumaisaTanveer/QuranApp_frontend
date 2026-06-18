import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val appConfig = Properties()
val appConfigFile = rootProject.file("../app_config.properties")
if (appConfigFile.exists()) {
    appConfig.load(FileInputStream(appConfigFile))
}

val androidAppId = appConfig.getProperty("ANDROID_APP_ID", "com.quranjournal.quran_journal")
val appDisplayName = appConfig.getProperty("APP_DISPLAY_NAME", "Quran Journal")
val googleWebClientId = appConfig.getProperty("GOOGLE_WEB_CLIENT_ID", "")

android {
    namespace = "com.quranjournal.quran_journal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = androidAppId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "app_name", appDisplayName)
        if (googleWebClientId.isNotEmpty()) {
            resValue("string", "default_web_client_id", googleWebClientId)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
