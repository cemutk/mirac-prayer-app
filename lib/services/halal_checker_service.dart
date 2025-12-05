import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helal Gıda Kontrol Servisi
/// Barkod okuma ve E-kodu analizi yapar
class HalalCheckerService extends ChangeNotifier {
  static final HalalCheckerService _instance = HalalCheckerService._internal();
  factory HalalCheckerService() => _instance;
  HalalCheckerService._internal();

  List<ScanHistory> _scanHistory = [];
  List<ScanHistory> get scanHistory => _scanHistory;

  /// Open Food Facts API ile ürün bilgilerini çek
  Future<ProductInfo?> fetchProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          
          return ProductInfo(
            barcode: barcode,
            productName: product['product_name'] ?? 'Bilinmeyen Ürün',
            brand: product['brands'] ?? '',
            ingredients: product['ingredients_text'] ?? '',
            ingredientsList: (product['ingredients'] as List?)?.map((e) => e['text']?.toString() ?? '').toList() ?? [],
            categories: product['categories'] ?? '',
            imageUrl: product['image_url'] ?? '',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Ürün bilgisi alınamadı: $e');
      return null;
    }
  }

  /// Şüpheli/Haram E-kodları veritabanı (200+ E-kodu)
  static const Map<String, ECodeInfo> eCodeDatabase = {
    // ============ HARAM - Kesinlikle Yasak ============
    
    // Böcek Kaynaklı
    'E120': ECodeInfo(
      code: 'E120',
      name: 'Karmin / Cochineal',
      source: 'Böcek (Cochineal böceği)',
      status: ECodeStatus.haram,
      description: 'Kırmızı renk verici. Cochineal böceğinden elde edilir.',
    ),
    'E904': ECodeInfo(
      code: 'E904',
      name: 'Shellac / Şellak',
      source: 'Böcek (Lac böceği)',
      status: ECodeStatus.haram,
      description: 'Parlatıcı. Lac böceğinin salgısından elde edilir.',
    ),
    
    // Domuz Kaynaklı
    'E441': ECodeInfo(
      code: 'E441',
      name: 'Jelatin',
      source: 'Hayvansal (Genellikle domuz)',
      status: ECodeStatus.haram,
      description: 'Jöle kıvamı verici. Çoğunlukla domuz derisinden üretilir.',
    ),
    'E542': ECodeInfo(
      code: 'E542',
      name: 'Kemik Fosfat',
      source: 'Hayvansal kemik',
      status: ECodeStatus.haram,
      description: 'Hayvan kemiklerinden elde edilen fosfat.',
    ),
    
    // İnsan Saçı/Hayvan Kılı
    'E910': ECodeInfo(
      code: 'E910',
      name: 'L-sistein',
      source: 'İnsan saçı veya domuz kılı',
      status: ECodeStatus.haram,
      description: 'Hamur yumuşatıcı. İnsan saçı veya hayvan kılından.',
    ),
    'E920': ECodeInfo(
      code: 'E920',
      name: 'L-sistein hidroklorür',
      source: 'İnsan saçı veya domuz kılı',
      status: ECodeStatus.haram,
      description: 'E910 ile aynı kaynak.',
    ),
    'E921': ECodeInfo(
      code: 'E921',
      name: 'L-sistin',
      source: 'Hayvansal',
      status: ECodeStatus.haram,
      description: 'Amino asit, genellikle hayvansal kaynak.',
    ),
    'E924': ECodeInfo(
      code: 'E924',
      name: 'Potasyum Bromat',
      source: 'Kimyasal',
      status: ECodeStatus.haram,
      description: 'Birçok ülkede yasaklanmış. Kanser riski.',
    ),
    
    // Alkol İçeren
    'E1510': ECodeInfo(
      code: 'E1510',
      name: 'Etanol / Etil Alkol',
      source: 'Alkol',
      status: ECodeStatus.haram,
      description: 'Çözücü. İçki yapımında kullanılan alkol.',
    ),
    'E1518': ECodeInfo(
      code: 'E1518',
      name: 'Gliseril Triasetat (Triacetin)',
      source: 'Gliserol türevi',
      status: ECodeStatus.haram,
      description: 'Alkol türevi çözücü.',
    ),
    
    // ŞÜPHELI - Kaynağına bağlı
    'E101': ECodeInfo(
      code: 'E101',
      name: 'Riboflavin (B2)',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Vitamin B2. Kaynağı bitkisel veya hayvansal olabilir.',
    ),
    'E153': ECodeInfo(
      code: 'E153',
      name: 'Karbon Siyahı',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Siyah renk verici. Kemik kömürü olabilir.',
    ),
    'E161g': ECodeInfo(
      code: 'E161g',
      name: 'Kantaksantin',
      source: 'Sentetik veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Turuncu renk verici.',
    ),
    'E252': ECodeInfo(
      code: 'E252',
      name: 'Potasyum Nitrat',
      source: 'Mineral/sentetik',
      status: ECodeStatus.suspicious,
      description: 'Koruyucu. Et ürünlerinde kullanılır.',
    ),
    'E322': ECodeInfo(
      code: 'E322',
      name: 'Lesitin',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Soya veya yumurtadan elde edilir.',
    ),
    'E422': ECodeInfo(
      code: 'E422',
      name: 'Gliserol / Gliserin',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Nem tutucu. Bitkisel veya hayvansal yağlardan.',
    ),
    'E431': ECodeInfo(
      code: 'E431',
      name: 'Polioksietilen Stearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Kaynağı belirsiz olabilir.',
    ),
    'E432': ECodeInfo(
      code: 'E432',
      name: 'Polisorbat 20',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Yağ asidi kaynağı önemli.',
    ),
    'E433': ECodeInfo(
      code: 'E433',
      name: 'Polisorbat 80',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Oleik asit kaynağı önemli.',
    ),
    'E434': ECodeInfo(
      code: 'E434',
      name: 'Polisorbat 40',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E435': ECodeInfo(
      code: 'E435',
      name: 'Polisorbat 60',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E436': ECodeInfo(
      code: 'E436',
      name: 'Polisorbat 65',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E470a': ECodeInfo(
      code: 'E470a',
      name: 'Sodyum/Potasyum Stearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Stearik asit kaynağı önemli.',
    ),
    'E470b': ECodeInfo(
      code: 'E470b',
      name: 'Magnezyum Stearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Anti-topaklanma ajanı.',
    ),
    'E471': ECodeInfo(
      code: 'E471',
      name: 'Mono ve Digliseritler',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Gliserin ve yağ asidi kaynağı önemli.',
    ),
    'E472a': ECodeInfo(
      code: 'E472a',
      name: 'Asetik Asit Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E472b': ECodeInfo(
      code: 'E472b',
      name: 'Laktik Asit Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E472c': ECodeInfo(
      code: 'E472c',
      name: 'Sitrik Asit Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E472e': ECodeInfo(
      code: 'E472e',
      name: 'Tartarik Asit Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E473': ECodeInfo(
      code: 'E473',
      name: 'Sukroz Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E474': ECodeInfo(
      code: 'E474',
      name: 'Sukrogliseritler',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E475': ECodeInfo(
      code: 'E475',
      name: 'Poligliserol Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E476': ECodeInfo(
      code: 'E476',
      name: 'Poligliserol Polirisinoleat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Çikolatada yaygın.',
    ),
    'E477': ECodeInfo(
      code: 'E477',
      name: 'Propilen Glikol Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E478': ECodeInfo(
      code: 'E478',
      name: 'Laktilat Esterleri',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E481': ECodeInfo(
      code: 'E481',
      name: 'Sodyum Stearoil Laktilat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör. Ekmekte yaygın.',
    ),
    'E482': ECodeInfo(
      code: 'E482',
      name: 'Kalsiyum Stearoil Laktilat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E483': ECodeInfo(
      code: 'E483',
      name: 'Stearil Tartrat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E491': ECodeInfo(
      code: 'E491',
      name: 'Sorbitan Monostearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E492': ECodeInfo(
      code: 'E492',
      name: 'Sorbitan Tristearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E493': ECodeInfo(
      code: 'E493',
      name: 'Sorbitan Monolaurat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E494': ECodeInfo(
      code: 'E494',
      name: 'Sorbitan Monooleat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E495': ECodeInfo(
      code: 'E495',
      name: 'Sorbitan Monopalmitat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Emülgatör.',
    ),
    'E570': ECodeInfo(
      code: 'E570',
      name: 'Stearik Asit',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Yağ asidi. Bitkisel veya hayvansal yağlardan.',
    ),
    'E572': ECodeInfo(
      code: 'E572',
      name: 'Magnezyum Stearat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Anti-topaklanma.',
    ),
    'E585': ECodeInfo(
      code: 'E585',
      name: 'Demir Laktat',
      source: 'Laktik asit kaynağı belirsiz',
      status: ECodeStatus.suspicious,
      description: 'Renk sabitleyici.',
    ),
    'E631': ECodeInfo(
      code: 'E631',
      name: 'Disodyum İnosinat',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı. Hayvansal kaynaklı olabilir.',
    ),
    'E635': ECodeInfo(
      code: 'E635',
      name: 'Disodyum 5-ribonükleotit',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E640': ECodeInfo(
      code: 'E640',
      name: 'Glisin',
      source: 'Hayvansal veya sentetik',
      status: ECodeStatus.suspicious,
      description: 'Amino asit.',
    ),
    'E901': ECodeInfo(
      code: 'E901',
      name: 'Balmumu',
      source: 'Arı',
      status: ECodeStatus.suspicious,
      description: 'Parlatıcı. Arı ürünü.',
    ),
    'E913': ECodeInfo(
      code: 'E913',
      name: 'Lanolin',
      source: 'Koyun yünü',
      status: ECodeStatus.suspicious,
      description: 'Parlatıcı. Koyun yünü yağı.',
    ),
    'E966': ECodeInfo(
      code: 'E966',
      name: 'Laktitol',
      source: 'Süt şekeri',
      status: ECodeStatus.suspicious,
      description: 'Tatlandırıcı. Laktozdan üretilir.',
    ),
    
    // Daha fazla şüpheli E-kodları
    'E100': ECodeInfo(
      code: 'E100',
      name: 'Kurkumin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Sarı renk verici. Zerdeçaldan elde edilir.',
    ),
    'E102': ECodeInfo(
      code: 'E102',
      name: 'Tartrazin',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Sarı renk verici. Alerji yapabilir.',
    ),
    'E104': ECodeInfo(
      code: 'E104',
      name: 'Kinolin Sarısı',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Sarı renk verici.',
    ),
    'E110': ECodeInfo(
      code: 'E110',
      name: 'Sunset Yellow',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Turuncu renk verici.',
    ),
    'E122': ECodeInfo(
      code: 'E122',
      name: 'Azorubin',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici.',
    ),
    'E123': ECodeInfo(
      code: 'E123',
      name: 'Amarant',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici. Birçok ülkede yasaklı.',
    ),
    'E124': ECodeInfo(
      code: 'E124',
      name: 'Ponceau 4R',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici.',
    ),
    'E127': ECodeInfo(
      code: 'E127',
      name: 'Eritrosin',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici.',
    ),
    'E129': ECodeInfo(
      code: 'E129',
      name: 'Allura Red',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici.',
    ),
    'E131': ECodeInfo(
      code: 'E131',
      name: 'Patent Blue V',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Mavi renk verici.',
    ),
    'E132': ECodeInfo(
      code: 'E132',
      name: 'Indigotin',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Mavi renk verici.',
    ),
    'E133': ECodeInfo(
      code: 'E133',
      name: 'Brilliant Blue',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Mavi renk verici.',
    ),
    'E140': ECodeInfo(
      code: 'E140',
      name: 'Klorofil',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Yeşil renk verici.',
    ),
    'E141': ECodeInfo(
      code: 'E141',
      name: 'Bakır Klorofil',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Yeşil renk verici.',
    ),
    'E142': ECodeInfo(
      code: 'E142',
      name: 'Green S',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Yeşil renk verici.',
    ),
    'E150a': ECodeInfo(
      code: 'E150a',
      name: 'Karamel I',
      source: 'Bitkisel (şeker)',
      status: ECodeStatus.halal,
      description: 'Kahverengi renk verici.',
    ),
    'E150b': ECodeInfo(
      code: 'E150b',
      name: 'Karamel II',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kahverengi renk verici.',
    ),
    'E150c': ECodeInfo(
      code: 'E150c',
      name: 'Karamel III',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kahverengi renk verici.',
    ),
    'E150d': ECodeInfo(
      code: 'E150d',
      name: 'Karamel IV',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kahverengi renk verici.',
    ),
    'E160a': ECodeInfo(
      code: 'E160a',
      name: 'Karoten',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Turuncu renk verici. Havuçtan elde edilir.',
    ),
    'E160b': ECodeInfo(
      code: 'E160b',
      name: 'Annatto',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Turuncu renk verici.',
    ),
    'E160c': ECodeInfo(
      code: 'E160c',
      name: 'Kapsantin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Turuncu renk verici.',
    ),
    'E160d': ECodeInfo(
      code: 'E160d',
      name: 'Likopen',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici. Domateslerden.',
    ),
    'E160e': ECodeInfo(
      code: 'E160e',
      name: 'Beta-apokarotenal',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Turuncu renk verici.',
    ),
    'E161b': ECodeInfo(
      code: 'E161b',
      name: 'Lutein',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Sarı renk verici.',
    ),
    'E162': ECodeInfo(
      code: 'E162',
      name: 'Pancar Kırmızısı',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kırmızı renk verici. Pancardan.',
    ),
    'E163': ECodeInfo(
      code: 'E163',
      name: 'Antosiyanin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Mor/kırmızı renk verici. Üzümden.',
    ),
    'E170': ECodeInfo(
      code: 'E170',
      name: 'Kalsiyum Karbonat',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Beyaz renk verici. Tebeşir.',
    ),
    'E171': ECodeInfo(
      code: 'E171',
      name: 'Titanyum Dioksit',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Beyaz renk verici.',
    ),
    'E172': ECodeInfo(
      code: 'E172',
      name: 'Demir Oksit',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Kahverengi/kırmızı renk verici.',
    ),
    'E175': ECodeInfo(
      code: 'E175',
      name: 'Altın',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Dekoratif parlatıcı.',
    ),
    'E200': ECodeInfo(
      code: 'E200',
      name: 'Sorbik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E201': ECodeInfo(
      code: 'E201',
      name: 'Sodyum Sorbat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E202': ECodeInfo(
      code: 'E202',
      name: 'Potasyum Sorbat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E210': ECodeInfo(
      code: 'E210',
      name: 'Benzoik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E211': ECodeInfo(
      code: 'E211',
      name: 'Sodyum Benzoat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E220': ECodeInfo(
      code: 'E220',
      name: 'Kükürt Dioksit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu. Astımlılar dikkat.',
    ),
    'E250': ECodeInfo(
      code: 'E250',
      name: 'Sodyum Nitrit',
      source: 'Sentetik',
      status: ECodeStatus.suspicious,
      description: 'Koruyucu. Et ürünlerinde. Yüksek dozda zararlı.',
    ),
    'E251': ECodeInfo(
      code: 'E251',
      name: 'Sodyum Nitrat',
      source: 'Sentetik',
      status: ECodeStatus.suspicious,
      description: 'Koruyucu. Et ürünlerinde.',
    ),
    'E260': ECodeInfo(
      code: 'E260',
      name: 'Asetik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu. Sirke.',
    ),
    'E270': ECodeInfo(
      code: 'E270',
      name: 'Laktik Asit',
      source: 'Süt veya sentetik',
      status: ECodeStatus.suspicious,
      description: 'Asitlik düzenleyici. Kaynak önemli.',
    ),
    'E280': ECodeInfo(
      code: 'E280',
      name: 'Propiyonik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Koruyucu.',
    ),
    'E300': ECodeInfo(
      code: 'E300',
      name: 'Askorbik Asit (C Vitamini)',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E301': ECodeInfo(
      code: 'E301',
      name: 'Sodyum Askorbat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E304': ECodeInfo(
      code: 'E304',
      name: 'Askorbil Palmitat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Antioksidan. Palmitik asit kaynağı önemli.',
    ),
    'E306': ECodeInfo(
      code: 'E306',
      name: 'Tokoferol (E Vitamini)',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E307': ECodeInfo(
      code: 'E307',
      name: 'Alfa-tokoferol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E308': ECodeInfo(
      code: 'E308',
      name: 'Gamma-tokoferol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E309': ECodeInfo(
      code: 'E309',
      name: 'Delta-tokoferol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E310': ECodeInfo(
      code: 'E310',
      name: 'Propil Galat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Antioksidan.',
    ),
    'E320': ECodeInfo(
      code: 'E320',
      name: 'BHA (Bütillenmiş Hidroksianisol)',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Antioksidan. Yüksek dozda zararlı olabilir.',
    ),
    'E321': ECodeInfo(
      code: 'E321',
      name: 'BHT (Bütillenmiş Hidroksitoluen)',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Antioksidan. Yüksek dozda zararlı olabilir.',
    ),
    'E325': ECodeInfo(
      code: 'E325',
      name: 'Sodyum Laktat',
      source: 'Süt veya sentetik',
      status: ECodeStatus.suspicious,
      description: 'Asitlik düzenleyici.',
    ),
    'E326': ECodeInfo(
      code: 'E326',
      name: 'Potasyum Laktat',
      source: 'Süt veya sentetik',
      status: ECodeStatus.suspicious,
      description: 'Asitlik düzenleyici.',
    ),
    'E327': ECodeInfo(
      code: 'E327',
      name: 'Kalsiyum Laktat',
      source: 'Süt veya sentetik',
      status: ECodeStatus.suspicious,
      description: 'Asitlik düzenleyici.',
    ),
    'E330': ECodeInfo(
      code: 'E330',
      name: 'Sitrik Asit',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici. Limondan.',
    ),
    'E331': ECodeInfo(
      code: 'E331',
      name: 'Sodyum Sitrat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E333': ECodeInfo(
      code: 'E333',
      name: 'Kalsiyum Sitrat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E334': ECodeInfo(
      code: 'E334',
      name: 'Tartarik Asit',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici. Üzümden.',
    ),
    'E335': ECodeInfo(
      code: 'E335',
      name: 'Sodyum Tartrat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E336': ECodeInfo(
      code: 'E336',
      name: 'Potasyum Tartrat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E337': ECodeInfo(
      code: 'E337',
      name: 'Sodyum Potasyum Tartrat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E338': ECodeInfo(
      code: 'E338',
      name: 'Fosforik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici. Kolada kullanılır.',
    ),
    'E339': ECodeInfo(
      code: 'E339',
      name: 'Sodyum Fosfat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E340': ECodeInfo(
      code: 'E340',
      name: 'Potasyum Fosfat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E341': ECodeInfo(
      code: 'E341',
      name: 'Kalsiyum Fosfat',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E400': ECodeInfo(
      code: 'E400',
      name: 'Aljinik Asit',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E401': ECodeInfo(
      code: 'E401',
      name: 'Sodyum Aljinat',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E402': ECodeInfo(
      code: 'E402',
      name: 'Potasyum Aljinat',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E403': ECodeInfo(
      code: 'E403',
      name: 'Amonyum Aljinat',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E404': ECodeInfo(
      code: 'E404',
      name: 'Kalsiyum Aljinat',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E405': ECodeInfo(
      code: 'E405',
      name: 'Propilen Glikol Aljinat',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E406': ECodeInfo(
      code: 'E406',
      name: 'Agar',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Jöle yapıcı.',
    ),
    'E407': ECodeInfo(
      code: 'E407',
      name: 'Karagenan',
      source: 'Deniz yosunu',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E410': ECodeInfo(
      code: 'E410',
      name: 'Keçiboynuzu Gamı',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E412': ECodeInfo(
      code: 'E412',
      name: 'Guar Gamı',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E413': ECodeInfo(
      code: 'E413',
      name: 'Tragakant Gamı',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E414': ECodeInfo(
      code: 'E414',
      name: 'Arap Zamkı',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E415': ECodeInfo(
      code: 'E415',
      name: 'Ksantan Gamı',
      source: 'Bakteriyel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E420': ECodeInfo(
      code: 'E420',
      name: 'Sorbitol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E421': ECodeInfo(
      code: 'E421',
      name: 'Mannitol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E440': ECodeInfo(
      code: 'E440',
      name: 'Pektin',
      source: 'Bitkisel (meyve)',
      status: ECodeStatus.halal,
      description: 'Jöle yapıcı.',
    ),
    'E450': ECodeInfo(
      code: 'E450',
      name: 'Difosfatlar',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E451': ECodeInfo(
      code: 'E451',
      name: 'Trifosfatlar',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E452': ECodeInfo(
      code: 'E452',
      name: 'Polifosfatlar',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E460': ECodeInfo(
      code: 'E460',
      name: 'Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E461': ECodeInfo(
      code: 'E461',
      name: 'Metil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E462': ECodeInfo(
      code: 'E462',
      name: 'Etil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E463': ECodeInfo(
      code: 'E463',
      name: 'Hidroksipropil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E464': ECodeInfo(
      code: 'E464',
      name: 'Hidroksipropil Metil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E465': ECodeInfo(
      code: 'E465',
      name: 'Etil Metil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E466': ECodeInfo(
      code: 'E466',
      name: 'Karboksimetil Selüloz',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E500': ECodeInfo(
      code: 'E500',
      name: 'Sodyum Karbonat',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E501': ECodeInfo(
      code: 'E501',
      name: 'Potasyum Karbonat',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E503': ECodeInfo(
      code: 'E503',
      name: 'Amonyum Karbonat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kabartma tozu.',
    ),
    'E504': ECodeInfo(
      code: 'E504',
      name: 'Magnezyum Karbonat',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E507': ECodeInfo(
      code: 'E507',
      name: 'Hidroklorik Asit',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Asitlik düzenleyici.',
    ),
    'E508': ECodeInfo(
      code: 'E508',
      name: 'Potasyum Klorür',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Tuz takviyesi.',
    ),
    'E509': ECodeInfo(
      code: 'E509',
      name: 'Kalsiyum Klorür',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Sertleştirici.',
    ),
    'E510': ECodeInfo(
      code: 'E510',
      name: 'Amonyum Klorür',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Hamur geliştirici.',
    ),
    'E511': ECodeInfo(
      code: 'E511',
      name: 'Magnezyum Klorür',
      source: 'Mineral',
      status: ECodeStatus.halal,
      description: 'Sertleştirici.',
    ),
    'E620': ECodeInfo(
      code: 'E620',
      name: 'Glutamik Asit',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E621': ECodeInfo(
      code: 'E621',
      name: 'Monosodyum Glutamat (MSG)',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı. Çin yemeği sendromu.',
    ),
    'E622': ECodeInfo(
      code: 'E622',
      name: 'Monopotasyum Glutamat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E623': ECodeInfo(
      code: 'E623',
      name: 'Kalsiyum Glutamat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E624': ECodeInfo(
      code: 'E624',
      name: 'Monoamonyum Glutamat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E625': ECodeInfo(
      code: 'E625',
      name: 'Magnezyum Glutamat',
      source: 'Bitkisel veya hayvansal',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E627': ECodeInfo(
      code: 'E627',
      name: 'Disodyum Guanilat',
      source: 'Balık veya maya',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E628': ECodeInfo(
      code: 'E628',
      name: 'Dipotasyum Guanilat',
      source: 'Balık veya maya',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E629': ECodeInfo(
      code: 'E629',
      name: 'Kalsiyum Guanilat',
      source: 'Balık veya maya',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E630': ECodeInfo(
      code: 'E630',
      name: 'İnosinik Asit',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E632': ECodeInfo(
      code: 'E632',
      name: 'Dipotasyum İnosinat',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E633': ECodeInfo(
      code: 'E633',
      name: 'Kalsiyum İnosinat',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E634': ECodeInfo(
      code: 'E634',
      name: 'Kalsiyum 5-ribonükleotit',
      source: 'Balık veya et',
      status: ECodeStatus.suspicious,
      description: 'Lezzet arttırıcı.',
    ),
    'E636': ECodeInfo(
      code: 'E636',
      name: 'Maltol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Lezzet arttırıcı.',
    ),
    'E637': ECodeInfo(
      code: 'E637',
      name: 'Etil Maltol',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Lezzet arttırıcı.',
    ),
    'E900': ECodeInfo(
      code: 'E900',
      name: 'Polidimetilsiloksan',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Köpük önleyici.',
    ),
    'E902': ECodeInfo(
      code: 'E902',
      name: 'Kandelilla Mumu',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Parlatıcı.',
    ),
    'E903': ECodeInfo(
      code: 'E903',
      name: 'Karnauba Mumu',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Parlatıcı.',
    ),
    'E905': ECodeInfo(
      code: 'E905',
      name: 'Mineral Yağ (Parafin)',
      source: 'Petrol',
      status: ECodeStatus.halal,
      description: 'Parlatıcı.',
    ),
    'E950': ECodeInfo(
      code: 'E950',
      name: 'Asesülfam K',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E951': ECodeInfo(
      code: 'E951',
      name: 'Aspartam',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı. Fenilketonüri hastaları dikkat.',
    ),
    'E952': ECodeInfo(
      code: 'E952',
      name: 'Siklamat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı. Bazı ülkelerde yasaklı.',
    ),
    'E953': ECodeInfo(
      code: 'E953',
      name: 'İzomalt',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E954': ECodeInfo(
      code: 'E954',
      name: 'Sakarin',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E955': ECodeInfo(
      code: 'E955',
      name: 'Sukraloz',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E956': ECodeInfo(
      code: 'E956',
      name: 'Alitam',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E957': ECodeInfo(
      code: 'E957',
      name: 'Taumatin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E959': ECodeInfo(
      code: 'E959',
      name: 'Neohesperidin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E960': ECodeInfo(
      code: 'E960',
      name: 'Steviol Glikozitleri (Stevia)',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Doğal tatlandırıcı.',
    ),
    'E961': ECodeInfo(
      code: 'E961',
      name: 'Neotam',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E962': ECodeInfo(
      code: 'E962',
      name: 'Aspartam-Asesülfam Tuzu',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E965': ECodeInfo(
      code: 'E965',
      name: 'Maltitol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E967': ECodeInfo(
      code: 'E967',
      name: 'Ksilitol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E968': ECodeInfo(
      code: 'E968',
      name: 'Eritritol',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Tatlandırıcı.',
    ),
    'E999': ECodeInfo(
      code: 'E999',
      name: 'Quillaia Ekstresi',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Köpük oluşturucu.',
    ),
    'E1200': ECodeInfo(
      code: 'E1200',
      name: 'Polidekstroz',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1400': ECodeInfo(
      code: 'E1400',
      name: 'Dekstrin',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1404': ECodeInfo(
      code: 'E1404',
      name: 'Okside Nişasta',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1410': ECodeInfo(
      code: 'E1410',
      name: 'Monostarch Fosfat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1412': ECodeInfo(
      code: 'E1412',
      name: 'Distarch Fosfat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1413': ECodeInfo(
      code: 'E1413',
      name: 'Fosforlu Distarch Fosfat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1414': ECodeInfo(
      code: 'E1414',
      name: 'Asetillenmiş Distarch Fosfat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1420': ECodeInfo(
      code: 'E1420',
      name: 'Asetillenmiş Nişasta',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1422': ECodeInfo(
      code: 'E1422',
      name: 'Asetillenmiş Distarch Adipat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1450': ECodeInfo(
      code: 'E1450',
      name: 'Starch Sodyum Oktenilinksüksünat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1451': ECodeInfo(
      code: 'E1451',
      name: 'Asetillenmiş Okside Nişasta',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1452': ECodeInfo(
      code: 'E1452',
      name: 'Starch Alüminyum Oktenilinksüksünat',
      source: 'Bitkisel',
      status: ECodeStatus.halal,
      description: 'Kıvam arttırıcı.',
    ),
    'E1505': ECodeInfo(
      code: 'E1505',
      name: 'Trietil Sitrat',
      source: 'Sentetik',
      status: ECodeStatus.halal,
      description: 'Çözücü.',
    ),
    
  };

  /// Şüpheli kelimeler (içerik listesinde aranacak)
  static const List<String> suspiciousIngredients = [
    'jelatin',
    'gelatin',
    'domuz',
    'pork',
    'lard', // Domuz yağı
    'bacon',
    'ham',
    'alkol',
    'alcohol',
    'şarap',
    'wine',
    'bira',
    'beer',
    'viski',
    'whisky',
    'vodka',
    'rom',
    'rum',
    'likör',
    'liqueur',
    'brendi',
    'brandy',
    'konyak',
    'cognac',
    'cochineal',
    'carmine',
    'karmin',
    'shellac',
    'şellak',
    'l-cysteine',
    'l-sistein',
    'animal fat',
    'hayvansal yağ',
    'beef gelatin',
    'pork gelatin',
  ];

  Future<void> initialize() async {
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('halal_scan_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _scanHistory = decoded.map((e) => ScanHistory.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Tarama geçmişi yüklenemedi: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_scanHistory.map((e) => e.toJson()).toList());
      await prefs.setString('halal_scan_history', historyJson);
    } catch (e) {
      debugPrint('Tarama geçmişi kaydedilemedi: $e');
    }
  }

  /// Barkodu analiz et
  Future<ScanResult> analyzeBarcode(String barcode, {String? productName, String? ingredients}) async {
    final List<ECodeInfo> foundECodes = [];
    final List<String> foundIngredients = [];
    HalalStatus overallStatus = HalalStatus.halal;

    // İçerik listesinde E-kodlarını ara
    if (ingredients != null && ingredients.isNotEmpty) {
      final upperIngredients = ingredients.toUpperCase();
      
      // E-kodlarını kontrol et
      for (final entry in eCodeDatabase.entries) {
        if (upperIngredients.contains(entry.key.toUpperCase())) {
          foundECodes.add(entry.value);
          
          // Durumu güncelle
          if (entry.value.status == ECodeStatus.haram) {
            overallStatus = HalalStatus.haram;
          } else if (entry.value.status == ECodeStatus.suspicious && 
                     overallStatus != HalalStatus.haram) {
            overallStatus = HalalStatus.suspicious;
          }
        }
      }

      // Şüpheli kelimeleri ara
      final lowerIngredients = ingredients.toLowerCase();
      for (final word in suspiciousIngredients) {
        if (lowerIngredients.contains(word.toLowerCase())) {
          foundIngredients.add(word);
          
          // Domuz ve alkol kelimeleri kesin haram
          if (word.contains('domuz') || word.contains('pork') || 
              word.contains('lard') || word.contains('bacon') ||
              word.contains('alkol') || word.contains('alcohol') ||
              word.contains('şarap') || word.contains('wine') ||
              word.contains('bira') || word.contains('beer') ||
              word.contains('viski') || word.contains('vodka')) {
            overallStatus = HalalStatus.haram;
          } else if (overallStatus != HalalStatus.haram) {
            overallStatus = HalalStatus.suspicious;
          }
        }
      }
    }

    // API'den ürün bilgisi varsa ekle
    ProductInfo? productInfo;
    if (barcode != 'manual') {
      productInfo = await fetchProductByBarcode(barcode);
    }

    final result = ScanResult(
      barcode: barcode,
      productName: productName ?? productInfo?.productName,
      ingredients: ingredients ?? productInfo?.ingredients,
      foundECodes: foundECodes,
      foundSuspiciousIngredients: foundIngredients,
      status: overallStatus,
      scanTime: DateTime.now(),
      productInfo: productInfo,
    );

    // Geçmişe ekle
    _addToHistory(result);

    return result;
  }

  /// Sadece E-kodlarını analiz et (barkod olmadan)
  Future<ScanResult> analyzeIngredients(String ingredients, {String? productName}) async {
    return analyzeBarcode('manual', productName: productName, ingredients: ingredients);
  }

  void _addToHistory(ScanResult result) {
    final historyItem = ScanHistory(
      barcode: result.barcode,
      productName: result.productName ?? result.productInfo?.productName ?? 'Bilinmeyen Ürün',
      status: result.status,
      scanTime: result.scanTime,
    );

    // Aynı barkod varsa güncelle
    _scanHistory.removeWhere((h) => h.barcode == result.barcode);
    _scanHistory.insert(0, historyItem);

    // Maksimum 50 kayıt tut
    if (_scanHistory.length > 50) {
      _scanHistory = _scanHistory.take(50).toList();
    }

    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _scanHistory.clear();
    _saveHistory();
    notifyListeners();
  }

  /// E-kodu bilgisi getir
  ECodeInfo? getECodeInfo(String code) {
    return eCodeDatabase[code.toUpperCase()];
  }

  /// Tüm haram E-kodlarını listele
  List<ECodeInfo> getHaramECodes() {
    return eCodeDatabase.values
        .where((e) => e.status == ECodeStatus.haram)
        .toList();
  }

  /// Tüm şüpheli E-kodlarını listele
  List<ECodeInfo> getSuspiciousECodes() {
    return eCodeDatabase.values
        .where((e) => e.status == ECodeStatus.suspicious)
        .toList();
  }
}

/// Ürün bilgisi (Open Food Facts API'den)
class ProductInfo {
  final String barcode;
  final String productName;
  final String brand;
  final String ingredients;
  final List<String> ingredientsList;
  final String categories;
  final String imageUrl;

  ProductInfo({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.ingredients,
    required this.ingredientsList,
    required this.categories,
    required this.imageUrl,
  });
}

/// E-kodu durumu
enum ECodeStatus {
  halal,      // Helal
  haram,      // Haram
  suspicious, // Şüpheli (kaynağına bağlı)
}

/// Helal durumu
enum HalalStatus {
  halal,      // Helal - sorun yok
  haram,      // Haram - kesinlikle yasak
  suspicious, // Şüpheli - dikkatli olunmalı
  unknown,    // Bilinmiyor
}

/// E-kodu bilgisi
class ECodeInfo {
  final String code;
  final String name;
  final String source;
  final ECodeStatus status;
  final String description;

  const ECodeInfo({
    required this.code,
    required this.name,
    required this.source,
    required this.status,
    required this.description,
  });
}

/// Tarama sonucu
class ScanResult {
  final String barcode;
  final String? productName;
  final String? ingredients;
  final List<ECodeInfo> foundECodes;
  final List<String> foundSuspiciousIngredients;
  final HalalStatus status;
  final DateTime scanTime;
  final ProductInfo? productInfo;  // API'den gelen ürün bilgisi

  ScanResult({
    required this.barcode,
    this.productName,
    this.ingredients,
    required this.foundECodes,
    required this.foundSuspiciousIngredients,
    required this.status,
    required this.scanTime,
    this.productInfo,
  });

  bool get hasIssues => foundECodes.isNotEmpty || foundSuspiciousIngredients.isNotEmpty;
}

/// Tarama geçmişi
class ScanHistory {
  final String barcode;
  final String productName;
  final HalalStatus status;
  final DateTime scanTime;

  ScanHistory({
    required this.barcode,
    required this.productName,
    required this.status,
    required this.scanTime,
  });

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'productName': productName,
    'status': status.index,
    'scanTime': scanTime.toIso8601String(),
  };

  factory ScanHistory.fromJson(Map<String, dynamic> json) => ScanHistory(
    barcode: json['barcode'],
    productName: json['productName'],
    status: HalalStatus.values[json['status']],
    scanTime: DateTime.parse(json['scanTime']),
  );
}
