plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tienda_control"
    compileSdk = 34  // Usar la última versión estable
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.tienda_control"
        minSdk = 21  // Mínimo recomendado para mejor performance
        targetSdk = 34  // Última versión estable
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Optimizaciones para mejor performance
        multiDexEnabled = true
        
        // Configuración de ProGuard para release
        ndk {
            abiFilters("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        debug {
            // Mantener símbolos de debug pero optimizar
            minifyEnabled = false
            shrinkResources = false
        }
        
        release {
            // Optimizaciones para release
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Optimizaciones de build
    buildFeatures {
        buildConfig = true
    }
    
    packagingOptions {
        exclude("META-INF/DEPENDENCIES")
        exclude("META-INF/LICENSE")
        exclude("META-INF/LICENSE.txt")
        exclude("META-INF/NOTICE")
        exclude("META-INF/NOTICE.txt")
    }
}

flutter {
    source = "../.."
}

// Configuración adicional de dependencias
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}