import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/quiz_data.dart';
import '../../../theme/app_theme.dart';

/// Quiz soru widget'ı
class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final int? selectedAnswerIndex;
  final bool answerSubmitted;
  final Function(int) onSelectAnswer;
  final VoidCallback onSubmitAnswer;
  final VoidCallback onNextQuestion;
  final int correctAnswers;
  final int wrongAnswers;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedAnswerIndex,
    required this.answerSubmitted,
    required this.onSelectAnswer,
    required this.onSubmitAnswer,
    required this.onNextQuestion,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İlerleme ve skor
          Row(
            children: [
              // İlerleme
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soru ${currentIndex + 1}/$totalQuestions',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / totalQuestions,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDark),
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 1.h,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              // Skor
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                    SizedBox(width: 1.w),
                    Text(
                      '$correctAnswers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 14.sp),
                    SizedBox(width: 1.w),
                    Text(
                      '$wrongAnswers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Kategori ve zorluk
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.category,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDifficultyText(question.difficulty),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: _getDifficultyColor(question.difficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Soru
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppTheme.accentGold,
                    size: 12.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Seçenekler
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionCard(index, option);
          }),

          SizedBox(height: 2.h),

          // Açıklama (cevap verildikten sonra)
          if (answerSubmitted && question.explanation != null)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentGold,
                    size: 18.sp,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Açıklama',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          question.explanation!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 2.h),

          // Butonlar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: answerSubmitted
                  ? onNextQuestion
                  : (selectedAnswerIndex != null ? onSubmitAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: answerSubmitted ? AppTheme.primaryDark : AppTheme.accentGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                answerSubmitted
                    ? (currentIndex < totalQuestions - 1 ? 'Sonraki Soru' : 'Sonuçları Gör')
                    : 'Cevabı Onayla',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String option) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswerIndex;
    
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = AppTheme.primaryDark;
    IconData? icon;
    Color? iconColor;

    if (answerSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryDark.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryDark;
    }

    return GestureDetector(
      onTap: () => onSelectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isSelected || (answerSubmitted && isCorrect)
                    ? borderColor
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected || (answerSubmitted && isCorrect)
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, color: iconColor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Kolay';
      case DifficultyLevel.medium:
        return 'Orta';
      case DifficultyLevel.hard:
        return 'Zor';
    }
  }
}
