import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/halal_checker_service.dart';

class HalalCheckerScreen extends StatefulWidget {
  const HalalCheckerScreen({super.key});

  @override
  State<HalalCheckerScreen> createState() => _HalalCheckerScreenState();
}

class _HalalCheckerScreenState extends State<HalalCheckerScreen> with SingleTickerProviderStateMixin {
  final HalalCheckerService _service = HalalCheckerService();
  late TabController _tabController;
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _isFlashOn = false;
  ScanResult? _lastResult; // ignore: unused_field - used for future features
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _service.initialize();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController?.dispose();
    _ingredientsController.dispose();
    _productNameController.dispose();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _startScanning() {
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() {
      _isScanning = true;
      _lastResult = null;
    });
  }

  void _stopScanning() {
    _scannerController?.dispose();
    _scannerController = null;
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;
    
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    // Taramayı durdur ve sonucu göster
    _stopScanning();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ürün bilgileri yükleniyor...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Fetch product from API and analyze
    final result = await _service.analyzeBarcode(barcode.rawValue!);
    
    // Close loading dialog
    if (mounted) Navigator.pop(context);
    
    setState(() {
      _lastResult = result;
    });
    
    // Show result
    _showResultDialog(result);
  }

  void _showIngredientInputDialog(String barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.qr_code_scanner, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Barkod Okundu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        barcode,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Bilgi notu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ürünün arkasındaki içerik listesini girin. E-kodları ve şüpheli maddeler otomatik tespit edilecek.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ürün adı
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Ürün Adı (Opsiyonel)',
                hintText: 'Örn: Çikolata',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // İçerik listesi
            TextField(
              controller: _ingredientsController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'İçerik Listesi',
                hintText: 'Ürünün arkasındaki içerik listesini buraya yazın veya yapıştırın...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _productNameController.clear();
                      _ingredientsController.clear();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _analyzeProduct(
                        barcode,
                        _productNameController.text,
                        _ingredientsController.text,
                      );
                      _productNameController.clear();
                      _ingredientsController.clear();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Analiz Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeProduct(String barcode, String productName, String ingredients) async {
    final result = await _service.analyzeBarcode(
      barcode,
      productName: productName.isNotEmpty ? productName : null,
      ingredients: ingredients.isNotEmpty ? ingredients : null,
    );
    
    setState(() {
      _lastResult = result;
    });
    
    // Sonuç ekranına geç
    _showResultDialog(result);
  }

  void _showResultDialog(ScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Sonuç başlığı
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildResultHeader(result),
              ),
              
              const Divider(height: 1),
              
              // Detaylar
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // API'den gelen ürün bilgileri
                    if (result.productInfo != null) ...[
                      _buildProductInfoCard(result.productInfo!),
                      const SizedBox(height: 20),
                    ],
                    
                    // Ürün bilgisi (fallback)
                    if (result.productName != null && result.productInfo == null) ...[
                      _buildInfoRow('Ürün', result.productName!),
                      const SizedBox(height: 8),
                    ],
                    _buildInfoRow('Barkod', result.barcode),
                    
                    const SizedBox(height: 20),
                    
                    // Bulunan E-kodları
                    if (result.foundECodes.isNotEmpty) ...[
                      _buildSectionTitle('Bulunan E-Kodları', Icons.warning_amber),
                      const SizedBox(height: 12),
                      ...result.foundECodes.map((e) => _buildECodeCard(e)),
                    ],
                    
                    // Şüpheli içerikler
                    if (result.foundSuspiciousIngredients.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionTitle('Şüpheli İçerikler', Icons.report_problem),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result.foundSuspiciousIngredients.map((ing) => 
                          Chip(
                            label: Text(ing),
                            backgroundColor: Colors.red.shade100,
                            labelStyle: TextStyle(color: Colors.red.shade800),
                            avatar: Icon(Icons.block, color: Colors.red.shade700, size: 16),
                          ),
                        ).toList(),
                      ),
                    ],
                    
                    // Sorun yoksa
                    if (!result.hasIssues && result.ingredients != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'İçerik listesinde bilinen şüpheli madde bulunamadı.',
                                style: TextStyle(color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // İçerik girilmediyse
                    if (result.ingredients == null || result.ingredients!.isEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'İçerik listesi girilmedi. Analiz için ürünün içindekiler kısmını girmelisiniz.',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Uyarı
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bu sonuçlar bilgilendirme amaçlıdır. Kesin bilgi için ürünün üreticisine başvurun veya helal sertifikası kontrol edin.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Alt butonlar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startScanning();
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Yeni Tarama'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Tamam'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(ScanResult result) {
    Color bgColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    switch (result.status) {
      case HalalStatus.halal:
        bgColor = Colors.green.shade100;
        iconColor = Colors.green;
        icon = Icons.check_circle;
        title = 'Helal Görünüyor';
        subtitle = 'Bilinen şüpheli madde bulunamadı';
        break;
      case HalalStatus.haram:
        bgColor = Colors.red.shade100;
        iconColor = Colors.red;
        icon = Icons.cancel;
        title = 'Haram / Şüpheli';
        subtitle = 'Yasak veya şüpheli madde tespit edildi';
        break;
      case HalalStatus.suspicious:
        bgColor = Colors.orange.shade100;
        iconColor = Colors.orange;
        icon = Icons.warning;
        title = 'Dikkatli Olun';
        subtitle = 'Kaynağı belirsiz maddeler içeriyor';
        break;
      case HalalStatus.unknown:
        bgColor = Colors.grey.shade100;
        iconColor = Colors.grey;
        icon = Icons.help_outline;
        title = 'Bilinmiyor';
        subtitle = 'İçerik listesi analiz edilemedi';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: iconColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildECodeCard(ECodeInfo eCode) {
    Color statusColor;
    String statusText;
    
    switch (eCode.status) {
      case ECodeStatus.haram:
        statusColor = Colors.red;
        statusText = 'HARAM';
        break;
      case ECodeStatus.suspicious:
        statusColor = Colors.orange;
        statusText = 'ŞÜPHELİ';
        break;
      case ECodeStatus.halal:
        statusColor = Colors.green;
        statusText = 'HELAL';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    eCode.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    eCode.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kaynak: ${eCode.source}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              eCode.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(ProductInfo productInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ürün Bilgileri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Product Image
            if (productInfo.imageUrl != null) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    productInfo.imageUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Product Name
            if (productInfo.productName != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Ürün',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      productInfo.productName!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Brand
            if (productInfo.brand != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Marka',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      productInfo.brand!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Categories
            if (productInfo.categories != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      productInfo.categories!,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Ingredients text
            if (productInfo.ingredients != null && productInfo.ingredients!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'İçindekiler',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      productInfo.ingredients!,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helal Gıda Kontrolü'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Tara'),
            Tab(icon: Icon(Icons.list_alt), text: 'E-Kodları'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(),
          _buildECodesTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return Column(
      children: [
        // Tarayıcı alanı
        Expanded(
          flex: 3,
          child: _isScanning
              ? Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onBarcodeDetected,
                    ),
                    // Overlay
                    CustomPaint(
                      painter: ScannerOverlayPainter(),
                      child: const SizedBox.expand(),
                    ),
                    // Flash ve kapat butonları
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'flash',
                            onPressed: () {
                              _scannerController?.toggleTorch();
                              setState(() => _isFlashOn = !_isFlashOn);
                            },
                            backgroundColor: _isFlashOn ? Colors.yellow : Colors.white,
                            child: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: _isFlashOn ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton.small(
                            heroTag: 'close',
                            onPressed: _stopScanning,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Bilgi yazısı
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Barkodu çerçeveye hizalayın',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Barkod Tarayıcı',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ürünün barkodunu okutarak\nhelal kontrolü yapın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _startScanning,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Taramayı Başlat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => _showManualInputDialog(),
                          icon: const Icon(Icons.edit),
                          label: const Text('Manuel Giriş'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        
        // Alt bilgi
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ürünün arkasındaki barkodu okutun, ardından içerik listesini girin.',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showManualInputDialog() {
    _showIngredientInputDialog('manuel-giris');
  }

  Widget _buildECodesTab() {
    final haramCodes = _service.getHaramECodes();
    final suspiciousCodes = _service.getSuspiciousECodes();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: const TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: 'Haram E-Kodları'),
                Tab(text: 'Şüpheli E-Kodları'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Haram kodları
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: haramCodes.length,
                  itemBuilder: (context, index) => _buildECodeCard(haramCodes[index]),
                ),
                // Şüpheli kodları
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suspiciousCodes.length,
                  itemBuilder: (context, index) => _buildECodeCard(suspiciousCodes[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_service.scanHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Henüz tarama yapılmadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Taradığınız ürünler burada görünecek',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Temizle butonu
        if (_service.scanHistory.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Geçmişi Temizle'),
                      content: const Text('Tüm tarama geçmişi silinecek. Emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _service.clearHistory();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Temizle'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Temizle'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _service.scanHistory.length,
            itemBuilder: (context, index) {
              final item = _service.scanHistory[index];
              return _buildHistoryCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(ScanHistory item) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (item.status) {
      case HalalStatus.halal:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Helal';
        break;
      case HalalStatus.haram:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Haram';
        break;
      case HalalStatus.suspicious:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Şüpheli';
        break;
      case HalalStatus.unknown:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Bilinmiyor';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDate(item.scanTime)} • ${item.barcode}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} dk önce';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} saat önce';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Tarayıcı overlay painter
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Koyu overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Köşe çizgileri
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;

    // Sol üst
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Sağ üst
    canvas.drawLine(Offset(left + scanAreaSize, top), Offset(left + scanAreaSize - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top), Offset(left + scanAreaSize, top + cornerLength), cornerPaint);

    // Sol alt
    canvas.drawLine(Offset(left, top + scanAreaSize), Offset(left + cornerLength, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanAreaSize), Offset(left, top + scanAreaSize - cornerLength), cornerPaint);

    // Sağ alt
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize), Offset(left + scanAreaSize - cornerLength, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize), Offset(left + scanAreaSize, top + scanAreaSize - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
