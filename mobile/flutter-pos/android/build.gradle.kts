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

subprojects {
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        val javaTaskName = name.replace("Kotlin", "JavaWithJavac")
        val javaTask = project.tasks.findByName(javaTaskName) as? org.gradle.api.tasks.compile.JavaCompile
        val javaTarget = javaTask?.targetCompatibility?.toString() ?: "17"
        val target = when (javaTarget) {
            "1.8" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
            "11" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
            "17" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
            "21" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
            else -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
        compilerOptions {
            jvmTarget.set(target)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
