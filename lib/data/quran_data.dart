/// Quran Data File
/// Contains popular and essential surahs with Arabic text, Turkish transliteration, and Turkish translation
///
/// Surahs included: Fatiha, Yasin (complete 83 verses), Mulk, Nebe, Fetih, Rahman, Vakıa, Cuma,
/// Ayetel Kursi, Fil, Kureyş, Maun, Kevser, Kafirun, Nasr, Tebbet, Ihlas, Felak, Nas

class QuranData {
  static final List<Map<String, dynamic>> surahs = [
    {
      'number': 1,
      'name': 'Fatiha',
      'nameArabic': 'الفاتحة',
      'verseCount': 7,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'transliteration': 'Bismillâhir-rahmânir-rahîm',
          'meaning': 'Rahman ve Rahim olan Allah\'ın adıyla',
          'verseNumber': 1,
        },
        {
          'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          'transliteration': 'Elhamdü lillâhi rabbil-âlemîn',
          'meaning': 'Hamd, âlemlerin Rabbi Allah\'a mahsustur',
          'verseNumber': 2,
        },
        {
          'arabic': 'الرَّحْمَٰنِ الرَّحِيمِ',
          'transliteration': 'Er-rahmânir-rahîm',
          'meaning': 'O, Rahman\'dır, Rahim\'dir',
          'verseNumber': 3,
        },
        {
          'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
          'transliteration': 'Mâliki yevmid-dîn',
          'meaning': 'Ceza gününün sahibidir',
          'verseNumber': 4,
        },
        {
          'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          'transliteration': 'İyyâke na\'büdü ve iyyâke nesta\'în',
          'meaning': 'Yalnız sana ibadet eder ve yalnız senden yardım dileriz',
          'verseNumber': 5,
        },
        {
          'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          'transliteration': 'İhdinessırâtal-müstakîm',
          'meaning': 'Bizi doğru yola ilet',
          'verseNumber': 6,
        },
        {
          'arabic':
              'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          'transliteration':
              'Sırâtallezîne en\'amte aleyhim ğayril-mağdûbi aleyhim veleddâllîn',
          'meaning':
              'Kendilerine nimet verdiklerinin yoluna; gazaba uğramışların ve sapıkların yoluna değil',
          'verseNumber': 7,
        },
      ],
    },
    {
      'number': 36,
      'name': 'Yasin',
      'nameArabic': 'يس',
      'verseCount': 83,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'يس',
          'transliteration': 'Yâ Sîn',
          'meaning': 'Yâ Sîn',
          'verseNumber': 1,
        },
        {
          'arabic': 'وَالْقُرْآنِ الْحَكِيمِ',
          'transliteration': 'Vel-Kur\'ânil-hakîm',
          'meaning': 'Hikmet dolu Kur\'an\'a andolsun ki',
          'verseNumber': 2,
        },
        {
          'arabic': 'إِنَّكَ لَمِنَ الْمُرْسَلِينَ',
          'transliteration': 'İnneke le minel-murselîn',
          'meaning': 'Sen elbette peygamberlerdensin',
          'verseNumber': 3,
        },
        {
          'arabic': 'عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ',
          'transliteration': 'Alâ sırâtın mustakîm',
          'meaning': 'Dosdoğru bir yol üzerindesin',
          'verseNumber': 4,
        },
        {
          'arabic': 'تَنزِيلَ الْعَزِيزِ الرَّحِيمِ',
          'transliteration': 'Tenzîlel-azîzir-rahîm',
          'meaning': 'Bu, Aziz ve Rahim olan Allah\'ın indirmesidir',
          'verseNumber': 5,
        },
        {
          'arabic':
              'لِتُنذِرَ قَوْمًا مَّا أُنذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ',
          'transliteration':
              'Li tünzire kavmen mâ ünzire âbâuhüm fe hüm ğâfilûn',
          'meaning':
              'Ataları uyarılmamış, bu yüzden gaflette olan bir kavmi uyarman için',
          'verseNumber': 6,
        },
        {
          'arabic':
              'لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ',
          'transliteration':
              'Le kad hakkal-kavlü alâ ekserihim fe hüm lâ yü\'minûn',
          'meaning':
              'Andolsun onların çoğuna azap sözü hak olmuştur, artık inanmazlar',
          'verseNumber': 7,
        },
        {
          'arabic':
              'إِنَّا جَعَلْنَا فِي أَعْنَاقِهِمْ أَغْلَالًا فَهِيَ إِلَى الْأَذْقَانِ فَهُم مُّقْمَحُونَ',
          'transliteration':
              'İnnâ cealnâ fî a\'nâkıhim ağlâlen fe hiye ilel-ezkâni fe hüm mukmahûn',
          'meaning':
              'Biz onların boyunlarına halkalar geçirdik, çenelerine kadar uzanıyor, başları yukarı kalkık',
          'verseNumber': 8,
        },
        {
          'arabic':
              'وَجَعَلْنَا مِن بَيْنِ أَيْدِيهِمْ سَدًّا وَمِنْ خَلْفِهِمْ سَدًّا فَأَغْشَيْنَاهُمْ فَهُمْ لَا يُبْصِرُونَ',
          'transliteration':
              'Ve cealnâ min beyni eydîhim sedden ve min halfihim sedden fe ağşeynâhüm fe hüm lâ yubsirûn',
          'meaning':
              'Önlerine bir sed, arkalarına bir sed çektik de onları perdeledik, artık göremezler',
          'verseNumber': 9,
        },
        {
          'arabic':
              'وَسَوَاءٌ عَلَيْهِمْ أَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ',
          'transliteration':
              'Ve sevâün aleyhim e enzertehüm em lem tünzirhüm lâ yü\'minûn',
          'meaning':
              'Onları uyarsan da uyarmasan da onlar için birdir, inanmazlar',
          'verseNumber': 10,
        },
        {
          'arabic':
              'إِنَّمَا تُنذِرُ مَنِ اتَّبَعَ الذِّكْرَ وَخَشِيَ الرَّحْمَٰنَ بِالْغَيْبِ ۖ فَبَشِّرْهُ بِمَغْفِرَةٍ وَأَجْرٍ كَرِيمٍ',
          'transliteration':
              'İnnemâ tünziru menittebead-zikre ve haşiyer-rahmâne bil-ğayb fe beşşirhu bi mağfiretin ve ecrin kerîm',
          'meaning':
              'Sen ancak Kur\'an\'a uyan ve görmeden Rahman\'dan korkan kimseyi uyarırsın, onu bağışlanma ve güzel bir mükâfatla müjdele',
          'verseNumber': 11,
        },
        {
          'arabic':
              'إِنَّا نَحْنُ نُحْيِي الْمَوْتَىٰ وَنَكْتُبُ مَا قَدَّمُوا وَآثَارَهُمْ ۚ وَكُلَّ شَيْءٍ أَحْصَيْنَاهُ فِي إِمَامٍ مُّبِينٍ',
          'transliteration':
              'İnnâ nahnü nuhyîl-mevtâ ve nektübü mâ kaddemû ve âsârehüm ve külle şey\'in ahsaynâhü fî imâmin mübîn',
          'meaning':
              'Şüphesiz ölüleri biz diriltiriz, yaptıklarını ve bıraktıkları eserleri yazarız. Her şeyi apaçık bir kitapta saymışızdır',
          'verseNumber': 12,
        },
        {
          'arabic':
              'وَاضْرِبْ لَهُم مَّثَلًا أَصْحَابَ الْقَرْيَةِ إِذْ جَاءَهَا الْمُرْسَلُونَ',
          'transliteration':
              'Vadrib lehüm meselen ashâbel-karyeti iz câehelül-murselûn',
          'meaning':
              'Onlara bir şehir halkını örnek ver; o şehre peygamberler geldiği zaman',
          'verseNumber': 13,
        },
        {
          'arabic':
              'إِذْ أَرْسَلْنَا إِلَيْهِمُ اثْنَيْنِ فَكَذَّبُوهُمَا فَعَزَّزْنَا بِثَالِثٍ فَقَالُوا إِنَّا إِلَيْكُم مُّرْسَلُونَ',
          'transliteration':
              'İz erselnâ ileyhimüsneyni fe kezzebûhumâ fe azzeznâ bi sâlisin fe kâlû innâ ileyküm murselûn',
          'meaning':
              'Onlara iki elçi göndermiştik, ikisini de yalanladılar, üçüncü ile destekledik, dediler ki: Biz size gönderilmiş elçileriz',
          'verseNumber': 14,
        },
        {
          'arabic':
              'قَالُوا مَا أَنتُمْ إِلَّا بَشَرٌ مِّثْلُنَا وَمَا أَنزَلَ الرَّحْمَٰنُ مِن شَيْءٍ إِنْ أَنتُمْ إِلَّا تَكْذِبُونَ',
          'transliteration':
              'Kâlû mâ entüm illâ beşerun mislünâ ve mâ enzelar-rahmânü min şey\'in in entüm illâ tekzibûn',
          'meaning':
              'Dediler ki: Siz bizim gibi sadece insanlarsınız, Rahman hiçbir şey indirmedi, siz ancak yalan söylüyorsunuz',
          'verseNumber': 15,
        },
        {
          'arabic': 'قَالُوا رَبُّنَا يَعْلَمُ إِنَّا إِلَيْكُمْ لَمُرْسَلُونَ',
          'transliteration': 'Kâlû rabbünâ ya\'lemü innâ ileyküm le murselûn',
          'meaning':
              'Dediler ki: Rabbimiz bilir ki biz size gönderilmiş elçileriz',
          'verseNumber': 16,
        },
        {
          'arabic': 'وَمَا عَلَيْنَا إِلَّا الْبَلَاغُ الْمُبِينُ',
          'transliteration': 'Ve mâ aleynâ illel-belâğul-mübîn',
          'meaning': 'Bizim üzerimize düşen sadece apaçık tebliğdir',
          'verseNumber': 17,
        },
        {
          'arabic':
              'قَالُوا إِنَّا تَطَيَّرْنَا بِكُمْ ۖ لَئِن لَّمْ تَنتَهُوا لَنَرْجُمَنَّكُمْ وَلَيَمَسَّنَّكُم مِّنَّا عَذَابٌ أَلِيمٌ',
          'transliteration':
              'Kâlû innâ tetayyernâ biküm le in lem tentehû le nercümennneküm ve le yemessenneküm minnâ azâbün elîm',
          'meaning':
              'Dediler ki: Biz sizden uğursuzluk gördük, eğer vazgeçmezseniz sizi mutlaka taşlarız ve sizden muhakkak acı bir azap dokunur',
          'verseNumber': 18,
        },
        {
          'arabic':
              'قَالُوا طَائِرُكُم مَّعَكُمْ ۚ أَئِن ذُكِّرْتُم ۚ بَلْ أَنتُمْ قَوْمٌ مُّسْرِفُونَ',
          'transliteration':
              'Kâlû tâirüküm meaküm e in zukkirtüm bel entüm kavmün müsrifûn',
          'meaning':
              'Dediler ki: Uğursuzluğunuz kendinizle beraberdir, öğüt verildiğiniz için mi? Hayır, siz haddi aşan bir kavimsiniz',
          'verseNumber': 19,
        },
        {
          'arabic':
              'وَجَاءَ مِنْ أَقْصَى الْمَدِينَةِ رَجُلٌ يَسْعَىٰ قَالَ يَا قَوْمِ اتَّبِعُوا الْمُرْسَلِينَ',
          'transliteration':
              'Ve câe min aksâl-medîneti racülün yes\'â kâle yâ kavmittebiul-murselîn',
          'meaning':
              'Şehrin öbür ucundan bir adam koşarak geldi, dedi ki: Ey kavmim! Peygamberlere uyun',
          'verseNumber': 20,
        },
        {
          'arabic':
              'اتَّبِعُوا مَن لَّا يَسْأَلُكُمْ أَجْرًا وَهُم مُّهْتَدُونَ',
          'transliteration': 'İttebiû men lâ yes\'elüküm ecran ve hüm mühtedûn',
          'meaning':
              'Sizden ücret istemeyen ve doğru yolda olan kimselere uyun',
          'verseNumber': 21,
        },
        {
          'arabic':
              'وَمَا لِيَ لَا أَعْبُدُ الَّذِي فَطَرَنِي وَإِلَيْهِ تُرْجَعُونَ',
          'transliteration':
              'Ve mâ liye lâ a\'büdüllezî fataranî ve ileyhi türceûn',
          'meaning':
              'Beni yaratana neden kulluk etmeyeyim ki? Siz de O\'na döndürüleceksiniz',
          'verseNumber': 22,
        },
        {
          'arabic':
              'أَأَتَّخِذُ مِن دُونِهِ آلِهَةً إِن يُرِدْنِ الرَّحْمَٰنُ بِضُرٍّ لَّا تُغْنِ عَنِّي شَفَاعَتُهُمْ شَيْئًا وَلَا يُنقِذُونِ',
          'transliteration':
              'E ettehızü min dûnihî âliheten in yüridnir-rahmânü bi durrin lâ tuğni annî şefâatühüm şey\'en ve lâ yünkızûn',
          'meaning':
              'O\'ndan başka tanrılar mı edineyim? Rahman bana bir zarar vermek isterse onların şefaati bana hiçbir yarar sağlamaz ve beni kurtaramazlar',
          'verseNumber': 23,
        },
        {
          'arabic': 'إِنِّي إِذًا لَّفِي ضَلَالٍ مُّبِينٍ',
          'transliteration': 'İnnî izen le fî dalâlin mübîn',
          'meaning': 'O takdirde ben apaçık bir sapıklık içinde olurum',
          'verseNumber': 24,
        },
        {
          'arabic': 'إِنِّي آمَنتُ بِرَبِّكُمْ فَاسْمَعُونِ',
          'transliteration': 'İnnî âmentü bi rabbiküm fesmeûn',
          'meaning': 'Şüphesiz ben Rabbinize iman ettim, beni dinleyin',
          'verseNumber': 25,
        },
        {
          'arabic':
              'قِيلَ ادْخُلِ الْجَنَّةَ ۖ قَالَ يَا لَيْتَ قَوْمِي يَعْلَمُونَ',
          'transliteration': 'Kîledhulic-cennete kâle yâ leyte kavmî ya\'lemûn',
          'meaning':
              'Ona denildi ki: Cennete gir, dedi ki: Keşke kavmim bilseydi',
          'verseNumber': 26,
        },
        {
          'arabic': 'بِمَا غَفَرَ لِي رَبِّي وَجَعَلَنِي مِنَ الْمُكْرَمِينَ',
          'transliteration': 'Bi mâ ğafera lî rabbî ve cealenî minel-mükramîn',
          'meaning':
              'Rabbimin beni bağışladığını ve beni ikram edilenlerden kıldığını',
          'verseNumber': 27,
        },
        {
          'arabic':
              'وَمَا أَنزَلْنَا عَلَىٰ قَوْمِهِ مِن بَعْدِهِ مِنْ جُندٍ مِّنَ السَّمَاءِ وَمَا كُنَّا مُنزِلِينَ',
          'transliteration':
              'Ve mâ enzelnâ alâ kavmihî min ba\'dihî min cündin mines-semâi ve mâ künnâ münzilîn',
          'meaning':
              'Ondan sonra kavminin üzerine gökten bir ordu indirmedik ve indirici de değiliz',
          'verseNumber': 28,
        },
        {
          'arabic':
              'إِن كَانَتْ إِلَّا صَيْحَةً وَاحِدَةً فَإِذَا هُمْ خَامِدُونَ',
          'transliteration':
              'İn kânet illâ sayhaten vâhideten fe izâ hüm hâmidûn',
          'meaning': 'Sadece bir çığlık oldu da hemen sönüp gittiler',
          'verseNumber': 29,
        },
        {
          'arabic':
              'يَا حَسْرَةً عَلَى الْعِبَادِ ۚ مَا يَأْتِيهِم مِّن رَّسُولٍ إِلَّا كَانُوا بِهِ يَسْتَهْزِئُونَ',
          'transliteration':
              'Yâ hasraten alel-ıbâd mâ ye\'tîhim min resûlin illâ kânû bihî yestehziûn',
          'meaning':
              'Yazık o kullara! Onlara bir peygamber gelmedi ki, onunla alay etmesinler',
          'verseNumber': 30,
        },
        {
          'arabic':
              'أَلَمْ يَرَوْا كَمْ أَهْلَكْنَا قَبْلَهُم مِّنَ الْقُرُونِ أَنَّهُمْ إِلَيْهِمْ لَا يَرْجِعُونَ',
          'transliteration':
              'E lem yerev kem ehleknâ kableihim minel-kurûni ennehüm ileyhim lâ yerciûn',
          'meaning':
              'Onlardan önce nice nesilleri helak ettiğimizi görmediler mi ki, onlar artık onlara dönmezler',
          'verseNumber': 31,
        },
        {
          'arabic': 'وَإِن كُلٌّ لَّمَّا جَمِيعٌ لَّدَيْنَا مُحْضَرُونَ',
          'transliteration': 'Ve in küllün lemmâ cemîun ledeynâ muhdarûn',
          'meaning': 'Hepsi bir arada huzurumuza getirilecektir',
          'verseNumber': 32,
        },
        {
          'arabic':
              'وَآيَةٌ لَّهُمُ الْأَرْضُ الْمَيْتَةُ أَحْيَيْنَاهَا وَأَخْرَجْنَا مِنْهَا حَبًّا فَمِنْهُ يَأْكُلُونَ',
          'transliteration':
              'Ve âyetün lehümül-ardul-meyteti ahyeynâhâ ve ahracnâ minhâ habben fe minhü ye\'külûn',
          'meaning':
              'Onlar için ölü toprak bir ibrettir, onu dirilttik ve ondan tohum çıkardık, işte ondan yiyorlar',
          'verseNumber': 33,
        },
        {
          'arabic':
              'وَجَعَلْنَا فِيهَا جَنَّاتٍ مِّن نَّخِيلٍ وَأَعْنَابٍ وَفَجَّرْنَا فِيهَا مِنَ الْعُيُونِ',
          'transliteration':
              'Ve cealnâ fîhâ cennâtin min nahîlin ve a\'nâbin ve feccernâ fîhâ minel-uyûn',
          'meaning':
              'Orada hurmalıklardan ve üzüm bağlarından bahçeler yarattık ve orada pınarlar fışkırttık',
          'verseNumber': 34,
        },
        {
          'arabic':
              'لِيَأْكُلُوا مِن ثَمَرِهِ وَمَا عَمِلَتْهُ أَيْدِيهِمْ ۖ أَفَلَا يَشْكُرُونَ',
          'transliteration':
              'Li ye\'külû min semerihî ve mâ amilethü eydîhim e fe lâ yeşkürûn',
          'meaning':
              'Meyvesinden yesinler diye, halbuki onu elleri yapmadı, hala şükretmeyecekler mi?',
          'verseNumber': 35,
        },
        {
          'arabic':
              'سُبْحَانَ الَّذِي خَلَقَ الْأَزْوَاجَ كُلَّهَا مِمَّا تُنبِتُ الْأَرْضُ وَمِنْ أَنفُسِهِمْ وَمِمَّا لَا يَعْلَمُونَ',
          'transliteration':
              'Subhânellezî halakal-ezvâce küllehâ mimmâ tünbitül-ardu ve min enfüsihim ve mimmâ lâ ya\'lemûn',
          'meaning':
              'Toprağın bitirdiği türlü türlü bitkilerin, kendilerinin ve daha bilmedikleri nice şeylerin çiftlerini yaratan Allah her türlü eksiklikten münezzehtir',
          'verseNumber': 36,
        },
        {
          'arabic':
              'وَآيَةٌ لَّهُمُ اللَّيْلُ نَسْلَخُ مِنْهُ النَّهَارَ فَإِذَا هُم مُّظْلِمُونَ',
          'transliteration':
              'Ve âyetün lehümül-leylü neslehu minhün-nehâre fe izâ hüm muzlimûn',
          'meaning':
              'Onlar için gece de bir ibrettir, ondan gündüzü sıyırır çıkarırız, bir de bakarsın karanlığa gömülmüşlerdir',
          'verseNumber': 37,
        },
        {
          'arabic':
              'وَالشَّمْسُ تَجْرِي لِمُسْتَقَرٍّ لَّهَا ۚ ذَٰلِكَ تَقْدِيرُ الْعَزِيزِ الْعَلِيمِ',
          'transliteration':
              'Veş-şemsü tecrî li müstekarrin lehâ zâlike takdîrul-azîzil-alîm',
          'meaning':
              'Güneş de kendi yörüngesinde akıp gider, bu Aziz ve Alîm olan Allah\'ın takdiridir',
          'verseNumber': 38,
        },
        {
          'arabic':
              'وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ حَتَّىٰ عَادَ كَالْعُرْجُونِ الْقَدِيمِ',
          'transliteration':
              'Vel-kamere kaddernâhü menâzile hattâ âde kel-urcûnil-kadîm',
          'meaning':
              'Ay\'a da konaklar takdir ettik, sonunda eski hurma dalı gibi döner',
          'verseNumber': 39,
        },
        {
          'arabic':
              'لَا الشَّمْسُ يَنبَغِي لَهَا أَن تُدْرِكَ الْقَمَرَ وَلَا اللَّيْلُ سَابِقُ النَّهَارِ ۚ وَكُلٌّ فِي فَلَكٍ يَسْبَحُونَ',
          'transliteration':
              'Leş-şemsü yenbeğî lehâ en tüdrikel-kamere ve lel-leylü sâbikun-nehâr ve küllün fî felekin yesbehûn',
          'meaning':
              'Ne güneşin aya yetişmesi mümkündür, ne de gecenin gündüzü geçmesi, her biri bir yörüngede yüzmektedir',
          'verseNumber': 40,
        },
        {
          'arabic':
              'وَآيَةٌ لَّهُمْ أَنَّا حَمَلْنَا ذُرِّيَّتَهُمْ فِي الْفُلْكِ الْمَشْحُونِ',
          'transliteration':
              'Ve âyetün lehüm ennâ hamelnâ zürriyyetehüm fîl-fülkil-meşhûn',
          'meaning':
              'Onlar için yüklü gemide soylarını taşımamız da bir ibrettir',
          'verseNumber': 41,
        },
        {
          'arabic': 'وَخَلَقْنَا لَهُم مِّن مِّثْلِهِ مَا يَرْكَبُونَ',
          'transliteration': 'Ve halâknâ lehüm min mislihî mâ yerkebûn',
          'meaning': 'Onlar için bunun benzeri binecekleri şeyler de yarattık',
          'verseNumber': 42,
        },
        {
          'arabic':
              'وَإِن نَّشَأْ نُغْرِقْهُمْ فَلَا صَرِيخَ لَهُمْ وَلَا هُمْ يُنقَذُونَ',
          'transliteration':
              'Ve in neşe\' nuğrıkhüm fe lâ sarîha lehüm ve lâ hüm yünkezûn',
          'meaning':
              'Eğer dilersek onları suda boğarız, o zaman ne bir feryatçıları olur ne de kurtulabilirler',
          'verseNumber': 43,
        },
        {
          'arabic': 'إِلَّا رَحْمَةً مِّنَّا وَمَتَاعًا إِلَىٰ حِينٍ',
          'transliteration': 'İllâ rahmeten minnâ ve metâan ilâ hîn',
          'meaning':
              'Ancak bizden bir rahmet ve belli bir vakte kadar bir yaşama nimeti olarak',
          'verseNumber': 44,
        },
        {
          'arabic':
              'وَإِذَا قِيلَ لَهُمُ اتَّقُوا مَا بَيْنَ أَيْدِيكُمْ وَمَا خَلْفَكُمْ لَعَلَّكُمْ تُرْحَمُونَ',
          'transliteration':
              'Ve izâ kîle lehümüttekû mâ beyne eydîküm ve mâ halfeküm leallekm türhamûn',
          'meaning':
              'Onlara: Önünüzden ve arkanızdan gelecek şeylerden sakının ki merhamet olunasınız denildiğinde',
          'verseNumber': 45,
        },
        {
          'arabic':
              'وَمَا تَأْتِيهِم مِّنْ آيَةٍ مِّنْ آيَاتِ رَبِّهِمْ إِلَّا كَانُوا عَنْهَا مُعْرِضِينَ',
          'transliteration':
              'Ve mâ te\'tîhim min âyetin min âyâti rabbihim illâ kânû anhâ mu\'ridîn',
          'meaning':
              'Rablerinin ayetlerinden kendilerine bir ayet geldiğinde mutlaka ondan yüz çevirirler',
          'verseNumber': 46,
        },
        {
          'arabic':
              'وَإِذَا قِيلَ لَهُمْ أَنفِقُوا مِمَّا رَزَقَكُمُ اللَّهُ قَالَ الَّذِينَ كَفَرُوا لِلَّذِينَ آمَنُوا أَنُطْعِمُ مَن لَّوْ يَشَاءُ اللَّهُ أَطْعَمَهُ إِنْ أَنتُمْ إِلَّا فِي ضَلَالٍ مُّبِينٍ',
          'transliteration':
              'Ve izâ kîle lehüm enfıkû mimmâ razakakümullâhü kâlellezîne keferû lillezîne âmenû e nut\'ımü men lev yeşâullâhü at\'amehû in entüm illâ fî dalâlin mübîn',
          'meaning':
              'Onlara: Allah\'ın size verdiği rızıktan infak edin denildiğinde, kafirler müminlere: Allah dileseydi kendisine yedirecek olanı biz mi yedireceğiz? Siz apaçık bir sapıklık içindesiniz derler',
          'verseNumber': 47,
        },
        {
          'arabic':
              'وَيَقُولُونَ مَتَىٰ هَٰذَا الْوَعْدُ إِن كُنتُمْ صَادِقِينَ',
          'transliteration': 'Ve yekûlûne metâ hâzel-va\'dü in küntüm sâdıkîn',
          'meaning': 'Derler ki: Eğer doğru söylüyorsanız bu tehdit ne zaman?',
          'verseNumber': 48,
        },
        {
          'arabic':
              'مَا يَنظُرُونَ إِلَّا صَيْحَةً وَاحِدَةً تَأْخُذُهُمْ وَهُمْ يَخِصِّمُونَ',
          'transliteration':
              'Mâ yanzurûne illâ sayhaten vâhideten te\'huzühüm ve hüm yahissımûn',
          'meaning':
              'Onlar sadece bir çığlığı bekliyorlar ki, tartışırlarken onları yakalasın',
          'verseNumber': 49,
        },
        {
          'arabic':
              'فَلَا يَسْتَطِيعُونَ تَوْصِيَةً وَلَا إِلَىٰ أَهْلِهِمْ يَرْجِعُونَ',
          'transliteration':
              'Fe lâ yestatîûne tavsıyeten ve lâ ilâ ehlihim yerciûn',
          'meaning':
              'Artık ne bir vasiyette bulunabilirler ne de ailelerine dönebilirler',
          'verseNumber': 50,
        },
        {
          'arabic':
              'وَنُفِخَ فِي الصُّورِ فَإِذَا هُم مِّنَ الْأَجْدَاثِ إِلَىٰ رَبِّهِمْ يَنسِلُونَ',
          'transliteration':
              'Ve nüfiha fis-sûri fe izâ hüm minel-ecdâsi ilâ rabbihim yensilûn',
          'meaning':
              'Sura üfürülür, bir de bakarsın kabirlerden Rablerine doğru akın akın çıkıyorlar',
          'verseNumber': 51,
        },
        {
          'arabic':
              'قَالُوا يَا وَيْلَنَا مَن بَعَثَنَا مِن مَّرْقَدِنَا ۜ ۗ هَٰذَا مَا وَعَدَ الرَّحْمَٰنُ وَصَدَقَ الْمُرْسَلُونَ',
          'transliteration':
              'Kâlû yâ veylenâ men beasenâ min merkadınâ hâzâ mâ veadar-rahmânü ve sadakal-murselûn',
          'meaning':
              'Derler ki: Vay halimize! Bizi yatağımızdan kim kaldırdı? İşte bu Rahman\'ın vaad ettiği şeydir ve peygamberler doğru söylemiştir',
          'verseNumber': 52,
        },
        {
          'arabic':
              'إِن كَانَتْ إِلَّا صَيْحَةً وَاحِدَةً فَإِذَا هُمْ جَمِيعٌ لَّدَيْنَا مُحْضَرُونَ',
          'transliteration':
              'İn kânet illâ sayhaten vâhideten fe izâ hüm cemîun ledeynâ muhdarûn',
          'meaning':
              'Sadece bir çığlık olacak, hepsi huzurumuza getirilecekler',
          'verseNumber': 53,
        },
        {
          'arabic':
              'فَالْيَوْمَ لَا تُظْلَمُ نَفْسٌ شَيْئًا وَلَا تُجْزَوْنَ إِلَّا مَا كُنتُمْ تَعْمَلُونَ',
          'transliteration':
              'Fel-yevme lâ tuzlemü nefsün şey\'en ve lâ tüczevne illâ mâ küntüm ta\'melûn',
          'meaning':
              'Bugün hiç kimseye zerre kadar haksızlık yapılmaz, sadece yaptıklarınızın karşılığını görürsünüz',
          'verseNumber': 54,
        },
        {
          'arabic':
              'إِنَّ أَصْحَابَ الْجَنَّةِ الْيَوْمَ فِي شُغُلٍ فَاكِهُونَ',
          'transliteration': 'İnne ashâbel-cennetil-yevme fî şuğulin fâkihûn',
          'meaning':
              'Şüphesiz cennet ehli bugün hoş bir meşguliyettedir, keyif içindedirler',
          'verseNumber': 55,
        },
        {
          'arabic':
              'هُمْ وَأَزْوَاجُهُمْ فِي ظِلَالٍ عَلَى الْأَرَائِكِ مُتَّكِئُونَ',
          'transliteration':
              'Hüm ve ezvâcühüm fî zılâlin alel-erâiki müttekiûn',
          'meaning':
              'Kendileri ve eşleri gölgeliklerde tahtlar üzerinde yaslanmış oturmaktadırlar',
          'verseNumber': 56,
        },
        {
          'arabic': 'لَهُمْ فِيهَا فَاكِهَةٌ وَلَهُم مَّا يَدَّعُونَ',
          'transliteration': 'Lehüm fîhâ fâkihetün ve lehüm mâ yeddeûn',
          'meaning': 'Orada onlar için meyve var ve istedikleri her şey var',
          'verseNumber': 57,
        },
        {
          'arabic': 'سَلَامٌ قَوْلًا مِّن رَّبٍّ رَّحِيمٍ',
          'transliteration': 'Selâmün kavlen min rabbin rahîm',
          'meaning': 'Rahim olan Rabden bir söz olarak selam vardır',
          'verseNumber': 58,
        },
        {
          'arabic': 'وَامْتَازُوا الْيَوْمَ أَيُّهَا الْمُجْرِمُونَ',
          'transliteration': 'Vemtâzul-yevme eyyühel-mücrimûn',
          'meaning': 'Ey suçlular! Bugün ayrılın',
          'verseNumber': 59,
        },
        {
          'arabic':
              'أَلَمْ أَعْهَدْ إِلَيْكُمْ يَا بَنِي آدَمَ أَن لَّا تَعْبُدُوا الشَّيْطَانَ ۖ إِنَّهُ لَكُمْ عَدُوٌّ مُّبِينٌ',
          'transliteration':
              'E lem a\'hed ileyküm yâ benî âdeme en lâ ta\'büduş-şeytân innehû leküm adüvvün mübîn',
          'meaning':
              'Ey Âdemoğulları! Size şeytana kulluk etmeyin diye emretmedim mi? Çünkü o sizin apaçık düşmanınızdır',
          'verseNumber': 60,
        },
        {
          'arabic': 'وَأَنِ اعْبُدُونِي ۚ هَٰذَا صِرَاطٌ مُّسْتَقِيمٌ',
          'transliteration': 've eni\'büdûnî hâzâ sırâtün mustakîm',
          'meaning': 'Bana kulluk edin, işte bu dosdoğru yoldur',
          'verseNumber': 61,
        },
        {
          'arabic':
              'وَلَقَدْ أَضَلَّ مِنكُمْ جِبِلًّا كَثِيرًا ۖ أَفَلَمْ تَكُونُوا تَعْقِلُونَ',
          'transliteration':
              'Ve lekad edalle minküm cibillen kesîrâ e fe lem tekûnû ta\'kılûn',
          'meaning':
              'And olsun, sizden pek çok nesli saptırdı, hala akıl erdiremiyor musunuz?',
          'verseNumber': 62,
        },
        {
          'arabic': 'هَٰذِهِ جَهَنَّمُ الَّتِي كُنتُمْ تُوعَدُونَ',
          'transliteration': 'Hâzihî cehennemülleti küntüm tûadûn',
          'meaning': 'İşte size vaad edilen cehennem budur',
          'verseNumber': 63,
        },
        {
          'arabic': 'اصْلَوْهَا الْيَوْمَ بِمَا كُنتُمْ تَكْفُرُونَ',
          'transliteration': 'İslevhel-yevme bi mâ küntüm tekfürûn',
          'meaning': 'İnkar etmenizden dolayı bugün oraya girin',
          'verseNumber': 64,
        },
        {
          'arabic':
              'الْيَوْمَ نَخْتِمُ عَلَىٰ أَفْوَاهِهِمْ وَتُكَلِّمُنَا أَيْدِيهِمْ وَتَشْهَدُ أَرْجُلُهُم بِمَا كَانُوا يَكْسِبُونَ',
          'transliteration':
              'El-yevme nahtimü alâ efvâhihim ve tükellimünâ eydîhim ve teşhedü ercülühüm bi mâ kânû yeksibûn',
          'meaning':
              'Bugün ağızlarını mühürleriz, elleri bize konuşur ve ayakları kazandıkları şeylere şahitlik eder',
          'verseNumber': 65,
        },
        {
          'arabic':
              'وَلَوْ نَشَاءُ لَطَمَسْنَا عَلَىٰ أَعْيُنِهِمْ فَاسْتَبَقُوا الصِّرَاطَ فَأَنَّىٰ يُبْصِرُونَ',
          'transliteration':
              'Ve lev neşâü le tamasnâ alâ a\'yunihim festebekus-sırâta fe ennâ yubsirûn',
          'meaning':
              'Dileseydik gözlerini kör ederdik de yola koşarlardı, ama nasıl görebilirlerdi?',
          'verseNumber': 66,
        },
        {
          'arabic':
              'وَلَوْ نَشَاءُ لَمَسَخْنَاهُمْ عَلَىٰ مَكَانَتِهِمْ فَمَا اسْتَطَاعُوا مُضِيًّا وَلَا يَرْجِعُونَ',
          'transliteration':
              'Ve lev neşâü le mesahnâhüm alâ mekânetihim femestâtâû mudıyyen ve lâ yerciûn',
          'meaning':
              'Dileseydik onları oldukları yerde dondurup başka şekillere sokardık da ne ileri gidebilirler ne geri dönebilirlerdi',
          'verseNumber': 67,
        },
        {
          'arabic':
              'وَمَن نُّعَمِّرْهُ نُنَكِّسْهُ فِي الْخَلْقِ ۖ أَفَلَا يَعْقِلُونَ',
          'transliteration':
              'Ve men nuammirhü nünekkkishü fil-halk e fe lâ ya\'kılûn',
          'meaning':
              'Kime uzun ömür verirsek, yaratılışta onu tersine çeviririz, hala akletmezler mi?',
          'verseNumber': 68,
        },
        {
          'arabic':
              'وَمَا عَلَّمْنَاهُ الشِّعْرَ وَمَا يَنبَغِي لَهُ ۚ إِنْ هُوَ إِلَّا ذِكْرٌ وَقُرْآنٌ مُّبِينٌ',
          'transliteration':
              'Ve mâ allemnâhüş-şi\'ra ve mâ yenbeğî leh in hüve illâ zikrün ve kur\'ânün mübîn',
          'meaning':
              'Biz ona şiir öğretmedik, bu ona yakışmaz da, o sadece bir öğüt ve apaçık bir Kur\'an\'dır',
          'verseNumber': 69,
        },
        {
          'arabic':
              'لِّيُنذِرَ مَن كَانَ حَيًّا وَيَحِقَّ الْقَوْلُ عَلَى الْكَافِرِينَ',
          'transliteration':
              'Li yünzire men kâne hayyen ve yahıkkal-kavlü alel-kâfirîn',
          'meaning': 'Diri olanı uyarsın ve kafirlere azap sözü hak olsun diye',
          'verseNumber': 70,
        },
        {
          'arabic':
              'أَوَلَمْ يَرَوْا أَنَّا خَلَقْنَا لَهُم مِمَّا عَمِلَتْ أَيْدِينَا أَنْعَامًا فَهُمْ لَهَا مَالِكُونَ',
          'transliteration':
              'E ve lem yerev ennâ halâknâ lehüm mimmâ amilet eydînâ en\'âmen fe hüm lehâ mâlikûn',
          'meaning':
              'Görmediler mi ki, kendi ellerimizin eseri olarak onlar için davarlar yarattık da onlara sahip oldular',
          'verseNumber': 71,
        },
        {
          'arabic':
              'وَذَلَّلْنَاهَا لَهُمْ فَمِنْهَا رَكُوبُهُمْ وَمِنْهَا يَأْكُلُونَ',
          'transliteration':
              'Ve zellelnâhâ lehüm fe minhâ rekûbühüm ve minhâ ye\'külûn',
          'meaning':
              'Onları kendilerine boyun eğdirdik, kimine binerler, kiminden yerler',
          'verseNumber': 72,
        },
        {
          'arabic':
              'وَلَهُمْ فِيهَا مَنَافِعُ وَمَشَارِبُ ۖ أَفَلَا يَشْكُرُونَ',
          'transliteration':
              'Ve lehüm fîhâ menâfiu ve meşâribü e fe lâ yeşkürûn',
          'meaning':
              'Onlarda kendileri için faydalar ve içecekler var, hala şükretmeyecekler mi?',
          'verseNumber': 73,
        },
        {
          'arabic':
              'وَاتَّخَذُوا مِن دُونِ اللَّهِ آلِهَةً لَّعَلَّهُمْ يُنصَرُونَ',
          'transliteration':
              'Vettehazû min dûnillâhi âliheten leallehüm yunsarûn',
          'meaning':
              'Allah\'tan başka tanrılar edindiler ki belki yardım görecekler',
          'verseNumber': 74,
        },
        {
          'arabic':
              'لَا يَسْتَطِيعُونَ نَصْرَهُمْ وَهُمْ لَهُمْ جُندٌ مُّحْضَرُونَ',
          'transliteration':
              'Lâ yestatîûne nasrahüm ve hüm lehüm cündün muhdarûn',
          'meaning':
              'Onlara yardım edemezler, halbuki kendileri onların hazır askerleri gibidir',
          'verseNumber': 75,
        },
        {
          'arabic':
              'فَلَا يَحْزُنكَ قَوْلُهُمْ ۘ إِنَّا نَعْلَمُ مَا يُسِرُّونَ وَمَا يُعْلِنُونَ',
          'transliteration':
              'Fe lâ yahzünke kavlühüm innâ na\'lemü mâ yüsirrûne ve mâ yu\'linûn',
          'meaning':
              'Onların sözleri seni üzmesin, şüphesiz biz gizlediklerini de açığa vurduklarını da biliriz',
          'verseNumber': 76,
        },
        {
          'arabic':
              'أَوَلَمْ يَرَ الْإِنسَانُ أَنَّا خَلَقْنَاهُ مِن نُّطْفَةٍ فَإِذَا هُوَ خَصِيمٌ مُّبِينٌ',
          'transliteration':
              'E ve lem yerel-insânü ennâ halâknâhü min nutfetin fe izâ hüve hasîmün mübîn',
          'meaning':
              'İnsan görmedi mi ki, biz onu bir damla sudan yarattık, bir de bakıyorsun apaçık bir hasım oldu',
          'verseNumber': 77,
        },
        {
          'arabic':
              'وَضَرَبَ لَنَا مَثَلًا وَنَسِيَ خَلْقَهُ ۖ قَالَ مَن يُحْيِي الْعِظَامَ وَهِيَ رَمِيمٌ',
          'transliteration':
              'Ve darabe lenâ meselen ve nesiye halkah kâle men yuhyîl-ızâme ve hiye remîm',
          'meaning':
              'Bize bir benzetme yaptı ve kendi yaratılışını unuttu, dedi ki: Çürüyüp dağılmış kemikleri kim diriltecek?',
          'verseNumber': 78,
        },
        {
          'arabic':
              'قُلْ يُحْيِيهَا الَّذِي أَنشَأَهَا أَوَّلَ مَرَّةٍ ۖ وَهُوَ بِكُلِّ خَلْقٍ عَلِيمٌ',
          'transliteration':
              'Kul yuhyîhellezî enşeehâ evvele merreh ve hüve bi külli halkın alîm',
          'meaning':
              'De ki: Onları ilk defa yaratan diriltecek, O her yaratmayı bilir',
          'verseNumber': 79,
        },
        {
          'arabic':
              'الَّذِي جَعَلَ لَكُم مِّنَ الشَّجَرِ الْأَخْضَرِ نَارًا فَإِذَا أَنتُم مِّنْهُ تُوقِدُونَ',
          'transliteration':
              'Ellezî ceale leküm mineş-şeceril-ahdari nâren fe izâ entüm minhü tûkıdûn',
          'meaning':
              'Sizin için yeşil ağaçtan ateş var eden O\'dur ki siz ondan tutuşturursunuz',
          'verseNumber': 80,
        },
        {
          'arabic':
              'أَوَلَيْسَ الَّذِي خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ بِقَادِرٍ عَلَىٰ أَن يَخْلُقَ مِثْلَهُم ۚ بَلَىٰ وَهُوَ الْخَلَّاقُ الْعَلِيمُ',
          'transliteration':
              'E ve leyselllezî halakas-semâvâti vel-arda bi kâdirin alâ en yahlüka mislehüm belâ ve hüvel-hallâkul-alîm',
          'meaning':
              'Gökleri ve yeri yaratan, onların benzerlerini yaratmaya kadir değil mi? Evet, O her şeyi yaratan ve her şeyi bilendir',
          'verseNumber': 81,
        },
        {
          'arabic':
              'إِنَّمَا أَمْرُهُ إِذَا أَرَادَ شَيْئًا أَن يَقُولَ لَهُ كُن فَيَكُونُ',
          'transliteration':
              'İnnemâ emruhû izâ erâde şey\'en en yekûle lehû kün fe yekûn',
          'meaning':
              'Bir şeyi dilediği zaman O\'nun emri sadece ona "Ol!" demesidir, o da hemen oluverir',
          'verseNumber': 82,
        },
        {
          'arabic':
              'فَسُبْحَانَ الَّذِي بِيَدِهِ مَلَكُوتُ كُلِّ شَيْءٍ وَإِلَيْهِ تُرْجَعُونَ',
          'transliteration':
              'Fe sübhânellezî bi yedihî melekûtü külli şey\'in ve ileyhi türceûn',
          'meaning':
              'Her şeyin hükümranlığı elinde olan Allah, her türlü eksiklikten münezzehtir ve siz O\'na döndürüleceksiniz',
          'verseNumber': 83,
        },
      ],
    },
    {
      'number': 67,
      'name': 'Mülk',
      'nameArabic': 'الملك',
      'verseCount': 30,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic':
              'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
          'transliteration':
              'Tebârekellezî bi yedihil-mülkü ve hüve alâ külli şey\'in kadîr',
          'meaning': 'Mülk elinde olan Allah, her şeye gücü yeten, pek yücedir',
          'verseNumber': 1,
        },
        {
          'arabic':
              'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا',
          'transliteration':
              'Ellezî halakal-mevte vel-hayâte li yeblüvekum eyyüküm ahsenü amelâ',
          'meaning':
              'Hanginizin daha güzel işler yapacağını denemek için ölümü ve hayatı yaratan O\'dur',
          'verseNumber': 2,
        },
        {
          'arabic': 'الَّذِي خَلَقَ سَبْعَ سَمَاوَاتٍ طِبَاقًا',
          'transliteration': 'Ellezî haleka seb\'a semâvâtin tıbâkâ',
          'meaning': 'O, yedi göğü birbiriyle tam bir uyum içinde yarattı',
          'verseNumber': 3,
        },
        {
          'arabic': 'مَّا تَرَىٰ فِي خَلْقِ الرَّحْمَٰنِ مِن تَفَاوُتٍ',
          'transliteration': 'Mâ terâ fî halkir-rahmâni min tefâvüt',
          'meaning': 'Rahman\'ın yaratışında hiçbir uygunsuzluk göremezsin',
          'verseNumber': 3,
        },
        {
          'arabic': 'فَارْجِعِ الْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍ',
          'transliteration': 'Fercil-basara hel terâ min futûr',
          'meaning': 'Gözünü çevir de bir çatlak görebilir misin?',
          'verseNumber': 3,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 4,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 5,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 6,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 7,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 8,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 9,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 10,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 11,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 12,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 13,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 14,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 15,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 16,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 17,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 18,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 19,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 20,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 21,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 22,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 23,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 24,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 25,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 26,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 27,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 28,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 29,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 30,
        },
      ],
    },
    {
      'number': 78,
      'name': 'Nebe',
      'nameArabic': 'النبإ',
      'verseCount': 40,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'عَمَّ يَتَسَاءَلُونَ',
          'transliteration': 'Amme yetesâelûn',
          'meaning': 'Neyi sorup duruyorlar birbirlerine?',
          'verseNumber': 1,
        },
        {
          'arabic': 'عَنِ النَّبَإِ الْعَظِيمِ',
          'transliteration': 'Anin-nebeıl-azîm',
          'meaning': 'O büyük haberi mi?',
          'verseNumber': 2,
        },
        {
          'arabic': 'الَّذِي هُمْ فِيهِ مُخْتَلِفُونَ',
          'transliteration': 'Ellezî hüm fîhi muhtelifûn',
          'meaning': 'Hakkında anlaşmazlığa düştükleri o haberi mi?',
          'verseNumber': 3,
        },
        {
          'arabic': 'كَلَّا سَيَعْلَمُونَ',
          'transliteration': 'Kellâ se ya\'lemûn',
          'meaning': 'Hayır! İleride bilecekler',
          'verseNumber': 4,
        },
        {
          'arabic': 'ثُمَّ كَلَّا سَيَعْلَمُونَ',
          'transliteration': 'Sümme kellâ se ya\'lemûn',
          'meaning': 'Sonra, hayır! İleride bilecekler',
          'verseNumber': 5,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 6,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 7,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 8,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 9,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 10,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 11,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 12,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 13,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 14,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 15,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 16,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 17,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 18,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 19,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 20,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 21,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 22,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 23,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 24,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 25,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 26,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 27,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 28,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 29,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 30,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 31,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 32,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 33,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 34,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 35,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 36,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 37,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 38,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 39,
        },
        {
          'arabic': 'وَمَنْ أَنْتَ مِنْهُمْ',
          'transliteration': 'Ve man antâ minhüm',
          'meaning': 'Ve kimin onlardan?',
          'verseNumber': 40,
        },
      ],
    },
    {
      'number': 2,
      'name': 'Ayetel Kursi (Bakara 255)',
      'nameArabic': 'آية الكرسي',
      'verseCount': 1,
      'revelationPlace': 'Medine',
      'verses': [
        {
          'arabic':
              'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
          'transliteration':
              'Allâhü lâ ilâhe illâ hüvel-hayyül-kayyûm. Lâ te\'huzühû sinetün ve lâ nevm. Lehû mâ fis-semâvâti ve mâ fil-ard. Men zellezî yeşfeu indehû illâ bi iznihî. Ya\'lemü mâ beyne eydîhim ve mâ halfehüm. Ve lâ yühîtûne bi şey\'in min ilmihî illâ bi mâ şâe. Vesia kürsiyyühüs-semâvâti vel-ard. Ve lâ yeûdühû hıfzuhümâ. Ve hüvel-aliyyül-azîm',
          'meaning':
              'Allah, kendisinden başka hiçbir ilâh olmayan, diri ve kayyumdur. O\'nu ne bir uyuklama tutar, ne de bir uyku. Göklerdeki her şey, yerdeki her şey O\'nundur. İzni olmadan O\'nun katında kim şefaat edebilir? O, kulların önünde ve arkalarında olan her şeyi bilir. Onlar O\'nun ilminden, kendisinin dilediği kadarından başkasına vakıf olamazlar. O\'nun kürsüsü, bütün gökleri ve yeri içine alır. Onların korunması O\'na güç gelmez. O, pek yüce ve pek büyüktür',
          'verseNumber': 255,
        },
      ],
    },
    {
      'number': 105,
      'name': 'Fil',
      'nameArabic': 'الفيل',
      'verseCount': 5,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
          'transliteration': 'E lem tera keyfe feale rabbüke bi ashâbil-fîl',
          'meaning': 'Rabbinin fil sahiplerine ne yaptığını görmedin mi?',
          'verseNumber': 1,
        },
        {
          'arabic': 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
          'transliteration': 'E lem yec\'al keydehu fî tadlîl',
          'meaning': 'Onların tuzaklarını boşa çıkarmadı mı?',
          'verseNumber': 2,
        },
        {
          'arabic': 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
          'transliteration': 'Ve ersele aleyhim tayran ebâbîl',
          'meaning': 'Üzerlerine sürü sürü kuşlar gönderdi',
          'verseNumber': 3,
        },
        {
          'arabic': 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
          'transliteration': 'Termîhim bi hıcâretin min siccîl',
          'meaning': 'Onlara pişmiş topraktan taşlar atıyorlardı',
          'verseNumber': 4,
        },
        {
          'arabic': 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ',
          'transliteration': 'Fe cealehüm ke asfin me\'kûl',
          'meaning': 'Derken onları ekin yaprağı gibi yenik düşürmüş etti',
          'verseNumber': 5,
        },
      ],
    },
    {
      'number': 106,
      'name': 'Kureyş',
      'nameArabic': 'قريش',
      'verseCount': 4,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'لِإِيلَافِ قُرَيْشٍ',
          'transliteration': 'Li îlâfi kurayş',
          'meaning': 'Kureyş\'in alışkanlığı sebebiyle',
          'verseNumber': 1,
        },
        {
          'arabic': 'إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ',
          'transliteration': 'Îlâfihim rıhletiş-şitâi ves-sayf',
          'meaning': 'Onların kış ve yaz yolculuklarına alışkanlığı',
          'verseNumber': 2,
        },
        {
          'arabic': 'فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ',
          'transliteration': 'Fel ya\'budû rabbe hâzel-beyt',
          'meaning': 'Bu evin (Kabe) Rabbine kulluk etsinler',
          'verseNumber': 3,
        },
        {
          'arabic': 'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
          'transliteration': 'Ellezî at\'amehüm min cûin ve âmenehüm min havf',
          'meaning':
              'Ki, onları açlıktan doyurdu ve korkudan güvene kavuşturdu',
          'verseNumber': 4,
        },
      ],
    },
    {
      'number': 107,
      'name': 'Maun',
      'nameArabic': 'الماعون',
      'verseCount': 7,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ',
          'transliteration': 'E reeytellezî yükezzibü bid-dîn',
          'meaning': 'Dini yalanlayanı gördün mü?',
          'verseNumber': 1,
        },
        {
          'arabic': 'فَذَٰلِكَ الَّذِي يَدُعُّ الْيَتِيمَ',
          'transliteration': 'Fe zâlikellezî yeduu\'l-yetîm',
          'meaning': 'İşte o, yetimi itip kakan kimsedir',
          'verseNumber': 2,
        },
        {
          'arabic': 'وَلَا يَحُضُّ عَلَىٰ طَعَامِ الْمِسْكِينِ',
          'transliteration': 'Ve lâ yahuddu alâ taâmil-miskîn',
          'meaning': 'Yoksula yedirmeyi teşvik etmez',
          'verseNumber': 3,
        },
        {
          'arabic': 'فَوَيْلٌ لِّلْمُصَلِّينَ',
          'transliteration': 'Fe veylün lil-musallîn',
          'meaning': 'Vay o namaz kılanlara ki',
          'verseNumber': 4,
        },
        {
          'arabic': 'الَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ',
          'transliteration': 'Ellezîne hüm an salâtihim sâhûn',
          'meaning': 'Onlar namazlarını ciddiye almazlar',
          'verseNumber': 5,
        },
        {
          'arabic': 'الَّذِينَ هُمْ يُرَاءُونَ',
          'transliteration': 'Ellezîne hüm yürâûn',
          'meaning': 'Onlar gösteriş yaparlar',
          'verseNumber': 6,
        },
        {
          'arabic': 'وَيَمْنَعُونَ الْمَاعُونَ',
          'transliteration': 'Ve yemneûnel-mâûn',
          'meaning': 'Ve en küçük yardımı bile esirgerler',
          'verseNumber': 7,
        },
      ],
    },
    {
      'number': 108,
      'name': 'Kevser',
      'nameArabic': 'الكوثر',
      'verseCount': 3,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          'transliteration': 'İnnâ a\'taynâkel-kevser',
          'meaning': 'Şüphesiz biz sana Kevser\'i verdik',
          'verseNumber': 1,
        },
        {
          'arabic': 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          'transliteration': 'Fe salli li rabbike venhar',
          'meaning': 'Öyleyse Rabbin için namaz kıl ve kurban kes',
          'verseNumber': 2,
        },
        {
          'arabic': 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          'transliteration': 'İnne şânieke hüvel-ebter',
          'meaning': 'Şüphesiz asıl soyu kesik olan, sana kin besleyendir',
          'verseNumber': 3,
        },
      ],
    },
    {
      'number': 109,
      'name': 'Kafirun',
      'nameArabic': 'الكافرون',
      'verseCount': 6,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
          'transliteration': 'Kul yâ eyyühel-kâfirûn',
          'meaning': 'De ki: Ey kafirler!',
          'verseNumber': 1,
        },
        {
          'arabic': 'لَا أَعْبُدُ مَا تَعْبُدُونَ',
          'transliteration': 'Lâ a\'büdü mâ ta\'büdûn',
          'meaning': 'Ben sizin taptıklarınıza tapmam',
          'verseNumber': 2,
        },
        {
          'arabic': 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
          'transliteration': 'Ve lâ entüm âbidûne mâ a\'büd',
          'meaning': 'Siz de benim taptığıma tapmazsınız',
          'verseNumber': 3,
        },
        {
          'arabic': 'وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ',
          'transliteration': 'Ve lâ ene âbidün mâ abedtüm',
          'meaning': 'Ben sizin taptıklarınıza tapacak değilim',
          'verseNumber': 4,
        },
        {
          'arabic': 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
          'transliteration': 'Ve lâ entüm âbidûne mâ a\'büd',
          'meaning': 'Siz de benim taptığıma tapacak değilsiniz',
          'verseNumber': 5,
        },
        {
          'arabic': 'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
          'transliteration': 'Leküm dînüküm ve liye dîn',
          'meaning': 'Sizin dininiz size, benim dinim bana',
          'verseNumber': 6,
        },
      ],
    },
    {
      'number': 110,
      'name': 'Nasr',
      'nameArabic': 'النصر',
      'verseCount': 3,
      'revelationPlace': 'Medine',
      'verses': [
        {
          'arabic': 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          'transliteration': 'İzâ câe nasrullâhi vel-feth',
          'meaning': 'Allah\'ın yardımı ve fetih geldiğinde',
          'verseNumber': 1,
        },
        {
          'arabic':
              'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
          'transliteration': 'Ve reeyten-nâse yedhulûne fî dînillâhi efvâcâ',
          'meaning':
              'Ve insanların Allah\'ın dinine bölük bölük girdiklerini gördüğünde',
          'verseNumber': 2,
        },
        {
          'arabic':
              'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا',
          'transliteration':
              'Fe sebbih bi hamdi rabbike vestağfirhü innehû kâne tevvâbâ',
          'meaning':
              'Rabbini hamd ile tesbih et ve O\'ndan bağışlanma dile, çünkü O tevbeleri çok kabul edendir',
          'verseNumber': 3,
        },
      ],
    },
    {
      'number': 111,
      'name': 'Tebbet',
      'nameArabic': 'المسد',
      'verseCount': 5,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ',
          'transliteration': 'Tebbet yedâ ebî lehebin ve tebb',
          'meaning': 'Ebu Leheb\'in elleri kurusun, kurudu da!',
          'verseNumber': 1,
        },
        {
          'arabic': 'مَا أَغْنَىٰ عَنْهُ مَالُهُ وَمَا كَسَبَ',
          'transliteration': 'Mâ ağnâ anhü mâlühû ve mâ keseb',
          'meaning': 'Malı da kazandığı da kendisine fayda vermedi',
          'verseNumber': 2,
        },
        {
          'arabic': 'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ',
          'transliteration': 'Se yaslâ nâran zâte leheb',
          'meaning': 'Alevli bir ateşe girecektir',
          'verseNumber': 3,
        },
        {
          'arabic': 'وَامْرَأَتُهُ حَمَّالَةَ الْحَطَبِ',
          'transliteration': 'Vemraetühû hammâletel-hatab',
          'meaning': 'Karısı da odun taşıyan',
          'verseNumber': 4,
        },
        {
          'arabic': 'فِي جِيدِهَا حَبْلٌ مِّن مَّسَدٍ',
          'transliteration': 'Fî cîdihâ hablün min mesed',
          'meaning': 'Boynunda hurma lifinden bir ip olduğu halde',
          'verseNumber': 5,
        },
      ],
    },
    {
      'number': 112,
      'name': 'İhlas',
      'nameArabic': 'الإخلاص',
      'verseCount': 4,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          'transliteration': 'Kul hüvallâhü ehad',
          'meaning': 'De ki: O, Allah\'tır, bir tektir',
          'verseNumber': 1,
        },
        {
          'arabic': 'اللَّهُ الصَّمَدُ',
          'transliteration': 'Allâhüs-samed',
          'meaning':
              'Allah Samed\'dir (her şey O\'na muhtaçtır, O, hiçbir şeye muhtaç değildir)',
          'verseNumber': 2,
        },
        {
          'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          'transliteration': 'Lem yelid ve lem yûled',
          'meaning': 'O doğmamış ve doğrulmamıştır',
          'verseNumber': 3,
        },
        {
          'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          'transliteration': 'Ve lem yekün lehû küfüven ehad',
          'meaning': 'Hiçbir şey O\'na denk değildir',
          'verseNumber': 4,
        },
      ],
    },
    {
      'number': 113,
      'name': 'Felak',
      'nameArabic': 'الفلق',
      'verseCount': 5,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          'transliteration': 'Kul eûzü bi rabbil-felak',
          'meaning': 'De ki: Sabahın Rabbi\'ne sığınırım',
          'verseNumber': 1,
        },
        {
          'arabic': 'مِن شَرِّ مَا خَلَقَ',
          'transliteration': 'Min şerri mâ halak',
          'meaning': 'Yarattıklarının şerrinden',
          'verseNumber': 2,
        },
        {
          'arabic': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          'transliteration': 'Ve min şerri ğâsıkın izâ vekab',
          'meaning': 'Karanlık çökünce karanlığın şerrinden',
          'verseNumber': 3,
        },
        {
          'arabic': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          'transliteration': 'Ve min şerrin-neffâsâti fil-ukad',
          'meaning': 'Düğümlere üfleyenlerin şerrinden',
          'verseNumber': 4,
        },
        {
          'arabic': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          'transliteration': 'Ve min şerri hâsidin izâ hased',
          'meaning': 'Haset ettiğinde hasedin şerrinden',
          'verseNumber': 5,
        },
      ],
    },
    {
      'number': 114,
      'name': 'Nas',
      'nameArabic': 'الناس',
      'verseCount': 6,
      'revelationPlace': 'Mekke',
      'verses': [
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          'transliteration': 'Kul eûzü bi rabbin-nâs',
          'meaning': 'De ki: İnsanların Rabbi\'ne sığınırım',
          'verseNumber': 1,
        },
        {
          'arabic': 'مَلِكِ النَّاسِ',
          'transliteration': 'Melikin-nâs',
          'meaning': 'İnsanların hakimi',
          'verseNumber': 2,
        },
        {
          'arabic': 'إِلَٰهِ النَّاسِ',
          'transliteration': 'İlâhin-nâs',
          'meaning': 'İnsanların ilahı',
          'verseNumber': 3,
        },
        {
          'arabic': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          'transliteration': 'Min şerril-vesvâsil-hannâs',
          'meaning': 'Gizlenip duran vesvesecinin şerrinden',
          'verseNumber': 4,
        },
        {
          'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          'transliteration': 'Ellezî yüvesvisü fî sudûrin-nâs',
          'meaning': 'İnsanların göğüslerine vesvese veren',
          'verseNumber': 5,
        },
        {
          'arabic': 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          'transliteration': 'Minel-cinneti ven-nâs',
          'meaning': 'Cinlerden ve insanlardan',
          'verseNumber': 6,
        },
      ],
    },
  ];

  /// Get surah by number
  static Map<String, dynamic>? getSurahByNumber(int number) {
    try {
      return surahs.firstWhere((surah) => surah['number'] == number);
    } catch (e) {
      return null;
    }
  }

  /// Get surah by name
  static Map<String, dynamic>? getSurahByName(String name) {
    try {
      return surahs.firstWhere(
        (surah) => surah['name'].toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all surahs
  static List<Map<String, dynamic>> getAllSurahs() {
    return surahs;
  }
}
