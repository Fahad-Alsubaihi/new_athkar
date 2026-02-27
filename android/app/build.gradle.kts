// 🔹 Added for loading keystore properties (Release signing)
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔹 Load key.properties file (used for release signing)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.alsubaihiapps.athkar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

      // ✅ Required for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.alsubaihiapps.athkar"

        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔹 Added: Release signing configuration using key.properties
    signingConfigs {
        create("release") {
            // 🔹 Read values safely and fail with clear message if missing
            val keyAliasVal = keystoreProperties.getProperty("keyAlias")
                ?: throw GradleException("Missing 'keyAlias' in android/key.properties")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
                ?: throw GradleException("Missing 'keyPassword' in android/key.properties")
            val storeFileVal = keystoreProperties.getProperty("storeFile")
                ?: throw GradleException("Missing 'storeFile' in android/key.properties")
            val storePasswordVal = keystoreProperties.getProperty("storePassword")
                ?: throw GradleException("Missing 'storePassword' in android/key.properties")

            keyAlias = keyAliasVal
            keyPassword = keyPasswordVal
            storeFile = file(storeFileVal)
            storePassword = storePasswordVal
        }
    }


    buildTypes {
        release {
            // ❌ Old config (was using debug signing)
            // signingConfig = signingConfigs.getByName("debug")

            // ✅ Now using release signing config
            signingConfig = signingConfigs.getByName("release")

            // 🔹 Optional but recommended for Play Store
            isMinifyEnabled = true
            isShrinkResources = true

            // 🔹 Proguard rules for code optimization
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // ✅ Core library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
