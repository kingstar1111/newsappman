# 📰 News Aggregator App

A multi-source news aggregator app built with Flutter, designed for users of all ages with a focus on simplicity and accessibility.

تطبيق تجميع الأخبار من مصادر متعددة، مبني بـ Flutter، مصمم لجميع الأعمار مع التركيز على البساطة وسهولة الاستخدام.

Flutter ile oluşturulmuş, sadelik ve erişilebilirliğe odaklanan, tüm yaş grupları için tasarlanmış çoklu kaynaklı haber toplama uygulaması.

---

## 📋 Table of Contents | الفهرس | İçindekiler

- [Features](#-features--المميزات--özellikler)
- [Technologies](#-technologies--التقنيات--teknolojiler)
- [Architecture](#-architecture--البنية--mimari)
- [Installation](#-installation--التثبيت--kurulum)
- [youtube video](https://www.youtube.com/watch?v=XoNXc6OlyiM)
- [sunum](https://github.com/kingstar1111/newsappman/edit/main/) 

---

## ✨ Features | المميزات | Özellikler

### 🇬🇧 English

| Feature | Description |
|---------|-------------|
| 📡 **Multiple Sources** | Combine news from NewsAPI + custom RSS feeds |
| 🌍 **Multi-Language** | Full support for Arabic, English, and Turkish |
| 🌙 **Dark Mode** | Eye-friendly dark theme |
| ⭐ **Favorites** | Save articles for later reading |
| 🔗 **Share** | Share articles via other apps |
| 📂 **7 Categories** | General, Business, Entertainment, Health, Science, Sports, Technology |
| 🔍 **Search** | Search within saved favorites |
| 📖 **Full Article** | Read full articles in WebView or extract content |
| 💾 **Offline Cache** | Read cached articles without internet |
| 🎨 **Adaptive Fonts** | Cairo for Arabic, Nunito for Turkish, Lato for English |

### 🇸🇦 العربية

| الميزة | الوصف |
|--------|-------|
| 📡 **مصادر متعددة** | دمج الأخبار من NewsAPI + مصادر RSS مخصصة |
| 🌍 **متعدد اللغات** | دعم كامل للعربية والإنجليزية والتركية |
| 🌙 **الوضع الداكن** | ثيم داكن مريح للعين |
| ⭐ **المفضلة** | حفظ المقالات للقراءة لاحقاً |
| 🔗 **المشاركة** | مشاركة المقالات عبر التطبيقات الأخرى |
| 📂 **7 فئات** | عام، أعمال، ترفيه، صحة، علوم، رياضة، تكنولوجيا |
| 🔍 **البحث** | البحث داخل المفضلة المحفوظة |
| 📖 **المقال الكامل** | قراءة المقال كاملاً في WebView أو استخراج المحتوى |
| 💾 **التخزين المؤقت** | قراءة المقالات المخزنة بدون إنترنت |
| 🎨 **خطوط متكيفة** | Cairo للعربية، Nunito للتركية، Lato للإنجليزية |

### 🇹🇷 Türkçe

| Özellik | Açıklama |
|---------|----------|
| 📡 **Çoklu Kaynaklar** | NewsAPI + özel RSS akışlarından haberleri birleştirme |
| 🌍 **Çoklu Dil** | Arapça, İngilizce ve Türkçe için tam destek |
| 🌙 **Karanlık Mod** | Göz dostu karanlık tema |
| ⭐ **Favoriler** | Makaleleri daha sonra okumak için kaydetme |
| 🔗 **Paylaşım** | Makaleleri diğer uygulamalarla paylaşma |
| 📂 **7 Kategori** | Genel, İş Dünyası, Eğlence, Sağlık, Bilim, Spor, Teknoloji |
| 🔍 **Arama** | Kaydedilen favorilerde arama |
| 📖 **Tam Makale** | WebView'da veya içerik çıkararak tam makaleleri okuma |
| 💾 **Çevrimdışı Önbellek** | İnternetsiz önbelleğe alınmış makaleleri okuma |
| 🎨 **Uyarlanabilir Yazı Tipleri** | Arapça için Cairo, Türkçe için Nunito, İngilizce için Lato |

---

## 🛠️ Technologies | التقنيات | Teknolojiler

### Core Stack

| Technology | Purpose | الغرض | Amaç |
|------------|---------|-------|------|
| **Flutter** | UI Framework | إطار الواجهة | UI Çerçevesi |
| **Dart** | Programming Language | لغة البرمجة | Programlama Dili |
| **Riverpod** | State Management | إدارة الحالة | Durum Yönetimi |
| **Hive** | Local Storage | التخزين المحلي | Yerel Depolama |
| **Dio** | HTTP Client | عميل HTTP | HTTP İstemcisi |

### Key Packages

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management with providers |
| `hive_flutter` | Fast NoSQL local database |
| `dio` | HTTP client for API requests |
| `xml` | RSS feed parsing |
| `easy_localization` | Multi-language support |
| `cached_network_image` | Image caching |
| `webview_flutter` | In-app article viewing |
| `share_plus` | Share functionality |
| `google_fonts` | Custom fonts (Cairo, Nunito, Lato) |

---

## 🏗️ Architecture | البنية | Mimari

```
lib/
├── core/
│   ├── constants/      # API Keys & Config
│   ├── network/        # Dio HTTP Client
│   └── storage/        # Hive Service
│
└── features/
    └── news/
        ├── data/
        │   ├── model/      # Article, NewsSource
        │   └── repository/ # NewsRepository
        │
        └── presentation/
            ├── providers/  # Riverpod Providers
            ├── screens/    # UI Screens (7 screens)
            └── widgets/    # Reusable Components
```

### Design Patterns | أنماط التصميم | Tasarım Kalıpları

- **Clean Architecture** - Separation of data, domain, and presentation layers
- **Repository Pattern** - Abstract data source access
- **Provider Pattern** - Reactive state management

---

## 📱 Screens | الشاشات | Ekranlar

| Screen | Description | الوصف | Açıklama |
|--------|-------------|-------|----------|
| **NewsScreen** | Main news feed | الصفحة الرئيسية | Ana haber akışı |
| **ArticleDetailScreen** | Article details & content | تفاصيل المقال | Makale detayları |
| **FavoritesScreen** | Saved articles | المفضلة | Favoriler |
| **SettingsScreen** | App settings & preferences | الإعدادات | Ayarlar |
| **WebViewScreen** | Full article in browser | المقال في المتصفح | Tarayıcıda makale |
| **ManageSourcesScreen** | RSS sources management | إدارة المصادر | Kaynak yönetimi |
| **AddSourceScreen** | Add new RSS source | إضافة مصدر | Kaynak ekle |

---

## 🚀 Installation | التثبيت | Kurulum

### Prerequisites | المتطلبات | Gereksinimler

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code

### Steps | الخطوات | Adımlar

```bash
# Clone the repository
git clone https://github.com/yourusername/newsappman.git

# Navigate to project directory
cd newsappman

# Install dependencies
flutter pub get

# Generate code (Hive adapters, Riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Configuration | الإعداد | Yapılandırma

1. Get a free API key from [NewsAPI.org](https://newsapi.org/)
2. Create `lib/core/constants/app_secrets.dart`:

```dart
class AppSecrets {
  static const String newsApiKey = 'YOUR_API_KEY_HERE';
}
```

---

## 📊 Statistics | الإحصائيات | İstatistikler

| Metric | Value |
|--------|-------|
| **Screens** | 7 |
| **Languages** | 3 (AR, EN, TR) |
| **Categories** | 7 |
| **Providers** | 6+ |
| **Supported Platforms** | Android, iOS |

---

## 📝 License | الترخيص | Lisans

This project is for educational purposes.

هذا المشروع لأغراض تعليمية.

Bu proje eğitim amaçlıdır.

---

## 👨‍💻 Author | المطور | Geliştirici

Made with ❤️ using Flutter

صُنع بـ ❤️ باستخدام Flutter

Flutter kullanılarak ❤️ ile yapıldı
