import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../data/quiz_data.dart';
import '../../theme/app_theme.dart';
import '../../services/ad_service.dart';
import 'widgets/quiz_question_widget.dart';
import 'widgets/quiz_result_widget.dart';
import 'widgets/quiz_category_widget.dart';

/// Dini Bilgi Yarışması ana ekranı
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Quiz durumu
  bool _isQuizStarted = false;
  bool _isQuizFinished = false;
  String _selectedCategory = 'Tümü';
  int _questionCount = 10;
  
  // Quiz verileri
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int? _selectedAnswerIndex;
  bool _answerSubmitted = false;
  
  // Zamanlayıcı
  Timer? _timer;
  int _timeLeft = 30;
  int _totalTime = 0;
  
  // En yüksek skor
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore(int score) async {
    if (score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_high_score', score);
      setState(() {
        _highScore = score;
      });
    }
  }

  void _startQuiz() {
    setState(() {
      _isQuizStarted = true;
      _isQuizFinished = false;
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _selectedAnswerIndex = null;
      _answerSubmitted = false;
      _totalTime = 0;
      _questions = getRandomQuestions(_questionCount, category: _selectedCategory);
    });
    _startTimer();
    HapticFeedback.mediumImpact();
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _totalTime++;
        } else {
          _submitAnswer();
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (_answerSubmitted) return;
    setState(() {
      _selectedAnswerIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  void _submitAnswer() {
    if (_answerSubmitted) return;
    
    _timer?.cancel();
    
    setState(() {
      _answerSubmitted = true;
      if (_selectedAnswerIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _correctAnswers++;
        HapticFeedback.lightImpact();
      } else {
        _wrongAnswers++;
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _answerSubmitted = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    final score = _correctAnswers * 10;
    _saveHighScore(score);
    setState(() {
      _isQuizFinished = true;
    });
    
    // Quiz tamamlandığında interstitial reklam göster
    AdService().showInterstitialAd();
  }

  void _resetQuiz() {
    setState(() {
      _isQuizStarted = false;
      _isQuizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_isQuizStarted && !_isQuizFinished) {
              _showExitConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Dini Bilgi Yarışması',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isQuizStarted && !_isQuizFinished)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 16.sp),
                  SizedBox(width: 1.w),
                  Text(
                    '$_timeLeft',
                    style: TextStyle(
                      color: _timeLeft <= 10 ? Colors.red.shade300 : Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isQuizFinished) {
      return QuizResultWidget(
        totalQuestions: _questions.length,
        correctAnswers: _correctAnswers,
        wrongAnswers: _wrongAnswers,
        totalTime: _totalTime,
        highScore: _highScore,
        onPlayAgain: _resetQuiz,
        onGoHome: () => Navigator.pop(context),
      );
    }
    
    if (_isQuizStarted) {
      return QuizQuestionWidget(
        question: _questions[_currentQuestionIndex],
        currentIndex: _currentQuestionIndex,
        totalQuestions: _questions.length,
        selectedAnswerIndex: _selectedAnswerIndex,
        answerSubmitted: _answerSubmitted,
        onSelectAnswer: _selectAnswer,
        onSubmitAnswer: _submitAnswer,
        onNextQuestion: _nextQuestion,
        correctAnswers: _correctAnswers,
        wrongAnswers: _wrongAnswers,
      );
    }
    
    return QuizCategoryWidget(
      selectedCategory: _selectedCategory,
      questionCount: _questionCount,
      highScore: _highScore,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
      onQuestionCountChanged: (count) {
        setState(() {
          _questionCount = count;
        });
      },
      onStartQuiz: _startQuiz,
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yarışmadan Çık'),
        content: const Text('Yarışmadan çıkmak istediğinize emin misiniz? İlerlemeniz kaybolacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Çık', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
