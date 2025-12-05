import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mosque_data.dart';
import '../../services/mosque_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/mosque_amenity_chip.dart';
import 'widgets/mosque_review_widget.dart';
import 'widgets/add_review_dialog.dart';

class MosqueDetailScreen extends StatefulWidget {
  final Mosque mosque;
  final VoidCallback? onFavoriteToggle;

  const MosqueDetailScreen({
    super.key,
    required this.mosque,
    this.onFavoriteToggle,
  });

  @override
  State<MosqueDetailScreen> createState() => _MosqueDetailScreenState();
}

class _MosqueDetailScreenState extends State<MosqueDetailScreen> {
  final MosqueService _mosqueService = MosqueService();
  List<MosqueReview> _reviews = [];
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reviews = await _mosqueService.getReviews(widget.mosque.id);
    final isFavorite = await _mosqueService.isFavorite(widget.mosque.id);

    setState(() {
      _reviews = reviews;
      _isFavorite = isFavorite;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _mosqueService.toggleFavorite(widget.mosque.id);
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle?.call();
  }

  Future<void> _openNavigation({bool walking = false}) async {
    final url = walking
        ? _mosqueService.getWalkingNavigationUrl(widget.mosque)
        : _mosqueService.getNavigationUrl(widget.mosque);

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareMosque() {
    final text = '''
🕌 ${widget.mosque.name}

📍 ${widget.mosque.address}

⭐ Puan: ${widget.mosque.averageRating.toStringAsFixed(1)} (${widget.mosque.totalRatings} değerlendirme)

${widget.mosque.amenities.isNotEmpty ? '✨ İmkanlar:\n${widget.mosque.amenities.map((a) => '${a.icon} ${a.displayName}').join('\n')}' : ''}

📲 Mirac Prayer Assistant ile paylaşıldı
''';

    Share.share(text);
  }

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.mosque.address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adres kopyalandı'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _addReview() async {
    final result = await showDialog<MosqueReview>(
      context: context,
      builder: (context) => AddReviewDialog(mosqueId: widget.mosque.id),
    );

    if (result != null) {
      await _mosqueService.addReview(result);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorumunuz eklendi! Teşekkürler.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildActionButtons()),
          SliverToBoxAdapter(child: _buildAmenities()),
          SliverToBoxAdapter(child: _buildInfo()),
          SliverToBoxAdapter(child: _buildReviewsSection()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareMosque,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryDark.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: const Icon(
                Icons.mosque,
                size: 80,
                color: Colors.white24,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.mosque.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              if (widget.mosque.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Doğrulanmış',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.mosque.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${widget.mosque.totalRatings} değerlendirme)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (widget.mosque.distanceInKm != null) ...[
                const Spacer(),
                Icon(Icons.location_on, size: 18, color: AppTheme.accentGold),
                const SizedBox(width: 4),
                Text(
                  '${widget.mosque.distanceInKm!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _copyAddress,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.mosque.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Icon(Icons.copy, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openNavigation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.directions_car),
              label: const Text('Araçla Git'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openNavigation(walking: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryDark,
                side: const BorderSide(color: AppTheme.primaryDark),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.directions_walk),
              label: const Text('Yürüyerek Git'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    if (widget.mosque.amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryDark, size: 20),
              SizedBox(width: 8),
              Text(
                'İmkanlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.mosque.amenities.map((amenity) {
              return MosqueAmenityChip(amenity: amenity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryDark, size: 20),
              SizedBox(width: 8),
              Text(
                'Detaylar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.mosque.phone != null)
            _buildInfoRow(Icons.phone, 'Telefon', widget.mosque.phone!),
          if (widget.mosque.capacity != null)
            _buildInfoRow(
                Icons.people, 'Kapasite', '${widget.mosque.capacity} kişi'),
          if (widget.mosque.imamName != null)
            _buildInfoRow(Icons.person, 'İmam', widget.mosque.imamName!),
          if (widget.mosque.openingHours != null)
            _buildInfoRow(
                Icons.access_time, 'Açık Saatler', widget.mosque.openingHours!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.rate_review,
                      color: AppTheme.primaryDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Değerlendirmeler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _addReview,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yorum Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.comment_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz değerlendirme yok',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'İlk yorumu siz yapın!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _reviews.length > 5 ? 5 : _reviews.length,
              (index) => MosqueReviewWidget(review: _reviews[index]),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.mosque.distanceInKm != null) ...[
                    Text(
                      '${widget.mosque.distanceInKm!.toStringAsFixed(1)} km uzaklıkta',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '≈ ${(widget.mosque.distanceInKm! / 5 * 60).round()} dk yürüyüş',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ] else
                    const Text(
                      'Konum bilgisi yok',
                      style: TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openNavigation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.navigation),
              label: const Text('Yol Tarifi Al'),
            ),
          ],
        ),
      ),
    );
  }
}
