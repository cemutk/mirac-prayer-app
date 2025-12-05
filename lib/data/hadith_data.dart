/// Hadith (Hadis-i Şerif) Data
/// Collection of authentic hadiths with Turkish translations

class Hadith {
  final int id;
  final String arabic;
  final String turkish;
  final String source;
  final String narrator;
  final String category;
  final bool isFavorite;

  const Hadith({
    required this.id,
    required this.arabic,
    required this.turkish,
    required this.source,
    required this.narrator,
    required this.category,
    this.isFavorite = false,
  });

  Hadith copyWith({bool? isFavorite}) {
    return Hadith(
      id: id,
      arabic: arabic,
      turkish: turkish,
      source: source,
      narrator: narrator,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Hadith categories
const List<String> hadithCategories = [
  'Tümü',
  'İman',
  'Namaz',
  'Ahlak',
  'İlim',
  'Aile',
  'Ticaret',
  'Sabır',
  'Dua',
  'Zikir',
];

/// Collection of Hadiths
const List<Hadith> hadithList = [
  // İMAN
  Hadith(
    id: 1,
    arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    turkish: 'Ameller niyetlere göredir. Herkes için ancak niyet ettiği şey vardır.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ömer (r.a.)',
    category: 'İman',
  ),
  Hadith(
    id: 2,
    arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    turkish: 'Sizden biriniz, kendisi için istediğini kardeşi için de istemedikçe gerçek mümin olamaz.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Enes (r.a.)',
    category: 'İman',
  ),
  Hadith(
    id: 3,
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    turkish: 'Müslüman, dilinden ve elinden diğer Müslümanların güvende olduğu kimsedir.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Abdullah b. Amr (r.a.)',
    category: 'İman',
  ),
  Hadith(
    id: 4,
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    turkish: 'Allah\'a ve ahiret gününe iman eden kimse ya hayır söylesin ya da sussun.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'İman',
  ),

  // NAMAZ
  Hadith(
    id: 5,
    arabic: 'الصَّلَاةُ عِمَادُ الدِّينِ',
    turkish: 'Namaz dinin direğidir.',
    source: 'Beyhakî',
    narrator: 'Hz. Ömer (r.a.)',
    category: 'Namaz',
  ),
  Hadith(
    id: 6,
    arabic: 'صَلُّوا كَمَا رَأَيْتُمُونِي أُصَلِّي',
    turkish: 'Beni nasıl namaz kılarken gördüyseniz, siz de öyle kılın.',
    source: 'Buhârî',
    narrator: 'Hz. Malik b. Huveyris (r.a.)',
    category: 'Namaz',
  ),
  Hadith(
    id: 7,
    arabic: 'بَيْنَ الرَّجُلِ وَبَيْنَ الشِّرْكِ وَالْكُفْرِ تَرْكُ الصَّلَاةِ',
    turkish: 'Kişi ile şirk ve küfür arasındaki fark namazı terk etmektir.',
    source: 'Müslim',
    narrator: 'Hz. Cabir (r.a.)',
    category: 'Namaz',
  ),
  Hadith(
    id: 8,
    arabic: 'أَوَّلُ مَا يُحَاسَبُ بِهِ الْعَبْدُ يَوْمَ الْقِيَامَةِ الصَّلَاةُ',
    turkish: 'Kıyamet gününde kulun ilk hesaba çekileceği şey namazdır.',
    source: 'Tirmizî, Nesâî',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Namaz',
  ),

  // AHLAK
  Hadith(
    id: 9,
    arabic: 'إِنَّمَا بُعِثْتُ لِأُتَمِّمَ مَكَارِمَ الْأَخْلَاقِ',
    turkish: 'Ben ancak güzel ahlakı tamamlamak için gönderildim.',
    source: 'Muvatta, Ahmed',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Ahlak',
  ),
  Hadith(
    id: 10,
    arabic: 'أَكْمَلُ الْمُؤْمِنِينَ إِيمَانًا أَحْسَنُهُمْ خُلُقًا',
    turkish: 'Müminlerin iman bakımından en mükemmeli, ahlakça en güzel olanıdır.',
    source: 'Tirmizî, Ebu Dâvud',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Ahlak',
  ),
  Hadith(
    id: 11,
    arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
    turkish: 'Güçlü insan güreşte rakibini yenen değil, öfkelendiğinde kendine hakim olabilen kimsedir.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Ahlak',
  ),
  Hadith(
    id: 12,
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
    turkish: 'Kardeşinin yüzüne gülümsemen sadakadır.',
    source: 'Tirmizî',
    narrator: 'Hz. Ebu Zer (r.a.)',
    category: 'Ahlak',
  ),

  // İLİM
  Hadith(
    id: 13,
    arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    turkish: 'İlim öğrenmek her Müslümana farzdır.',
    source: 'İbn Mâce',
    narrator: 'Hz. Enes (r.a.)',
    category: 'İlim',
  ),
  Hadith(
    id: 14,
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
    turkish: 'Kim ilim öğrenmek için bir yola girerse, Allah ona cennete giden yolu kolaylaştırır.',
    source: 'Müslim, Tirmizî',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'İlim',
  ),
  Hadith(
    id: 15,
    arabic: 'الْحِكْمَةُ ضَالَّةُ الْمُؤْمِنِ فَحَيْثُ وَجَدَهَا فَهُوَ أَحَقُّ بِهَا',
    turkish: 'Hikmet müminin yitiğidir. Onu nerede bulursa alır.',
    source: 'Tirmizî, İbn Mâce',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'İlim',
  ),

  // AİLE
  Hadith(
    id: 16,
    arabic: 'خَيْرُكُمْ خَيْرُكُمْ لِأَهْلِهِ وَأَنَا خَيْرُكُمْ لِأَهْلِي',
    turkish: 'Sizin en hayırlınız, ailesine en iyi davrananınızdır. Ben de aileme en iyi davrananınızım.',
    source: 'Tirmizî, İbn Mâce',
    narrator: 'Hz. Aişe (r.a.)',
    category: 'Aile',
  ),
  Hadith(
    id: 17,
    arabic: 'الْجَنَّةُ تَحْتَ أَقْدَامِ الْأُمَّهَاتِ',
    turkish: 'Cennet annelerin ayakları altındadır.',
    source: 'Nesâî, İbn Mâce',
    narrator: 'Hz. Enes (r.a.)',
    category: 'Aile',
  ),
  Hadith(
    id: 18,
    arabic: 'مَنْ كَانَ لَهُ ثَلَاثُ بَنَاتٍ فَصَبَرَ عَلَيْهِنَّ وَأَطْعَمَهُنَّ وَسَقَاهُنَّ وَكَسَاهُنَّ مِنْ جِدَتِهِ كُنَّ لَهُ حِجَابًا مِنَ النَّارِ يَوْمَ الْقِيَامَةِ',
    turkish: 'Kimin üç kız çocuğu olur da onlara sabredip yedirir, içirir ve giydirirse, kıyamet günü o kızlar onun için cehennem ateşine karşı perde olur.',
    source: 'İbn Mâce',
    narrator: 'Hz. Ukbe b. Âmir (r.a.)',
    category: 'Aile',
  ),

  // TİCARET
  Hadith(
    id: 19,
    arabic: 'التَّاجِرُ الصَّدُوقُ الْأَمِينُ مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاءِ',
    turkish: 'Doğru sözlü ve güvenilir tüccar, peygamberler, sıddıklar ve şehitlerle beraberdir.',
    source: 'Tirmizî',
    narrator: 'Hz. Ebu Said (r.a.)',
    category: 'Ticaret',
  ),
  Hadith(
    id: 20,
    arabic: 'الْبَيِّعَانِ بِالْخِيَارِ مَا لَمْ يَتَفَرَّقَا',
    turkish: 'Alıcı ve satıcı, ayrılmadıkları sürece muhayyerdirler (seçim hakları vardır).',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Abdullah b. Ömer (r.a.)',
    category: 'Ticaret',
  ),

  // SABIR
  Hadith(
    id: 21,
    arabic: 'وَمَنْ يَتَصَبَّرْ يُصَبِّرْهُ اللَّهُ',
    turkish: 'Kim sabretmeye çalışırsa, Allah ona sabır verir.',
    source: 'Buhârî',
    narrator: 'Hz. Ebu Said (r.a.)',
    category: 'Sabır',
  ),
  Hadith(
    id: 22,
    arabic: 'مَا يُصِيبُ الْمُسْلِمَ مِنْ نَصَبٍ وَلَا وَصَبٍ وَلَا هَمٍّ وَلَا حُزْنٍ وَلَا أَذًى وَلَا غَمٍّ حَتَّى الشَّوْكَةِ يُشَاكُهَا إِلَّا كَفَّرَ اللَّهُ بِهَا مِنْ خَطَايَاهُ',
    turkish: 'Müslümana isabet eden yorgunluk, hastalık, üzüntü, keder, sıkıntı, hatta ayağına batan dikene varıncaya kadar her şey, günahlarına kefaret olur.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Said, Hz. Ebu Hüreyre (r.a.)',
    category: 'Sabır',
  ),

  // DUA
  Hadith(
    id: 23,
    arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
    turkish: 'Dua ibadetin ta kendisidir.',
    source: 'Tirmizî, Ebu Dâvud',
    narrator: 'Hz. Nu\'man b. Beşir (r.a.)',
    category: 'Dua',
  ),
  Hadith(
    id: 24,
    arabic: 'ادْعُوا اللَّهَ وَأَنْتُمْ مُوقِنُونَ بِالْإِجَابَةِ',
    turkish: 'Allah\'a, kabul edileceğinden emin olarak dua edin.',
    source: 'Tirmizî',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Dua',
  ),
  Hadith(
    id: 25,
    arabic: 'مَا مِنْ مُسْلِمٍ يَدْعُو بِدَعْوَةٍ لَيْسَ فِيهَا إِثْمٌ وَلَا قَطِيعَةُ رَحِمٍ إِلَّا أَعْطَاهُ اللَّهُ بِهَا إِحْدَى ثَلَاثٍ',
    turkish: 'Günah ve akraba ile ilişkiyi kesme içermeyen her dua karşılığında Allah üç şeyden birini verir: Ya duasını hemen kabul eder, ya ahirete saklar, ya da benzeri bir kötülüğü ondan uzaklaştırır.',
    source: 'Ahmed, Tirmizî',
    narrator: 'Hz. Ebu Said (r.a.)',
    category: 'Dua',
  ),

  // ZİKİR
  Hadith(
    id: 26,
    arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ ثَقِيلَتَانِ فِي الْمِيزَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    turkish: 'İki kelime vardır ki, dile hafif, mizanda ağır ve Rahman\'a sevimlidir: "Subhanallahi ve bihamdihi, Subhanallahil azim" (Allah\'ı hamd ile tesbih ederim, Yüce Allah\'ı tesbih ederim).',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Zikir',
  ),
  Hadith(
    id: 27,
    arabic: 'مَنْ قَالَ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ فِي يَوْمٍ مِائَةَ مَرَّةٍ حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ',
    turkish: 'Kim günde yüz defa "Subhanallahi ve bihamdihi" derse, günahları deniz köpüğü kadar çok olsa bile bağışlanır.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Zikir',
  ),
  Hadith(
    id: 28,
    arabic: 'أَفْضَلُ الذِّكْرِ لَا إِلَهَ إِلَّا اللَّهُ',
    turkish: 'Zikrin en faziletlisi "La ilahe illallah"tır.',
    source: 'Tirmizî, İbn Mâce',
    narrator: 'Hz. Cabir (r.a.)',
    category: 'Zikir',
  ),

  // GENEL - İMAN
  Hadith(
    id: 29,
    arabic: 'الدِّينُ النَّصِيحَةُ',
    turkish: 'Din nasihattir (samimi öğüttür).',
    source: 'Müslim',
    narrator: 'Hz. Temim ed-Dari (r.a.)',
    category: 'İman',
  ),
  Hadith(
    id: 30,
    arabic: 'مَا نَقَصَ مَالٌ مِنْ صَدَقَةٍ',
    turkish: 'Sadaka vermekle mal eksilmez.',
    source: 'Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Ahlak',
  ),

  // AHLAK - EK
  Hadith(
    id: 31,
    arabic: 'إِنَّ اللَّهَ رَفِيقٌ يُحِبُّ الرِّفْقَ فِي الْأَمْرِ كُلِّهِ',
    turkish: 'Allah Refik\'tir (yumuşak huyludur) ve her işte yumuşak huyu sever.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Aişe (r.a.)',
    category: 'Ahlak',
  ),
  Hadith(
    id: 32,
    arabic: 'لَا تَغْضَبْ',
    turkish: 'Öfkelenme!',
    source: 'Buhârî',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Ahlak',
  ),
  Hadith(
    id: 33,
    arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
    turkish: 'Nerede olursan ol Allah\'tan kork. Kötülüğün ardından iyilik yap ki onu silsin. İnsanlara güzel ahlakla davran.',
    source: 'Tirmizî',
    narrator: 'Hz. Muaz b. Cebel (r.a.)',
    category: 'Ahlak',
  ),

  // NAMAZ - EK
  Hadith(
    id: 34,
    arabic: 'إِذَا قُمْتَ إِلَى الصَّلَاةِ فَأَسْبِغِ الْوُضُوءَ',
    turkish: 'Namaza kalktığında abdestini güzelce al.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Namaz',
  ),
  Hadith(
    id: 35,
    arabic: 'صَلَاةُ الْجَمَاعَةِ تَفْضُلُ صَلَاةَ الْفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً',
    turkish: 'Cemaatle kılınan namaz, tek başına kılınan namazdan yirmi yedi derece daha faziletlidir.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Abdullah b. Ömer (r.a.)',
    category: 'Namaz',
  ),

  // İLİM - EK
  Hadith(
    id: 36,
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    turkish: 'Sizin en hayırlınız Kur\'an\'ı öğrenen ve öğretendir.',
    source: 'Buhârî',
    narrator: 'Hz. Osman (r.a.)',
    category: 'İlim',
  ),

  // SABIR - EK
  Hadith(
    id: 37,
    arabic: 'عَجَبًا لِأَمْرِ الْمُؤْمِنِ إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ',
    turkish: 'Müminin haline şaşılır! Onun her hali hayırdır. Sevinirse şükreder, bu onun için hayırdır. Başına bir bela gelirse sabreder, bu da onun için hayırdır.',
    source: 'Müslim',
    narrator: 'Hz. Suheyb (r.a.)',
    category: 'Sabır',
  ),

  // DUA - EK
  Hadith(
    id: 38,
    arabic: 'أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ فَأَكْثِرُوا الدُّعَاءَ',
    turkish: 'Kulun Rabbine en yakın olduğu an secde halidir. O halde secdede çokça dua edin.',
    source: 'Müslim',
    narrator: 'Hz. Ebu Hüreyre (r.a.)',
    category: 'Dua',
  ),

  // AİLE - EK
  Hadith(
    id: 39,
    arabic: 'مَنْ لَا يَرْحَمِ النَّاسَ لَا يَرْحَمْهُ اللَّهُ',
    turkish: 'İnsanlara merhamet etmeyene Allah da merhamet etmez.',
    source: 'Buhârî, Müslim',
    narrator: 'Hz. Cerir b. Abdullah (r.a.)',
    category: 'Aile',
  ),

  // ZİKİR - EK
  Hadith(
    id: 40,
    arabic: 'مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لَا يَذْكُرُ رَبَّهُ مَثَلُ الْحَيِّ وَالْمَيِّتِ',
    turkish: 'Rabbini zikreden ile zikretmeyenin durumu, diri ile ölünün durumu gibidir.',
    source: 'Buhârî',
    narrator: 'Hz. Ebu Musa (r.a.)',
    category: 'Zikir',
  ),
];

/// Get hadiths by category
List<Hadith> getHadithsByCategory(String category) {
  if (category == 'Tümü') return hadithList;
  return hadithList.where((h) => h.category == category).toList();
}

/// Get random hadith
Hadith getRandomHadith() {
  final random = DateTime.now().millisecondsSinceEpoch % hadithList.length;
  return hadithList[random];
}

/// Get daily hadith (based on day of year)
Hadith getDailyHadith() {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  final index = dayOfYear % hadithList.length;
  return hadithList[index];
}
