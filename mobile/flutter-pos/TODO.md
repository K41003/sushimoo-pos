# TODO - Flutter tidak bisa jalan (Android build failure)

- [x] Cari penyebab error: build Gradle gagal
- [x] Hilangkan `afterEvaluate` di `android/build.gradle.kts` (error: afterEvaluate already evaluated)
- [x] Perbaiki masalah `pubspec.yaml` (indentasi dependency)
- [x] Tangani error baru: `blue_thermal_printer` butuh `namespace` (AGP 8+)
  - [x] Samakan AGP/Gradle/Kotlin ke versi template Flutter 3.41 (AGP 8.11.1, Gradle 8.14, Kotlin 2.2.20)
  - [x] Patch plugin `blue_thermal_printer` (tambah `namespace`, ganti dep `com.android.support`/zxing 3.6.0 ke AndroidX)
  - [x] Bereskan error download Gradle 7.5 (lock/stale cache di `android/.gradle`) - bersihkan folder `.gradle/7.5` & `8.14`
  - [x] Build sukses: `flutter build apk --debug` -> `app-debug.apk`
- [ ] Jalankan `flutter run -d emulator-5554` (butuh emulator aktif)
