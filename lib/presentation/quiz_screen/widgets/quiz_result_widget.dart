import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../theme/app_theme.dart';

/// Quiz sonuç widget'ı
class QuizResultWidget extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalTime;
  final int highScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const QuizResultWidget({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalTime,
    required this.highScore,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  int get score => correctAnswers * 10;
  double get successRate => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  bool get isNewHighScore => score >= highScore && score > 0;

  String get resultEmoji {
    if (successRate >= 90) return '🏆';
    if (successRate >= 70) return '🌟';
    if (successRate >= 50) return '👍';
    return '💪';
  }

  String get resultMessage {
    if (successRate >= 90) return 'Mükemmel!';
    if (successRate >= 70) return 'Harika!';
    if (successRate >= 50) return 'İyi iş!';
    if (successRate >= 30) return 'Daha iyi olabilir';
    return 'Pratik yapmaya devam et!';
  }

  void _shareResult() {
    final text = '''
🕌 Dini Bilgi Yarışması Sonucum

📊 Skor: $score puan
✅ Doğru: $correctAnswers
❌ Yanlış: $wrongAnswers
⏱️ Süre: ${_formatTime(totalTime)}
📈 Başarı: %${successRate.toStringAsFixed(0)}

$resultEmoji $resultMessage

— Mirac Namaz Vakitleri Uygulaması
''';
    Share.share(text);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Sonuç kartı
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primaryDark.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Yeni rekor badge
                if (isNewHighScore)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14.sp),
                        SizedBox(width: 1.w),
                        Text(
                          'YENİ REKOR!',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  resultEmoji,
                  style: TextStyle(fontSize: 50.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  resultMessage,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Yarışmayı tamamladınız!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 3.h),

                // Skor
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SKOR',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      Text(
                        'puan',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // İstatistikler
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  label: 'Doğru',
                  value: '$correctAnswers',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  label: 'Yanlış',
                  value: '$wrongAnswers',
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  iconColor: Colors.blue,
                  label: 'Süre',
                  value: _formatTime(totalTime),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  iconColor: Colors.orange,
                  label: 'Başarı',
                  value: '%${successRate.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Başarı grafiği
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başarı Oranı',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: successRate / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        successRate >= 70
                            ? Colors.green
                            : successRate >= 50
                                ? Colors.orange
                                : Colors.red,
                      ),
                      minHeight: 2.h,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$correctAnswers / $totalQuestions doğru',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '%${successRate.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share, color: AppTheme.primaryDark),
                  label: Text(
                    'Paylaş',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 12.sp,
                    ),
                  ),
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

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGoHome,
                  icon: Icon(Icons.home, color: AppTheme.primaryDark, size: 18.sp),
                  label: Text(
                    'Ana Sayfa',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 12.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    side: BorderSide(color: AppTheme.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: Icon(Icons.replay, color: Colors.white, size: 18.sp),
                  label: Text(
                    'Tekrar Oyna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
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

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(height: 1.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
