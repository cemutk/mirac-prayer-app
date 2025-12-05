import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/quiz_data.dart';
import '../../../theme/app_theme.dart';

/// Quiz kategori seçim widget'ı
class QuizCategoryWidget extends StatelessWidget {
  final String selectedCategory;
  final int questionCount;
  final int highScore;
  final Function(String) onCategorySelected;
  final Function(int) onQuestionCountChanged;
  final VoidCallback onStartQuiz;

  const QuizCategoryWidget({
    super.key,
    required this.selectedCategory,
    required this.questionCount,
    required this.highScore,
    required this.onCategorySelected,
    required this.onQuestionCountChanged,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartı
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
                  Icons.quiz,
                  color: AppTheme.accentGold,
                  size: 15.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Dini Bilgi Yarışması',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Bilgini test et, öğren ve eğlen!',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 2.h),
                if (highScore > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 16.sp),
                        SizedBox(width: 2.w),
                        Text(
                          'En Yüksek Skor: $highScore',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Kategori seçimi
          Text(
            'Kategori Seç',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: quizCategories.map((category) {
              final isSelected = category == selectedCategory;
              return FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryDark,
                    fontSize: 10.sp,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) => onCategorySelected(category),
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primaryDark,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryDark : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Soru sayısı
          Text(
            'Soru Sayısı',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [5, 10, 15, 20].map((count) {
              final isSelected = count == questionCount;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: ElevatedButton(
                    onPressed: () => onQuestionCountChanged(count),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppTheme.primaryDark : Colors.white,
                      foregroundColor: isSelected ? Colors.white : AppTheme.primaryDark,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryDark : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text('$count'),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Kurallar
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
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryDark, size: 18.sp),
                      SizedBox(width: 2.w),
                      Text(
                        'Yarışma Kuralları',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  _buildRuleItem('⏱️', 'Her soru için 30 saniye süreniz var'),
                  _buildRuleItem('✅', 'Doğru cevap: +10 puan'),
                  _buildRuleItem('❌', 'Yanlış cevap: 0 puan'),
                  _buildRuleItem('💡', 'Cevap verdikten sonra açıklama görürsünüz'),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Başlat butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 22.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Yarışmayı Başlat',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
