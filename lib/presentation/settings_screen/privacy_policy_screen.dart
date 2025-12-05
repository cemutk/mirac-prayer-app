import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Web'de barındırılan gizlilik politikası linki
  static const String privacyPolicyUrl = 'https://doc-hosting.flycricket.io/mirac-namaz-vakti-kible-privacy-policy/093a4de9-6046-4eff-8ee5-d0ee50c8e3a1/privacy';

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Tarayıcıda Aç',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Center(
                child: Column(
                  children: [
                    Icon(Icons.privacy_tip, size: 48, color: theme.colorScheme.primary),
                    SizedBox(height: 1.h),
                    Text(
                      'Gizlilik Politikası',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Mirac Prayer Assistant',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              
              _buildSection(
                theme,
                'Giriş',
                'Mirac Prayer Assistant ("Uygulama") olarak kullanıcılarımızın gizliliğine büyük önem veriyoruz. Bu Gizlilik Politikası, uygulamayı kullandığınızda hangi bilgileri topladığımızı, nasıl kullandığımızı ve koruduğumuzu açıklamaktadır.',
              ),
              
              _buildSection(
                theme,
                '1. Toplanan Bilgiler',
                '''a) Konum Verileri
• Namaz vakitlerini hesaplamak için konumunuz kullanılır
• Kıble yönünü belirlemek için konum erişimi gereklidir
• Yakındaki camileri bulmak için konum verileri işlenir
• Seferi Mod için GPS tabanlı mesafe hesaplaması yapılır

b) Cihaz Bilgileri
• Cihaz modeli ve işletim sistemi versiyonu
• Uygulama performansı için anonim kullanım istatistikleri

c) Kamera Erişimi
• AR Kıble modu için kamera kullanılır
• Helal Gıda Kontrolü için barkod tarama
• Fotoğraf veya video kaydedilmez

d) Depolama
• Kullanıcı tercihleri cihazda yerel olarak saklanır
• Tesbih sayıları ve istatistikler cihazda tutulur''',
              ),
              
              _buildSection(
                theme,
                '2. Bilgilerin Kullanımı',
                '''Topladığımız bilgiler şu amaçlarla kullanılır:
• Namaz vakitlerini doğru hesaplamak
• Kıble yönünü belirlemek
• Yakındaki camileri göstermek
• Bildirim göndermek (izninizle)
• Uygulama deneyimini iyileştirmek
• Hataları tespit etmek ve düzeltmek''',
              ),
              
              _buildSection(
                theme,
                '3. Reklam ve Analitik',
                '''• Google AdMob üzerinden reklam gösterilmektedir
• Reklamlar kişiselleştirilmiş olabilir (cihaz ayarlarınıza bağlı)
• Anonim kullanım istatistikleri toplanabilir
• Premium kullanıcılara reklam gösterilmez''',
              ),
              
              _buildSection(
                theme,
                '4. Üçüncü Taraf Hizmetler',
                '''Uygulamamız şu üçüncü taraf hizmetleri kullanmaktadır:
• Google AdMob (reklam)
• Open Food Facts API (helal gıda kontrolü)
• OpenStreetMap (cami bulma)
• Google Play Hizmetleri

Bu hizmetlerin kendi gizlilik politikaları geçerlidir.''',
              ),
              
              _buildSection(
                theme,
                '5. Veri Güvenliği',
                '''• Tüm veriler şifreli olarak iletilir
• Kişisel verileriniz sunucularımızda saklanmaz
• Kullanıcı tercihleri yalnızca cihazınızda tutulur
• Üçüncü taraflarla kişisel veri paylaşımı yapılmaz''',
              ),
              
              _buildSection(
                theme,
                '6. Çocukların Gizliliği',
                '''• Uygulamamız tüm yaş gruplarına uygundur
• 13 yaş altı çocuklardan bilerek kişisel bilgi toplamayız
• Çocuk Modu, eğitici içerik sunmak için tasarlanmıştır''',
              ),
              
              _buildSection(
                theme,
                '7. Haklarınız',
                '''Şu haklara sahipsiniz:
• Uygulama izinlerini istediğiniz zaman iptal edebilirsiniz
• Yerel verileri uygulama ayarlarından silebilirsiniz
• Bildirimleri kapatabilirsiniz
• Konum erişimini kısıtlayabilirsiniz''',
              ),
              
              _buildSection(
                theme,
                '8. Politika Değişiklikleri',
                'Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir.',
              ),
              
              _buildSection(
                theme,
                '9. İletişim',
                '''Gizlilikle ilgili sorularınız için:
📧 E-posta: privacy@miracprayer.com
🌐 Web: https://miracprayerassistant.github.io''',
              ),
              
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Son Güncelleme: 2 Aralık 2025',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Bu politikayı kabul ederek uygulamayı kullanmaya devam edebilirsiniz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
