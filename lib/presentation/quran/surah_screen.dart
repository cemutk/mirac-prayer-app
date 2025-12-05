import 'package:flutter/material.dart';

class SurahScreen extends StatelessWidget {
  final Map<String, dynamic> surah;
  const SurahScreen({Key? key, required this.surah}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verses = (surah['verses'] as List).cast<Map<String, dynamic>>();
    return Scaffold(
      appBar: AppBar(title: Text('${surah['number']}. ${surah['name_ar']}')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final v = verses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0,2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${v['verseNumber']}.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  v['arabic'] ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 22, height: 1.6),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
