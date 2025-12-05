import 'package:flutter/material.dart';
import '../../services/quran_service.dart';
import 'surah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({Key? key}) : super(key: key);

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _service = QuranService();
  late Future<List<Map<String, dynamic>>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = _service.getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuran')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _surahsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Hata: ${snap.error}'));
          final surahs = snap.data ?? [];
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = surahs[index];
              return ListTile(
                title: Text('${s['number']}. ${s['name_ar']}'),
                subtitle: Text(s['name_en'] ?? ''),
                onTap: () async {
                  final surah = await _service.getSurah(s['number'] as int);
                  if (surah != null) {
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SurahScreen(surah: surah),
                    ));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
