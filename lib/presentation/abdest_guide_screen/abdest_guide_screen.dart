import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AbdestGuideScreen extends StatelessWidget {
  const AbdestGuideScreen({super.key});

  static const _steps = [
    {
      'title': '1. Niyet',
      'description': 'Abdest almaya niyet edin ve kalpten niyetin anlamını tekrar edin.',
    },
    {
      'title': '2. Elleri yıkama',
      'description': 'Her iki eli de bileklere kadar üç kez yıkayın, parmak aralarına dikkat edin.',
    },
    {
      'title': '3. Ağız- burun temizliği',
      'description': 'Önce ağız üç kez çalkalanır, sonra burun üç kez çekilip üflenir.',
    },
    {
      'title': '4. Yüzü yıkama',
      'description': 'Alından çeneye ve kulak kenarlarına kadar üç kez yüz yıkanır.',
    },
    {
      'title': '5. Kolları dirseklere kadar yıkama',
      'description': 'Sağ kolu dirsek dahil, sonra sol kolu üçer kere yıkayın.',
    },
    {
      'title': '6. Baş meshi',
      'description': 'Islak ellerle başı bir defa meshedin; kulak arkasını da unutmayın.',
    },
    {
      'title': '7. Ayakları yıkama',
      'description': 'Sağ ayaktan başlayarak topuklara kadar üç kez yıkayıp parmak aralarını unutmayın.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abdest Rehberi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adım adım abdest',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              LinearProgressIndicator(value: progress, minHeight: 6),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.separated(
                  itemCount: _steps.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title']!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  step['description']!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Abdest duası',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 0.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Eşhedu en la ilahe illallah ve eşhedu enne Muhammeden abduhu ve rasûluhu.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
