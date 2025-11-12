# ============================================
# Alenwan App - ProGuard Rules (Complete)
# ============================================

# --- Flutter Core ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**
-keep class androidx.lifecycle.DefaultLifecycleObserver

# --- Video Player Plugin ---
-keep class io.flutter.plugins.videoplayer.** { *; }
-dontwarn io.flutter.plugins.videoplayer.**

# --- ExoPlayer (media3) ---
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**

# --- Play Core ---
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# --- Firebase ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# --- Networking (OkHttp, Dio) ---
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# --- Gson ---
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# --- In-App Purchase ---
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# --- WebView ---
-keep class android.webkit.** { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}

# --- General Android ---
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.view.View

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# --- Kotlin ---
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# --- Keep line numbers for debugging ---
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# --- Remove logging in release ---
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
