# OwnAdvertiser - Proje Takip Dokümanı

## Yapıldı

*   **Proje Kurulumu ve Temel Yapı:**
    *   Windsurf ile temel iOS proje yapısı oluşturuldu.
    *   Uygulama adı "OwnAdvertiser" olarak belirlendi.
*   **Ana Ekran (MainView) Arayüzü:**
    *   SwiftUI kullanılarak `MainView`'ın temel arayüzü tasarlandı (Kalan haklar, görsel seçme alanı, açıklama girişi, oluşturma butonu).
*   **Görsel Seçici Entegrasyonu:**
    *   `PHPickerViewController` kullanılarak kullanıcının galeriden görsel seçmesi sağlandı.
    *   Seçilen görsel `MainView`'da önizlendi.
*   **API Servis İskeleti:**
    *   `OpenAIService` adında ayrı bir yapı oluşturuldu.
    *   API anahtarı için güvenli saklama gerekliliği not edildi.
    *   API çağrısı için `async` fonksiyon taslağı (`generateAdvertisement`) ve temel hata enum'ı (`OpenAIError`) oluşturuldu (şimdilik simüle edilmiş gecikme ve hata ile).
*   **ViewModel Refactoring (MVVM):**
    *   `MainView` için `MainViewModel` oluşturuldu.
    *   State yönetimi ve `generateAdImage` fonksiyonu ViewModel'a taşındı.
    *   `MainView`, ViewModel'ı kullanarak güncellendi, kod temizlendi.
*   **Asenkron İşlem Yönetimi (UI):**
    *   `generateAdImage` fonksiyonu asenkron hale getirildi (`async/await`).
    *   API çağrısı sırasında `ProgressView` gösterimi eklendi.
    *   Butonun yükleme sırasında devre dışı bırakılması sağlandı.
    *   API'den veya doğrulama adımlarından dönen hataların kullanıcıya gösterilmesi (`errorMessage`) eklendi.

## Yapılacak (Sıradaki Adımlar)

*   **OpenAI API Entegrasyonu (Gerçek Çağrı):**
    *   `OpenAIService` içindeki `generateAdvertisement` fonksiyonuna gerçek OpenAI API (GPT-4o görsel+metin) çağrısını eklemek.
    *   Seçilen `UIImage`'ı API'nin beklediği formata (örn. Base64 veya yüklenmiş URL) dönüştürmek.
    *   API'den dönen başarılı yanıtı (üretilen görsel URL'si/verisi) işlemek.
*   **API Anahtarı Güvenliği:** API anahtarını koddan çıkarıp güvenli bir şekilde saklamak (örn. `Info.plist` + `.gitignore` veya başka bir yöntem).
*   **Görsel Gösterim Ekranı:** Üretilen görseli göstermek için yeni bir View (`GeneratedImageView`) oluşturmak ve başarılı API çağrısı sonrası bu ekrana yönlendirme (Navigation) yapmak.
*   **Firebase Entegrasyonu:**
    *   Firebase projesi oluşturmak ve SDK'ları eklemek.
    *   Kullanıcı kimlik doğrulama (Auth) sistemini kurmak (`LoginView`, `AuthGate`).
    *   Kullanıcı verilerini (kalan haklar vb.) ve görsel bilgilerini saklamak için Firestore kullanmak.
    *   Yüklenen ve üretilen görselleri saklamak için Firebase Storage kullanmak.
*   **Ücretlendirme Modeli:**
    *   Firestore'da ücretsiz hakları takip etmek.
    *   Apple StoreKit (In-App Purchase) entegrasyonu ile ek haklar veya abonelik satışı yapmak.
*   **Genel İyileştirmeler:**
    *   Daha detaylı hata yönetimi.
    *   UI/UX iyileştirmeleri.
    *   Kod refactoring (gerektikçe).