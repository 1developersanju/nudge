plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lognreview"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.lognreview"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Smaller APKs for sharing (e.g. WhatsApp): from repo root prefer one of:
    //   flutter build apk --release --split-per-abi
    //     → build/app/outputs/flutter-apk/app-*-release.apk (pick arm64 for most phones).
    //   flutter build apk --release --target-platform=android-arm64
    //     → one APK, smallest common choice (64-bit ARM only).
    buildTypes {
        release {
            // TODO: Replace with your release keystore before Play Store upload.
            // Debug signing is fine for local `flutter build apk --release` smoke tests.
            signingConfig = signingConfigs.getByName("debug")
            // Keep off unless you add ProGuard keep rules for plugins (notifications, WorkManager).
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required by flutter_local_notifications (java.time APIs on older minSdk).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
