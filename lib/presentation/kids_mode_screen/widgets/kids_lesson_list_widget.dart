import 'package:flutter/material.dart';
import '../../../services/kids_mode_service.dart';

class KidsLessonListWidget extends StatelessWidget {
  final List<KidsLesson> lessons;
  final String category;
  final String categoryTitle;
  final Color categoryColor;
  final Function(String lessonId, int points) onLessonComplete;
  final bool Function(String lessonId) isLessonCompleted;

  const KidsLessonListWidget({
    super.key,
    required this.lessons,
    required this.category,
    required this.categoryTitle,
    required this.categoryColor,
    required this.onLessonComplete,
    required this.isLessonCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final sortedLessons = List<KidsLesson>.from(lessons)
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedLessons.length,
      itemBuilder: (context, index) {
        final lesson = sortedLessons[index];
        final isCompleted = isLessonCompleted(lesson.id);
        final isLocked = index > 0 && !isLessonCompleted(sortedLessons[index - 1].id);

        return _buildLessonCard(context, lesson, isCompleted, isLocked, index + 1);
      },
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    KidsLesson lesson,
    bool isCompleted,
    bool isLocked,
    int number,
  ) {
    return GestureDetector(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔒 Önce önceki dersi tamamla!'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          : () => _openLesson(context, lesson, isCompleted),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey[200]
              : isCompleted
                  ? Colors.green[50]
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : isLocked
                    ? Colors.grey[300]!
                    : categoryColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Numara veya kilit
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isLocked
                          ? Colors.grey[400]
                          : categoryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : isLocked
                          ? const Icon(Icons.lock, color: Colors.white, size: 24)
                          : Text(
                              '$number',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lesson.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isLocked ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '+${lesson.points} puan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${lesson.steps.length} adım',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ok
              Icon(
                isCompleted
                    ? Icons.replay
                    : isLocked
                        ? Icons.lock_outline
                        : Icons.arrow_forward_ios,
                color: isCompleted
                    ? Colors.green
                    : isLocked
                        ? Colors.grey
                        : categoryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, KidsLesson lesson, bool isCompleted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _KidsLessonDetailScreen(
          lesson: lesson,
          categoryColor: categoryColor,
          isCompleted: isCompleted,
          onComplete: () {
            if (!isCompleted) {
              onLessonComplete(lesson.id, lesson.points);
            }
          },
        ),
      ),
    );
  }
}

class _KidsLessonDetailScreen extends StatefulWidget {
  final KidsLesson lesson;
  final Color categoryColor;
  final bool isCompleted;
  final VoidCallback onComplete;

  const _KidsLessonDetailScreen({
    required this.lesson,
    required this.categoryColor,
    required this.isCompleted,
    required this.onComplete,
  });

  @override
  State<_KidsLessonDetailScreen> createState() => _KidsLessonDetailScreenState();
}

class _KidsLessonDetailScreenState extends State<_KidsLessonDetailScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.lesson.steps[_currentStep];
    final isLastStep = _currentStep == widget.lesson.steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        title: Text(widget.lesson.title),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentStep + 1}/${widget.lesson.steps.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / widget.lesson.steps.length,
            backgroundColor: Colors.grey[200],
            color: widget.categoryColor,
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Emoji
                  if (step.imageEmoji != null)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: Text(
                          step.imageEmoji!,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Başlık
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // İçerik kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.categoryColor.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      step.content,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigasyon butonları
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Geri'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.categoryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isLastStep) {
                        widget.onComplete();
                        Navigator.pop(context);
                      } else {
                        setState(() => _currentStep++);
                      }
                    },
                    icon: Icon(isLastStep ? Icons.check_circle : Icons.arrow_forward),
                    label: Text(isLastStep ? 'Tamamla!' : 'İleri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastStep ? Colors.green : widget.categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
