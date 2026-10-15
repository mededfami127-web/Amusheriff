import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing ─────────────────────────────────────────────────────────
// The upload keystore is never committed. It reaches the build in one of two
// ways, both of which land in `android/key.properties`:
//
//   * locally  — create the keystore, point `android/key.properties` at it;
//   * in CI     — `ANDROID_KEYSTORE_BASE64` is decoded back into a .jks by
//                 `.github/workflows/build.yml` (see README → Release signing).
//
// When neither is present the release build falls back to the debug keys, so
// `flutter build apk --release` still works for local smoke tests. A
// debug-signed AAB cannot be uploaded to Play, which is why CI warns loudly.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

val hasReleaseSigning: Boolean = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
).all { !keystoreProperties.getProperty(it).isNullOrBlank() }

// Resolved here, against the script's own `Project` receiver, so the signing
// config never depends on how a nested lambda would resolve `file()`.
val releaseStoreFile: File? =
    keystoreProperties.getProperty("storeFile")?.let { file(it) }

android {
    namespace = "com.amusheriff.amu_sharif_majlis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Play Store identity. Deliberately different from `namespace` above:
        // the namespace is the package holding MainActivity and the R class,
        // while the applicationId is what Play and the device key on. Keeping
        // them apart avoids relocating the Kotlin source tree for a rename.
        applicationId = "com.amusheriff.myapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // 26 rather than Flutter's default 24: sentry_flutter 10 declares
        // minSdkVersion 26 and the manifest merger refuses a smaller app value.
        // That is the price of the built-in-Kotlin migration that unblocked the
        // Android build; it drops Android 7.x (API 24-25).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // `releaseStoreFile` may be an absolute path (what CI writes) or
                // a path relative to `android/app`.
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
