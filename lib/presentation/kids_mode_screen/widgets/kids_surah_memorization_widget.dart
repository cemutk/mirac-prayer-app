import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KidsSurahMemorizationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;
  final int Function(String surahId) getSurahProgress;
  final Function(String surahId, int progress) onProgressUpdate;

  const KidsSurahMemorizationWidget({
    super.key,
    required this.surahs,
    required this.getSurahProgress,
    required this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final progress = getSurahProgress(surah['id'] as String);
        final isCompleted = progress >= 100;

        return GestureDetector(
          onTap: () => _openSurahDetail(context, surah),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    )
                  : null,
              color: isCompleted ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.purple.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Emoji
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            surah['emoji'] as String,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bilgiler
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    surah['name'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isCompleted)
                                  const Icon(Icons.verified, color: Colors.white, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              surah['arabicName'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isCompleted
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Puan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCompleted ? '✅' : '⭐',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCompleted ? 'Tamamlandı' : '+${surah['points']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.white : Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: isCompleted
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey[200],
                      color: isCompleted ? Colors.white : Colors.purple,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(surah['verses'] as List).length} ayet',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$progress% tamamlandı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.white
                              : Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openSurahDetail(BuildContext context, Map<String, dynamic> surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SurahMemorizationScreen(
          surah: surah,
          initialProgress: getSurahProgress(surah['id'] as String),
          onProgressUpdate: (progress) {
            onProgressUpdate(surah['id'] as String, progress);
          },
        ),
      ),
    );
  }
}

class _SurahMemorizationScreen extends StatefulWidget {
  final Map<String, dynamic> surah;
  final int initialProgress;
  final Function(int progress) onProgressUpdate;

  const _SurahMemorizationScreen({
    required this.surah,
    required this.initialProgress,
    required this.onProgressUpdate,
  });

  @override
  State<_SurahMemorizationScreen> createState() => _SurahMemorizationScreenState();
}

class _SurahMemorizationScreenState extends State<_SurahMemorizationScreen> {
  late List<bool> _memorizedVerses;
  int _currentVerseIndex = 0;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    final verses = widget.surah['verses'] as List;
    final memorizedCount = (widget.initialProgress / 100 * verses.length).floor();
    _memorizedVerses = List.generate(
      verses.length,
      (index) => index < memorizedCount,
    );
  }

  int get _progress {
    final memorizedCount = _memorizedVerses.where((v) => v).length;
    return (memorizedCount / _memorizedVerses.length * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final verses = widget.surah['verses'] as List;
    final currentVerse = verses[_currentVerseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah['name'] as String,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.surah['arabicName'] as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showTranslation ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showTranslation = !_showTranslation);
            },
            tooltip: _showTranslation ? 'Meali Gizle' : 'Meali Göster',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress / 100,
                      backgroundColor: Colors.grey[300],
                      color: Colors.purple,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_progress%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Ayet sayacı
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(verses.length, (index) {
                final isMemorized = _memorizedVerses[index];
                final isCurrent = index == _currentVerseIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentVerseIndex = index);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isMemorized
                          ? Colors.green
                          : isCurrent
                              ? Colors.purple
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                      border: isCurrent
                          ? Border.all(color: Colors.purple, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isMemorized || isCurrent ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Ayet içeriği
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Arapça metin
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_currentVerseIndex + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentVerse['arabic'] as String,
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: 'Amiri',
                            height: 2,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Türkçe meal
                  AnimatedOpacity(
                    opacity: _showTranslation ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.translate, size: 16, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Türkçe Meal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentVerse['turkish'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Ezberledim butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _memorizedVerses[_currentVerseIndex] = !_memorizedVerses[_currentVerseIndex];
                      });
                      widget.onProgressUpdate(_progress);
                    },
                    icon: Icon(
                      _memorizedVerses[_currentVerseIndex]
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      _memorizedVerses[_currentVerseIndex]
                          ? 'Ezberledim ✓'
                          : 'Bu Ayeti Ezberledim',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _memorizedVerses[_currentVerseIndex]
                          ? Colors.green
                          : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigasyon
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
                if (_currentVerseIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _currentVerseIndex--);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Önceki'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentVerseIndex > 0) const SizedBox(width: 12),
                if (_currentVerseIndex < verses.length - 1)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _currentVerseIndex++);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sonraki'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentVerseIndex == verses.length - 1)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Bitir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
