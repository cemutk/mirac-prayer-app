import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/dua_data.dart';
import '../../../theme/app_theme.dart';

/// Ayet-el Kürsi özel widget'ı - büyük ve detaylı gösterim
class AyetelKursiWidget extends StatelessWidget {
  const AyetelKursiWidget({super.key});

  void _shareAyetelKursi() {
    final ayetelKursi = allDuas.firstWhere((d) => d.id == 1);
    final text = '''
🕌 AYET-EL KÜRSİ
(Bakara Suresi, 255. Ayet)

${ayetelKursi.arabicText}

📖 Okunuşu:
${ayetelKursi.latinTranscription}

📝 Anlamı:
${ayetelKursi.turkishMeaning}

✨ Fazileti:
${ayetelKursi.benefit}

— Mirac Namaz Vakitleri Uygulaması
''';
    Share.share(text);
  }

  void _copyToClipboard(BuildContext context) {
    final ayetelKursi = allDuas.firstWhere((d) => d.id == 1);
    final text = '''
AYET-EL KÜRSİ

${ayetelKursi.arabicText}

Okunuşu: ${ayetelKursi.latinTranscription}

Anlamı: ${ayetelKursi.turkishMeaning}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ayet-el Kürsi kopyalandı'),
        backgroundColor: AppTheme.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final ayetelKursi = allDuas.firstWhere((d) => d.id == 1);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Başlık kartı
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primaryDark.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentGold,
                  size: 12.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'AYET-EL KÜRSİ',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Bakara Suresi, 255. Ayet',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.accentGold,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Kur\'an\'ın en büyük ayeti',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Arapça metin
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, color: AppTheme.primaryDark, size: 18.sp),
                      SizedBox(width: 2.w),
                      Text(
                        'Arapça Metin',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 3.h, color: AppTheme.accentGold.withValues(alpha: 0.3)),
                  Text(
                    ayetelKursi.arabicText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Amiri',
                      height: 2.2,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Okunuşu
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, color: AppTheme.primaryDark, size: 16.sp),
                      SizedBox(width: 2.w),
                      Text(
                        'Okunuşu',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    ayetelKursi.latinTranscription,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Türkçe anlam
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: AppTheme.primaryDark, size: 16.sp),
                      SizedBox(width: 2.w),
                      Text(
                        'Türkçe Anlamı',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    ayetelKursi.turkishMeaning,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Fazilet
          Card(
            elevation: 2,
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 16.sp),
                      SizedBox(width: 2.w),
                      Text(
                        'Fazileti',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    ayetelKursi.benefit ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildBenefitItem('🌙', 'Her namazdan sonra okumak'),
                        _buildBenefitItem('🛏️', 'Yatmadan önce okumak'),
                        _buildBenefitItem('🏠', 'Evden çıkarken okumak'),
                        _buildBenefitItem('🌅', 'Sabah akşam okumak'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Aksiyon butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy, color: Colors.white),
                  label: const Text('Kopyala', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareAyetelKursi,
                  icon: const Icon(Icons.share, color: AppTheme.primaryDark),
                  label: const Text('Paylaş', style: TextStyle(color: AppTheme.primaryDark)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 3.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
