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
subprojects {
    project.evaluationDependsOn(":app")
}

// Several plugins still compile against an older Android SDK — file_picker,
// share_plus, connectivity_plus, flutter_secure_storage, video_compress and
// flutter_image_compress_common hardcode 34/35 — while
// `flutter_plugin_android_lifecycle` now requires every library that depends on
// it to compile against 36. Gradle's AAR metadata check fails on the mismatch,
// which is why `:file_picker:checkDebugAarMetadata` aborted every build.
//
// Compiling a plugin against a newer SDK is safe (the Android APIs are
// additive), so raise them all to the app's compileSdk here rather than
// waiting on six upstream releases. The legacy BaseExtension type is what
// `android.newDsl=false` in gradle.properties keeps in force; modules without
// an Android extension (such as :gradle) are skipped. Applied once, after every
// project has been evaluated, because evaluationDependsOn above can already have
// evaluated a module by the time this script's blocks run.
gradle.projectsEvaluated {
    subprojects.forEach { sp ->
        (sp.extensions.findByName("android") as? com.android.build.gradle.BaseExtension)
            ?.compileSdkVersion(36)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
