/// Dua (Prayer) data model and collection
class Dua {
  final int id;
  final String title;
  final String arabicText;
  final String turkishMeaning;
  final String latinTranscription;
  final String category;
  final String source;
  final String? benefit;
  final bool isFavorite;

  const Dua({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.turkishMeaning,
    required this.latinTranscription,
    required this.category,
    required this.source,
    this.benefit,
    this.isFavorite = false,
  });

  Dua copyWith({bool? isFavorite}) {
    return Dua(
      id: id,
      title: title,
      arabicText: arabicText,
      turkishMeaning: turkishMeaning,
      latinTranscription: latinTranscription,
      category: category,
      source: source,
      benefit: benefit,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Dua kategorileri
const List<String> duaCategories = [
  'Tümü',
  'Ayet-el Kürsi',
  'Sabah Duaları',
  'Akşam Duaları',
  'Namaz Duaları',
  'Yemek Duaları',
  'Yolculuk Duaları',
  'Şifa Duaları',
  'İstiğfar',
  'Salavat',
];

/// Önemli dualar koleksiyonu
const List<Dua> allDuas = [
  // AYET-EL KÜRSİ
  Dua(
    id: 1,
    title: 'Ayet-el Kürsi',
    arabicText: '''اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ''',
    turkishMeaning: 'Allah, O\'ndan başka ilah yoktur. O, Hayy\'dır (daima diridir), Kayyum\'dur (yaratıkları koruyup yönetendir). O\'nu ne uyuklama tutar ne de uyku. Göklerde ve yerde ne varsa O\'nundur. İzni olmadan O\'nun katında kim şefaat edebilir? O, kullarının yaptıklarını ve yapacaklarını bilir. O\'nun ilminden, ancak dilediği kadarından başka bir şey kavrayamazlar. O\'nun kürsüsü gökleri ve yeri kaplamıştır. Onları korumak O\'na zor gelmez. O, yücedir, büyüktür.',
    latinTranscription: 'Allahu la ilahe illa huvel hayyul kayyum. La te\'huzuhu sinetun vela nevm. Lehu ma fissemavati vema fil ard. Men zellezi yeşfeu indehu illa biiznih. Ya\'lemu ma beyne eydihim vema halfehum. Vela yuhitune bişey\'in min ilmihi illa bima şa\'. Vesia kursiyyuhus semavati vel ard. Vela yeuduhü hifzuhuma ve huvel aliyyul azim.',
    category: 'Ayet-el Kürsi',
    source: 'Bakara Suresi, 255. Ayet',
    benefit: 'Her namazdan sonra okuyan kişi ile cennet arasında ölümden başka engel kalmaz. (Nesâî)',
  ),

  // SABAH DUALARI
  Dua(
    id: 2,
    title: 'Sabah Duası',
    arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَىْءٍ قَدِيرٌ',
    turkishMeaning: 'Sabaha girdik, mülk de Allah\'ın olarak sabaha girdi. Hamd Allah\'a mahsustur. Allah\'tan başka ilah yoktur. O tektir, ortağı yoktur. Mülk O\'nundur ve hamd O\'na mahsustur. O her şeye kadirdir.',
    latinTranscription: 'Esbahna ve esbaha\'l-mulku lillahi ve\'l-hamdu lillahi la ilahe illallahu vahdehu la şerike leh, lehu\'l-mulku ve lehu\'l-hamdu ve huve ala kulli şey\'in kadir.',
    category: 'Sabah Duaları',
    source: 'Müslim',
    benefit: 'Sabah namazından sonra okunması tavsiye edilir.',
  ),
  Dua(
    id: 3,
    title: 'Sabahın Efendisi Duası',
    arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    turkishMeaning: 'Allah\'ım! Senin sayende sabaha girdik, Senin sayende akşama girdik. Senin sayende yaşar, Senin sayende ölürüz. Dönüş Sanadır.',
    latinTranscription: 'Allahumme bike asbahna ve bike emseyna ve bike nahya ve bike nemutu ve ileyke\'n-nuşur.',
    category: 'Sabah Duaları',
    source: 'Tirmizi',
    benefit: 'Her sabah okunması sünnettir.',
  ),
  Dua(
    id: 4,
    title: 'Bismillah Duası',
    arabicText: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    turkishMeaning: 'Allah\'ın adıyla! O\'nun adıyla birlikte yerde ve gökte hiçbir şey zarar veremez. O, işitendir, bilendir.',
    latinTranscription: 'Bismillahillezi la yedurru maasmihi şey\'un fil ardi vela fis semai ve huves semiul alim.',
    category: 'Sabah Duaları',
    source: 'Ebu Davud, Tirmizi',
    benefit: '3 defa okuyana o gün ve gece hiçbir şey zarar veremez.',
  ),

  // AKŞAM DUALARI
  Dua(
    id: 5,
    title: 'Akşam Duası',
    arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَىْءٍ قَدِيرٌ',
    turkishMeaning: 'Akşama girdik, mülk de Allah\'ın olarak akşama girdi. Hamd Allah\'a mahsustur. Allah\'tan başka ilah yoktur. O tektir, ortağı yoktur. Mülk O\'nundur ve hamd O\'na mahsustur. O her şeye kadirdir.',
    latinTranscription: 'Emseyna ve emsa\'l-mulku lillahi ve\'l-hamdu lillahi la ilahe illallahu vahdehu la şerike leh, lehu\'l-mulku ve lehu\'l-hamdu ve huve ala kulli şey\'in kadir.',
    category: 'Akşam Duaları',
    source: 'Müslim',
    benefit: 'Akşam namazından sonra okunması tavsiye edilir.',
  ),
  Dua(
    id: 6,
    title: 'Akşamın Efendisi Duası',
    arabicText: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    turkishMeaning: 'Allah\'ım! Senin sayende akşama girdik, Senin sayende sabaha girdik. Senin sayende yaşar, Senin sayende ölürüz. Dönüş Sanadır.',
    latinTranscription: 'Allahumme bike emseyna ve bike asbahna ve bike nahya ve bike nemutu ve ileyke\'l-masir.',
    category: 'Akşam Duaları',
    source: 'Tirmizi',
    benefit: 'Her akşam okunması sünnettir.',
  ),

  // NAMAZ DUALARI
  Dua(
    id: 7,
    title: 'Sübhaneke Duası',
    arabicText: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلاَ إِلَهَ غَيْرُكَ',
    turkishMeaning: 'Ey Allah\'ım! Sen eksik sıfatlardan pak ve uzaksın. Seni hamd ile tesbih ederim. Senin adın mübarektir. Şanın yücedir. Senden başka ilah yoktur.',
    latinTranscription: 'Subhanekallahümme ve bi hamdik ve tebarekesmük ve teala ceddük ve la ilahe gayrük.',
    category: 'Namaz Duaları',
    source: 'Ebu Davud, Tirmizi',
    benefit: 'Namazın başında iftitah tekbirinden sonra okunur.',
  ),
  Dua(
    id: 8,
    title: 'Ettehiyyatü Duası',
    arabicText: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلاَمُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ السَّلاَمُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    turkishMeaning: 'Dil ile, beden ile, mal ile yapılan bütün ibadetler Allah içindir. Ey Peygamber! Allah\'ın selamı, rahmeti ve bereketleri senin üzerine olsun. Selam bizim üzerimize ve Allah\'ın salih kulları üzerine olsun. Şahitlik ederim ki Allah\'tan başka ilah yoktur. Ve yine şahitlik ederim ki Muhammed O\'nun kulu ve resulüdür.',
    latinTranscription: 'Ettehiyyatu lillahi vessalavatu vettayyibat. Esselamu aleyke eyyuhen nebiyyu ve rahmetullahi ve berekatuh. Esselamu aleyna ve ala ibadillahis salihin. Eşhedu en la ilahe illallah ve eşhedu enne Muhammeden abduhu ve resuluh.',
    category: 'Namaz Duaları',
    source: 'Buhârî, Müslim',
    benefit: 'Namazın her oturuşunda okunur.',
  ),
  Dua(
    id: 9,
    title: 'Allahümme Salli',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    turkishMeaning: 'Allah\'ım! Hz. Muhammed\'e ve onun âline salat eyle. Hz. İbrahim\'e ve onun âline salat ettiğin gibi. Şüphesiz Sen övülmeye layıksın, yücesin.',
    latinTranscription: 'Allahümme salli ala Muhammedin ve ala ali Muhammed. Kema salleyte ala İbrahime ve ala ali İbrahim. İnneke hamidun mecid.',
    category: 'Namaz Duaları',
    source: 'Buhârî',
    benefit: 'Son oturuşta Ettehiyyatü\'den sonra okunur.',
  ),
  Dua(
    id: 10,
    title: 'Allahümme Barik',
    arabicText: 'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    turkishMeaning: 'Allah\'ım! Hz. Muhammed\'e ve onun âline bereket ver. Hz. İbrahim\'e ve onun âline bereket verdiğin gibi. Şüphesiz Sen övülmeye layıksın, yücesin.',
    latinTranscription: 'Allahümme barik ala Muhammedin ve ala ali Muhammed. Kema barekte ala İbrahime ve ala ali İbrahim. İnneke hamidun mecid.',
    category: 'Namaz Duaları',
    source: 'Buhârî',
    benefit: 'Son oturuşta Allahümme Salli\'den sonra okunur.',
  ),
  Dua(
    id: 11,
    title: 'Rabbena Atina Duası',
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    turkishMeaning: 'Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver. Bizi cehennem azabından koru.',
    latinTranscription: 'Rabbena atina fid dunya haseneten ve fil ahireti haseneten ve kına azaben nar.',
    category: 'Namaz Duaları',
    source: 'Bakara Suresi, 201. Ayet',
    benefit: 'Namazda ve her zaman okunabilecek en kapsamlı dualardan biridir.',
  ),

  // YEMEK DUALARI
  Dua(
    id: 12,
    title: 'Yemekten Önce Dua',
    arabicText: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
    turkishMeaning: 'Allah\'ın adıyla ve Allah\'ın bereketine sığınarak (başlıyorum).',
    latinTranscription: 'Bismillahi ve ala bereketillah.',
    category: 'Yemek Duaları',
    source: 'Hadis',
    benefit: 'Yemeğe başlamadan önce okunur.',
  ),
  Dua(
    id: 13,
    title: 'Yemekten Sonra Dua',
    arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مِنَ الْمُسْلِمِينَ',
    turkishMeaning: 'Bizi yediren, içiren ve Müslümanlardan kılan Allah\'a hamd olsun.',
    latinTranscription: 'Elhamdu lillahillezi at\'amena ve sekana ve cealena minel muslimin.',
    category: 'Yemek Duaları',
    source: 'Ebu Davud, Tirmizi',
    benefit: 'Yemekten sonra okunur.',
  ),

  // YOLCULUK DUALARI
  Dua(
    id: 14,
    title: 'Yolculuk Duası',
    arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    turkishMeaning: 'Bunu bizim hizmetimize veren Allah her türlü noksanlıktan münezzehtir. Yoksa biz buna güç yetiremezdik. Muhakkak ki biz Rabbimize döneceğiz.',
    latinTranscription: 'Subhanellezi sahhara lena haza ve ma kunna lehu mukrinin. Ve inna ila Rabbina lemunkalibun.',
    category: 'Yolculuk Duaları',
    source: 'Zuhruf Suresi, 13-14. Ayetler',
    benefit: 'Herhangi bir vasıtaya bindiğinde okunur.',
  ),
  Dua(
    id: 15,
    title: 'Eve Girerken Dua',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
    turkishMeaning: 'Allah\'ım! Senden hayırlı bir giriş ve hayırlı bir çıkış dilerim. Allah\'ın adıyla girdik, Allah\'ın adıyla çıktık ve Rabbimiz Allah\'a tevekkül ettik.',
    latinTranscription: 'Allahümme inni es\'elüke hayral mevlici ve hayral mahreci bismillahi velecna ve bismillahi haracna ve alellahi Rabbina tevekkelna.',
    category: 'Yolculuk Duaları',
    source: 'Ebu Davud',
    benefit: 'Eve girerken okunur.',
  ),

  // ŞİFA DUALARI
  Dua(
    id: 16,
    title: 'Şifa Duası',
    arabicText: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِهِ وَأَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا',
    turkishMeaning: 'Ey insanların Rabbi olan Allah\'ım! Bu hastalığı gider, şifa ver. Sen Şafi\'sin (şifa verensin). Senin şifandan başka şifa yoktur. Hiçbir hastalık izi bırakmayan bir şifa ver.',
    latinTranscription: 'Allahümme Rabben nasi, ezhebil be\'se, işfihi ve enteş şafi, la şifae illa şifauke, şifaen la yugadiru sekama.',
    category: 'Şifa Duaları',
    source: 'Buhârî, Müslim',
    benefit: 'Hasta ziyaretinde veya hastalık halinde okunur.',
  ),
  Dua(
    id: 17,
    title: 'Ağrı Duası',
    arabicText: 'أَعُوذُ بِعِزَّةِ اللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
    turkishMeaning: 'Hissettiğim ve çekindiğim şeyin şerrinden Allah\'ın izzetine ve kudretine sığınırım.',
    latinTranscription: 'Euzu biizzetillahi ve kudretihi min şerri ma ecidu ve uhaziru.',
    category: 'Şifa Duaları',
    source: 'Müslim',
    benefit: 'Ağrıyan yere el koyup 7 defa okunur.',
  ),

  // İSTİĞFAR
  Dua(
    id: 18,
    title: 'Seyyidü\'l-İstiğfar',
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    turkishMeaning: 'Allah\'ım! Sen benim Rabbimsin. Senden başka ilah yoktur. Beni Sen yarattın. Ben Senin kulunum ve gücüm yettiği ölçüde Sana verdiğim sözde duruyorum. İşlediklerimin şerrinden Sana sığınırım. Bana verdiğin nimetleri itiraf ederim. Günahlarımı da itiraf ederim. Beni bağışla. Çünkü günahları Senden başka bağışlayacak yoktur.',
    latinTranscription: 'Allahümme ente Rabbi la ilahe illa ente halakteni ve ene abduke ve ene ala ahdike ve va\'dike mesteta\'tu. Euzu bike min şerri ma sana\'tu. Ebuu leke bini\'metike aleyye ve ebuu bizenbi. Fağfirli feinnehü la yağfiruz zunube illa ente.',
    category: 'İstiğfar',
    source: 'Buhârî',
    benefit: 'İstiğfarların en faziletlisi. Sabah akşam okuyana cennet vaad edilmiştir.',
  ),
  Dua(
    id: 19,
    title: 'Kısa İstiğfar',
    arabicText: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
    turkishMeaning: 'Kendisinden başka ilah olmayan, Hayy ve Kayyum olan yüce Allah\'tan bağışlanmamı dilerim ve O\'na tevbe ederim.',
    latinTranscription: 'Estağfirullahel azimellezi la ilahe illa huvel hayyel kayyume ve etubu ileyh.',
    category: 'İstiğfar',
    source: 'Tirmizi, Hakim',
    benefit: 'Bu duayı okuyan günahları deniz köpüğü kadar bile olsa bağışlanır.',
  ),

  // SALAVAT
  Dua(
    id: 20,
    title: 'Salavat-ı Şerife',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ',
    turkishMeaning: 'Allah\'ım! Efendimiz Muhammed\'e ve Efendimiz Muhammed\'in âline salat eyle.',
    latinTranscription: 'Allahümme salli ala seyyidina Muhammedin ve ala ali seyyidina Muhammed.',
    category: 'Salavat',
    source: 'Hadis',
    benefit: 'Peygamber Efendimiz\'e bir salavat getirene, Allah on salat (rahmet) eder.',
  ),
  Dua(
    id: 21,
    title: 'Salavat-ı Tüncina',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ صَلَاةً تُنْجِينَا بِهَا مِنْ جَمِيعِ الْأَهْوَالِ وَالْآفَاتِ',
    turkishMeaning: 'Allah\'ım! Efendimiz Muhammed\'e ve Efendimiz Muhammed\'in âline öyle bir salat eyle ki, onun hürmetine bizi bütün korku ve afetlerden kurtar.',
    latinTranscription: 'Allahümme salli ala seyyidina Muhammedin ve ala ali seyyidina Muhammedin salaten tuncina biha min cemil ehvali vel afat.',
    category: 'Salavat',
    source: 'Delailü\'l-Hayrat',
    benefit: 'Sıkıntı ve belalardan kurtulmak için okunur.',
  ),

  // EK DUALAR
  Dua(
    id: 22,
    title: 'Kelime-i Tevhid',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ مُحَمَّدٌ رَسُولُ اللَّهِ',
    turkishMeaning: 'Allah\'tan başka ilah yoktur. Muhammed Allah\'ın resulüdür.',
    latinTranscription: 'La ilahe illallah Muhammedün Resulullah.',
    category: 'İstiğfar',
    source: 'Kur\'an ve Hadis',
    benefit: 'Zikirlerin en faziletlisi.',
  ),
  Dua(
    id: 23,
    title: 'Uyumadan Önce Dua',
    arabicText: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    turkishMeaning: 'Allah\'ım! Senin adınla ölür ve dirilirim (uyur ve uyanırım).',
    latinTranscription: 'Bismikallahümme emutu ve ahya.',
    category: 'Akşam Duaları',
    source: 'Buhârî',
    benefit: 'Uyumadan önce okunması sünnettir.',
  ),
  Dua(
    id: 24,
    title: 'Uyanınca Dua',
    arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    turkishMeaning: 'Bizi öldürdükten (uyuttuktan) sonra dirilten (uyandıran) Allah\'a hamd olsun. Dönüş O\'nadır.',
    latinTranscription: 'Elhamdulillahillezi ahyana ba\'de ma ematena ve ileyhinnuşur.',
    category: 'Sabah Duaları',
    source: 'Buhârî',
    benefit: 'Uyanınca ilk okunacak duadır.',
  ),
  Dua(
    id: 25,
    title: 'Sıkıntı Duası',
    arabicText: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    turkishMeaning: 'Senden başka ilah yoktur. Seni tenzih ederim. Gerçekten ben zalimlerden oldum.',
    latinTranscription: 'La ilahe illa ente subhaneke inni kuntu minez zalimin.',
    category: 'Şifa Duaları',
    source: 'Enbiya Suresi, 87. Ayet (Yunus Duası)',
    benefit: 'Hz. Yunus\'un balığın karnında ettiği dua. Sıkıntıları giderir.',
  ),
];

/// Kategoriye göre duaları getir
List<Dua> getDuasByCategory(String category) {
  if (category == 'Tümü') {
    return allDuas;
  }
  return allDuas.where((dua) => dua.category == category).toList();
}

/// Dua ara
List<Dua> searchDuas(String query) {
  final lowerQuery = query.toLowerCase();
  return allDuas.where((dua) {
    return dua.title.toLowerCase().contains(lowerQuery) ||
        dua.turkishMeaning.toLowerCase().contains(lowerQuery) ||
        dua.category.toLowerCase().contains(lowerQuery);
  }).toList();
}
