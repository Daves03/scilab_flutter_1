allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("${project.rootDir}/unityLibrary/libs")
        }
    }
}

subprojects {
    afterEvaluate {
        val subproject = this
        if (subproject.hasProperty("android")) {
            val android = subproject.property("android") as com.android.build.gradle.BaseExtension
            android.compileSdkVersion(36)
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
