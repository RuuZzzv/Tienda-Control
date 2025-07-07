# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter embedding
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Google Play Core - FIX PARA EL ERROR
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# SQLite
-keep class io.sqflite.** { *; }
-keep class com.tekartik.** { *; }

# Keep your models
-keep class com.example.tienda_control.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep public classes that extend Exception
-keep public class * extends java.lang.Exception

# Provider y ChangeNotifier
-keep class ** extends androidx.lifecycle.ViewModel { *; }
-keep class ** implements android.os.Parcelable { *; }

# SharedPreferences
-keep class androidx.preference.** { *; }

# Gson (si se usa)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# R8 optimization rules
-allowaccessmodification
-repackageclasses