plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "it.mypetcare.my_pet_care"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "it.mypetcare.my_pet_care"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Production version from pubspec.yaml
        versionCode = 100
        versionName = "1.0.0"
    }

    // Signing configurations for release builds
    signingConfigs {
        release {
            storeFile file(keystoreProperties['storeFile'] ?: System.getenv("KEYSTORE_FILE") ?: "../keystore/upload.jks")
            storePassword keystoreProperties['storePassword'] ?: System.getenv("KS_PASS")
            keyAlias keystoreProperties['keyAlias'] ?: System.getenv("ALIAS") ?: "upload"
            keyPassword keystoreProperties['keyPassword'] ?: System.getenv("ALIAS_PASS")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled = true
            shrinkResources = true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source = "../.."
}
