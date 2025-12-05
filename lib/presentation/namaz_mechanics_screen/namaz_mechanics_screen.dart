import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NamazMechanicsScreen extends StatelessWidget {
  const NamazMechanicsScreen({super.key});

  static const _tips = [
    'Saf’a girerken önünüzdeki kişilerle omuz hizası korunmalı.',
    'Seccadenizi Qibla’ya paralel yerleştirip, ön ayaklarınız hizalanmalı.',
    'Eller omuz hizasında, dirsekler göğüse yakın tutulmalı.',
    'Rükû’da sırt düz, secdeye inerken alnı tam yere değecek şekilde eğilin.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Mekaniği'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Column(
            children: [
              _buildVisualGuide(theme),
              SizedBox(height: 2.h),
              Text(
                'Saf’ta duruş',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.5.h),
              _buildTipsList(theme),
              const Spacer(),
              _buildReminderCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualGuide(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Text(
            'Kıble ve Seccade simulasyonu',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
          Stack(
            alignment: Alignment.center,
            children: [
                  Container(
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(31),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.navigation, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    width: 20.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withAlpha(102),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Seccade',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Seccadeniz kenarlarıyla Qıble yönü arasında paralellik kurmalı.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsList(ThemeData theme) {
    return Column(
      children: _tips
          .map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 10, color: theme.colorScheme.primary),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReminderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mini Görev',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Namazdan önce kıbleyi kontrol et, seccadenin düzlüğünü hafifçe elle düzelt.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
