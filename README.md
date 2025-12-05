# Miraç - İslami Mobil Uygulama

Namaz vakitleri, Kıble pusulası, Kuran-ı Kerim, dijital tesbih ve daha fazlasını içeren kapsamlı İslami mobil uygulama.

## 📱 Uygulama Özellikleri

- ⏰ Günlük Namaz Vakitleri
- 🧭 Kıble Pusulası
- 📿 Dijital Tesbih Sayacı
- 📖 Kuran-ı Kerim (Popüler Sureler + Meal + Okunuş)
- 🕌 Dini Günler ve Kandiller
- 🌙 Esmaül Hüsna
- 🤲 Dua Koleksiyonu
- 🌸 Kadınlar için Özel Gün Modu
- 🌓 Açık/Koyu Tema Desteği

---

## 🚀 Projeyi Bilgisayarınıza İndirme

### Adım 1: Gereksinimler
Bilgisayarınızda şunların kurulu olması gerekir:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10 veya üzeri)
- [Android Studio](https://developer.android.com/studio) (Android için)
- [Xcode](https://developer.apple.com/xcode/) (iOS için - sadece Mac)
- Git

### Adım 2: Projeyi Klonlama
Terminal veya komut satırında şu komutu çalıştırın:

```bash
git clone <projenizin-git-url>
cd mirac_prayer_assistant
```

### Adım 3: Bağımlılıkları Yükleme
```bash
flutter pub get
```

---

## 🎨 Kendi Logonuzu Ekleme

### İkon için (Uygulama simgesi):

1. **256x256 piksel** boyutunda bir PNG dosyası hazırlayın
2. Dosyayı `icon.png` olarak kaydedin
3. Proje ana dizinine `assets` klasörü oluşturun (yoksa)
4. `icon.png` dosyasını `assets/` klasörüne kopyalayın

**Dosya yolu:** `assets/icon.png`

### Splash Screen için (Açılış ekranı):

1. **1242x2688 piksel** veya benzer yüksek çözünürlükte PNG dosyası hazırlayın
2. Dosyayı `splash.png` olarak kaydedin
3. Aynı `assets/` klasörüne kopyalayın

**Dosya yolu:** `assets/splash.png`

### Klasör yapısı şu şekilde olmalı:
```
mirac_prayer_assistant/
├── assets/
│   ├── icon.png       ← Uygulama ikonu (256x256)
│   └── splash.png     ← Açılış ekranı (1242x2688)
├── lib/
├── android/
├── ios/
└── pubspec.yaml
```

---

## ⚙️ İkonları ve Splash Screen'i Üretme

Logo dosyalarınızı `assets/` klasörüne ekledikten sonra, terminalde şu komutları **sırasıyla** çalıştırın:

### 1. Uygulama İkonunu Oluşturma:
```bash
flutter pub run flutter_launcher_icons
```

Bu komut:
- Android için tüm boyutlarda ikon üretir
- iOS için AppIcon setini oluşturur
- Adaptive icon (Android 8.0+) yapılandırır

### 2. Splash Screen'i Oluşturma:
```bash
flutter pub run flutter_native_splash:create
```

Bu komut:
- Android ve iOS için açılış ekranlarını yapılandırır
- Beyaz arka plan üzerine logonuzu yerleştirir
- Tüm cihaz boyutları için otomatik uyarlama yapar

### ✅ Başarılı Oldu mu Kontrol Edin:
Her iki komut da hata vermeden tamamlanırsa şu mesajları göreceksiniz:
- "✓ Successfully generated launcher icons"
- "✓ Native splash screen created successfully"

---

## 📦 APK (Android) Dosyası Oluşturma

### Release APK (Yayın için):

```bash
flutter build apk --release
```

**Çıktı:** APK dosyası şu konumda oluşur:
```
build/app/outputs/flutter-apk/app-release.apk
```

Bu dosyayı Android cihazlara kurabilir veya Google Play Store'a yükleyebilirsiniz.

### Split APK (Daha küçük boyut):
Farklı işlemci mimarileri için ayrı APK'lar oluşturmak isterseniz:

```bash
flutter build apk --split-per-abi
```

**Çıktı:** Üç farklı APK oluşur:
- `app-armeabi-v7a-release.apk` (eski cihazlar)
- `app-arm64-v8a-release.apk` (modern cihazlar)
- `app-x86_64-release.apk` (emülatörler/tabletler)

### App Bundle (Google Play için önerilen):
```bash
flutter build appbundle
```

**Çıktı:** 
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 📱 iOS için IPA Oluşturma (sadece Mac)

### Gereksinimler:
- Xcode kurulu olmalı
- Apple Developer hesabı gerekli
- Sertifika ve profil yapılandırılmış olmalı

### IPA Oluşturma:
```bash
flutter build ipa
```

**Çıktı:**
```
build/ios/ipa/Miraç.ipa
```

---

## 🧪 Test Etme

### Android Emülatör'de çalıştırma:
```bash
flutter run
```

### Fiziksel cihazda test:
1. USB hata ayıklama açık olmalı
2. Cihazı bilgisayara bağlayın
3. `flutter devices` komutuyla cihazı görün
4. `flutter run` ile uygulamayı yükleyin

---

## 🔧 Sorun Giderme

### İkon güncellenmiyor:
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### Splash screen görünmüyor:
```bash
flutter clean
flutter pub get
flutter pub run flutter_native_splash:create
flutter run
```

### Build hatası alıyorum:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release
```

---

## 📞 Destek

Herhangi bir sorun yaşarsanız veya yardıma ihtiyacınız varsa:
- GitHub Issues bölümünden destek alabilirsiniz
- Flutter dokümanlarına başvurabilirsiniz: https://flutter.dev/docs

---

## 📄 Lisans

Bu proje özel kullanım içindir. Ticari kullanım için izin gereklidir.

---

**Geliştirici Notları:**
- Proje Flutter 3.16.0 ile geliştirilmiştir
- Minimum Android sürümü: 5.0 (API 21)
- Minimum iOS sürümü: 12.0
- Paket adı: `com.mirac.prayerapp`
- Uygulama adı: **Miraç**

---

**İyi kullanımlar! 🌙✨**