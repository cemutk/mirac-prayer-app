import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../data/dua_data.dart';
import '../../../theme/app_theme.dart';

/// Dua kartı widget'ı - genişletilebilir
class DuaCardWidget extends StatefulWidget {
  final Dua dua;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;

  const DuaCardWidget({
    super.key,
    required this.dua,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onShare,
  });

  @override
  State<DuaCardWidget> createState() => _DuaCardWidgetState();
}

class _DuaCardWidgetState extends State<DuaCardWidget> {
  bool _isExpanded = false;

  void _copyToClipboard() {
    final text = '''
${widget.dua.title}

${widget.dua.arabicText}

Okunuşu: ${widget.dua.latinTranscription}

Anlamı: ${widget.dua.turkishMeaning}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dua kopyalandı'),
        backgroundColor: AppTheme.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve aksiyonlar
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.dua.category,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : Colors.grey,
                      size: 20.sp,
                    ),
                    onPressed: widget.onFavoriteToggle,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(1.w),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: Colors.grey,
                      size: 18.sp,
                    ),
                    onPressed: _copyToClipboard,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(1.w),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey,
                      size: 18.sp,
                    ),
                    onPressed: widget.onShare,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(1.w),
                  ),
                ],
              ),
              
              SizedBox(height: 1.h),
              
              // Dua başlığı
              Text(
                widget.dua.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              
              SizedBox(height: 1.5.h),
              
              // Arapça metin
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.dua.arabicText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Amiri',
                    height: 2,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              
              // Genişletilmiş içerik
              if (_isExpanded) ...[
                SizedBox(height: 2.h),
                
                // Okunuşu
                _buildSection(
                  icon: Icons.record_voice_over,
                  title: 'Okunuşu',
                  content: widget.dua.latinTranscription,
                  isItalic: true,
                ),
                
                SizedBox(height: 1.5.h),
                
                // Türkçe anlam
                _buildSection(
                  icon: Icons.translate,
                  title: 'Anlamı',
                  content: widget.dua.turkishMeaning,
                ),
                
                SizedBox(height: 1.5.h),
                
                // Kaynak
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 14.sp, color: AppTheme.primaryDark),
                    SizedBox(width: 2.w),
                    Text(
                      'Kaynak: ',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.dua.source,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Fazilet
                if (widget.dua.benefit != null) ...[
                  SizedBox(height: 1.5.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16.sp,
                          color: AppTheme.accentGold,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fazileti',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                widget.dua.benefit!,
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
                ],
              ],
              
              // Genişlet/Daralt indikatörü
              SizedBox(height: 1.h),
              Center(
                child: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    bool isItalic = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: AppTheme.primaryDark),
            SizedBox(width: 2.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 6.w),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade800,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
