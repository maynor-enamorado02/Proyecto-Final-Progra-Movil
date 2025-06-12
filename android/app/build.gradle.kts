plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Correctamente aplicado
}

android {
    namespace = "com.example.prueba"
    compileSdk = 35 // puedes ajustar según tu flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // 👈 Esto resuelve el problema del NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }


    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

 defaultConfig {
        applicationId = "com.example.prueba"
        minSdk = 23 // 👈 Esto resuelve el error de firebase_auth
        targetSdk = 35 // o usa flutter.targetSdkVersion si lo tienes
        versionCode = 1
        versionName = "1.0.0"
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

dependencies {
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Agrega aquí otros productos de Firebase si los necesitas
}
