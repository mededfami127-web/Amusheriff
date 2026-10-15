allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Several plugins still compile against an older Android SDK — file_picker,
// share_plus, connectivity_plus, flutter_secure_storage, video_compress and
// flutter_image_compress_common hardcode 34/35 — while
// `flutter_plugin_android_lifecycle` now requires every library that depends on
// it to compile against 36. Gradle's AAR metadata check fails on the mismatch,
// which is why `:file_picker:checkDebugAarMetadata` aborted every build.
//
// Compiling a plugin against a newer SDK is safe (the Android APIs are
// additive), so raise every Android module to the app's compileSdk instead of
// waiting on six upstream releases.
//
// Ordering is the whole trick, so both mistakes are recorded here:
//   * registering this block *after* evaluationDependsOn(:app) throws
//     "Cannot run Project.afterEvaluate when the project is already evaluated";
//   * applying it in `gradle.projectsEvaluated` throws "It is too late to set
//     compileSdk — it has already been read to configure this project".
// Hooks fire in registration order, so registering here — before anything is
// evaluated — puts ours ahead of AGP's own afterEvaluate, which is where
// compileSdk gets read. Modules without an Android extension (:gradle) are
// skipped by the null-safe extension lookup.
subprojects {
    afterEvaluate {
        (extensions.findByName("android") as? com.android.build.gradle.BaseExtension)
            ?.compileSdkVersion(36)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
