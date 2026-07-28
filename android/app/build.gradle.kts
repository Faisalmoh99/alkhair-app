plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alkhair.alkhair_app"
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
        // Single real Firebase project (alkhair-bisha-dev) — see ARCHITECTURE.md §6.
        applicationId = "com.alkhair.alkhair_app.dev"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Shared debug-only keystore (android/debug.keystore, committed — see
        // ARCHITECTURE.md §6) so every teammate signs debug builds with the
        // same certificate, instead of each machine auto-generating its own
        // and needing its SHA-1/SHA-256 individually registered in Firebase
        // Console for real (non-test) phone-number sign-in to work.
        // Deliberately scoped to the debug buildType only — NOT reused by
        // release below, which keeps using AGP's own machine-local default
        // "debug" signingConfig so committing this file doesn't change what
        // release builds are signed with.
        create("sharedDebug") {
            storeFile = file("../debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("sharedDebug")
        }
        release {
            // TODO(Phase 2): Replace debug signing with a real keystore.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
