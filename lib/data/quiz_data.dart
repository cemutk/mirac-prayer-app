/// Dini Bilgi Yarışması soru ve veri modelleri
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String? explanation;
  final DifficultyLevel difficulty;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    this.explanation,
    this.difficulty = DifficultyLevel.medium,
  });

  String get correctAnswer => options[correctAnswerIndex];
}

enum DifficultyLevel { easy, medium, hard }

/// Quiz kategorileri
const List<String> quizCategories = [
  'Tümü',
  'Kur\'an-ı Kerim',
  'Peygamberler',
  'Namaz',
  'Oruç ve Ramazan',
  'Hac ve Umre',
  'Siyer',
  'Fıkıh',
  'İslam Tarihi',
];

/// Quiz sonuç modeli
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration timeTaken;
  final String category;
  final DateTime date;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTaken,
    required this.category,
    required this.date,
  });

  double get successRate => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  int get score => correctAnswers * 10;
}

/// Tüm sorular
const List<QuizQuestion> allQuestions = [
  // KUR'AN-I KERİM
  QuizQuestion(
    id: 1,
    question: 'Kur\'an-ı Kerim\'de kaç sure vardır?',
    options: ['100', '114', '120', '124'],
    correctAnswerIndex: 1,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Kur\'an-ı Kerim 114 sureden oluşmaktadır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 2,
    question: 'Kur\'an-ı Kerim\'in en uzun suresi hangisidir?',
    options: ['Yasin', 'Bakara', 'Al-i İmran', 'Nisa'],
    correctAnswerIndex: 1,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Bakara Suresi 286 ayetle Kur\'an\'ın en uzun suresidir.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 3,
    question: 'Kur\'an-ı Kerim\'in en kısa suresi hangisidir?',
    options: ['Kevser', 'İhlas', 'Nasr', 'Fil'],
    correctAnswerIndex: 0,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Kevser Suresi 3 ayetle Kur\'an\'ın en kısa suresidir.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 4,
    question: 'Ayet-el Kürsi hangi surede yer alır?',
    options: ['Al-i İmran', 'Nisa', 'Bakara', 'Maide'],
    correctAnswerIndex: 2,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Ayet-el Kürsi, Bakara Suresi\'nin 255. ayetidir.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 5,
    question: 'Kur\'an-ı Kerim kaç cüzden oluşur?',
    options: ['20', '25', '30', '40'],
    correctAnswerIndex: 2,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Kur\'an-ı Kerim 30 cüzden oluşmaktadır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 6,
    question: '"Amenerrasulü" olarak bilinen ayetler hangi surenin sonundadır?',
    options: ['Bakara', 'Al-i İmran', 'Nisa', 'Maide'],
    correctAnswerIndex: 0,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Amenerrasulü, Bakara Suresi\'nin son iki ayetidir (285-286).',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 7,
    question: 'Kur\'an-ı Kerim\'de adı geçen tek kadın kimdir?',
    options: ['Hz. Hatice', 'Hz. Meryem', 'Hz. Asiye', 'Hz. Hacer'],
    correctAnswerIndex: 1,
    category: 'Kur\'an-ı Kerim',
    explanation: 'Hz. Meryem, Kur\'an\'da ismiyle anılan tek kadındır.',
    difficulty: DifficultyLevel.medium,
  ),

  // PEYGAMBERLER
  QuizQuestion(
    id: 8,
    question: 'İlk peygamber kimdir?',
    options: ['Hz. İbrahim', 'Hz. Nuh', 'Hz. Adem', 'Hz. İdris'],
    correctAnswerIndex: 2,
    category: 'Peygamberler',
    explanation: 'Hz. Adem hem ilk insan hem de ilk peygamberdir.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 9,
    question: 'Son peygamber kimdir?',
    options: ['Hz. İsa', 'Hz. Musa', 'Hz. Muhammed', 'Hz. İbrahim'],
    correctAnswerIndex: 2,
    category: 'Peygamberler',
    explanation: 'Hz. Muhammed (s.a.v) son peygamber ve Hatemü\'l-Enbiya\'dır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 10,
    question: 'Hangi peygambere Zebur indirilmiştir?',
    options: ['Hz. İsa', 'Hz. Davud', 'Hz. Musa', 'Hz. İbrahim'],
    correctAnswerIndex: 1,
    category: 'Peygamberler',
    explanation: 'Zebur, Hz. Davud\'a indirilen kutsal kitaptır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 11,
    question: 'Hz. Yunus hangi balık tarafından yutulmuştur?',
    options: ['Köpekbalığı', 'Balina', 'Büyük bir balık', 'Yunus'],
    correctAnswerIndex: 2,
    category: 'Peygamberler',
    explanation: 'Kur\'an\'da büyük bir balık olarak geçer.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 12,
    question: 'Kur\'an\'da ismi geçen peygamber sayısı kaçtır?',
    options: ['20', '25', '28', '33'],
    correctAnswerIndex: 1,
    category: 'Peygamberler',
    explanation: 'Kur\'an\'da 25 peygamberin ismi geçmektedir.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 13,
    question: 'Hz. Süleyman hangi hayvanlarla konuşabilirdi?',
    options: ['Sadece kuşlar', 'Sadece karıncalar', 'Tüm hayvanlar', 'Hiçbiri'],
    correctAnswerIndex: 2,
    category: 'Peygamberler',
    explanation: 'Hz. Süleyman\'a hayvanların dili öğretilmişti.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 14,
    question: 'Ulü\'l-Azm peygamberler kaç tanedir?',
    options: ['3', '4', '5', '7'],
    correctAnswerIndex: 2,
    category: 'Peygamberler',
    explanation: 'Hz. Nuh, Hz. İbrahim, Hz. Musa, Hz. İsa ve Hz. Muhammed.',
    difficulty: DifficultyLevel.medium,
  ),

  // NAMAZ
  QuizQuestion(
    id: 15,
    question: 'Günde kaç vakit namaz farzdır?',
    options: ['3', '4', '5', '6'],
    correctAnswerIndex: 2,
    category: 'Namaz',
    explanation: 'Sabah, öğle, ikindi, akşam ve yatsı olmak üzere 5 vakit namaz farzdır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 16,
    question: 'Sabah namazının farzı kaç rekattır?',
    options: ['2', '3', '4', '5'],
    correctAnswerIndex: 0,
    category: 'Namaz',
    explanation: 'Sabah namazının farzı 2 rekattır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 17,
    question: 'Namaz hangi Miraç gecesinde farz kılındı?',
    options: ['Regaib Kandili', 'Mevlid Kandili', 'Miraç Kandili', 'Berat Kandili'],
    correctAnswerIndex: 2,
    category: 'Namaz',
    explanation: 'Namaz, Miraç gecesinde farz kılınmıştır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 18,
    question: 'Cuma namazı kaç rekattır?',
    options: ['2', '4', '6', '8'],
    correctAnswerIndex: 0,
    category: 'Namaz',
    explanation: 'Cuma namazının farzı 2 rekattır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 19,
    question: 'Namazın şartlarından değildir?',
    options: ['Abdestli olmak', 'Kıbleye dönmek', 'Başı örtmek', 'Ayakta durmak'],
    correctAnswerIndex: 3,
    category: 'Namaz',
    explanation: 'Ayakta durmak namazın şartı değil, rüknüdür.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 20,
    question: 'Secdede hangi tesbih okunur?',
    options: ['Subhaneke', 'Sübhane Rabbiyel A\'la', 'Sübhane Rabbiyel Azim', 'Ettehiyyatü'],
    correctAnswerIndex: 1,
    category: 'Namaz',
    explanation: 'Secdede "Sübhane Rabbiyel A\'la" okunur.',
    difficulty: DifficultyLevel.medium,
  ),

  // ORUÇ VE RAMAZAN
  QuizQuestion(
    id: 21,
    question: 'Ramazan orucu hangi yılda farz kılındı?',
    options: ['Hicretin 1. yılı', 'Hicretin 2. yılı', 'Hicretin 3. yılı', 'Hicretin 4. yılı'],
    correctAnswerIndex: 1,
    category: 'Oruç ve Ramazan',
    explanation: 'Ramazan orucu Hicretin 2. yılında farz kılınmıştır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 22,
    question: 'Kadir Gecesi Ramazan\'ın hangi gününe denk gelir?',
    options: ['İlk 10 gün', 'Son 10 gün tek geceler', '15. gece', '20. gece'],
    correctAnswerIndex: 1,
    category: 'Oruç ve Ramazan',
    explanation: 'Kadir Gecesi Ramazan\'ın son 10 gününün tek gecelerinde aranır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 23,
    question: 'Orucu bozan hallerden biri değildir?',
    options: ['Yemek yemek', 'Su içmek', 'Unutarak yemek', 'Sigara içmek'],
    correctAnswerIndex: 2,
    category: 'Oruç ve Ramazan',
    explanation: 'Unutarak yemek-içmek orucu bozmaz.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 24,
    question: 'İftar vakti hangi namaz vaktidir?',
    options: ['İkindi', 'Akşam', 'Yatsı', 'Güneş batımı'],
    correctAnswerIndex: 1,
    category: 'Oruç ve Ramazan',
    explanation: 'Akşam namazı vakti girdiğinde oruç açılır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 25,
    question: 'Sahur için son vakit ne zamandır?',
    options: ['Yatsı namazı', 'Gece yarısı', 'İmsak vakti', 'Sabah namazı'],
    correctAnswerIndex: 2,
    category: 'Oruç ve Ramazan',
    explanation: 'Sahur imsak vaktine kadar yenebilir.',
    difficulty: DifficultyLevel.easy,
  ),

  // HAC VE UMRE
  QuizQuestion(
    id: 26,
    question: 'Hac ibadeti hangi ayda yapılır?',
    options: ['Muharrem', 'Şaban', 'Zilhicce', 'Recep'],
    correctAnswerIndex: 2,
    category: 'Hac ve Umre',
    explanation: 'Hac ibadeti Zilhicce ayında yapılır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 27,
    question: 'Arafat vakfesi hangi gün yapılır?',
    options: ['Zilhicce 9', 'Zilhicce 10', 'Zilhicce 8', 'Zilhicce 11'],
    correctAnswerIndex: 0,
    category: 'Hac ve Umre',
    explanation: 'Arafat vakfesi Zilhicce ayının 9. günü yapılır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 28,
    question: 'Kabe\'nin etrafında kaç kez tavaf edilir?',
    options: ['3', '5', '7', '9'],
    correctAnswerIndex: 2,
    category: 'Hac ve Umre',
    explanation: 'Tavaf 7 şavt (tur) olarak yapılır.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 29,
    question: 'Safa ile Merve arasında kaç kez sa\'y yapılır?',
    options: ['3', '5', '7', '9'],
    correctAnswerIndex: 2,
    category: 'Hac ve Umre',
    explanation: 'Sa\'y, Safa\'dan başlayıp Merve\'de biten 7 şavttan oluşur.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 30,
    question: 'Hacerü\'l-Esved\'in rengi nedir?',
    options: ['Beyaz', 'Siyah', 'Kırmızı', 'Yeşil'],
    correctAnswerIndex: 1,
    category: 'Hac ve Umre',
    explanation: 'Hacerü\'l-Esved siyah taş anlamına gelir.',
    difficulty: DifficultyLevel.easy,
  ),

  // SİYER
  QuizQuestion(
    id: 31,
    question: 'Hz. Muhammed (s.a.v) hangi yılda doğdu?',
    options: ['571', '570', '572', '569'],
    correctAnswerIndex: 0,
    category: 'Siyer',
    explanation: 'Peygamber Efendimiz 571 yılında (Fil Yılı) doğmuştur.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 32,
    question: 'Hz. Muhammed\'in ilk eşi kimdir?',
    options: ['Hz. Aişe', 'Hz. Hafsa', 'Hz. Hatice', 'Hz. Zeynep'],
    correctAnswerIndex: 2,
    category: 'Siyer',
    explanation: 'Hz. Hatice, Peygamber Efendimizin ilk eşidir.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 33,
    question: 'Hicret hangi yılda gerçekleşti?',
    options: ['620', '622', '624', '626'],
    correctAnswerIndex: 1,
    category: 'Siyer',
    explanation: 'Hicret 622 yılında Mekke\'den Medine\'ye yapılmıştır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 34,
    question: 'İlk inen ayet hangisidir?',
    options: ['Fatiha', 'İhlas', 'Alak Suresi ilk ayetler', 'Bakara'],
    correctAnswerIndex: 2,
    category: 'Siyer',
    explanation: 'İlk inen ayetler Alak Suresi\'nin ilk 5 ayetidir: "Oku!"',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 35,
    question: 'Peygamberimizin vefat yaşı kaçtır?',
    options: ['60', '63', '65', '70'],
    correctAnswerIndex: 1,
    category: 'Siyer',
    explanation: 'Hz. Muhammed (s.a.v) 63 yaşında vefat etmiştir.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 36,
    question: 'Bedir Savaşı hangi yılda olmuştur?',
    options: ['Hicri 1', 'Hicri 2', 'Hicri 3', 'Hicri 4'],
    correctAnswerIndex: 1,
    category: 'Siyer',
    explanation: 'Bedir Savaşı Hicri 2. yılda gerçekleşmiştir.',
    difficulty: DifficultyLevel.medium,
  ),

  // FIKIH
  QuizQuestion(
    id: 37,
    question: 'İslam\'ın şartları kaç tanedir?',
    options: ['4', '5', '6', '7'],
    correctAnswerIndex: 1,
    category: 'Fıkıh',
    explanation: 'Kelime-i şehadet, namaz, oruç, zekat ve hac.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 38,
    question: 'İmanın şartları kaç tanedir?',
    options: ['4', '5', '6', '7'],
    correctAnswerIndex: 2,
    category: 'Fıkıh',
    explanation: 'Allah\'a, meleklere, kitaplara, peygamberlere, ahirete ve kadere iman.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 39,
    question: 'Zekat nisabı ne demektir?',
    options: ['Zekat oranı', 'Zekat verme zamanı', 'Zekat verilecek minimum mal miktarı', 'Zekat alacak kişiler'],
    correctAnswerIndex: 2,
    category: 'Fıkıh',
    explanation: 'Nisab, zekat verilmesi için gerekli minimum mal miktarıdır.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 40,
    question: 'Abdesti bozan hallerden biri değildir?',
    options: ['Uyumak', 'Bayılmak', 'Konuşmak', 'Yellenmek'],
    correctAnswerIndex: 2,
    category: 'Fıkıh',
    explanation: 'Konuşmak abdesti bozmaz.',
    difficulty: DifficultyLevel.easy,
  ),

  // İSLAM TARİHİ
  QuizQuestion(
    id: 41,
    question: 'Dört Halife döneminin ilk halifesi kimdir?',
    options: ['Hz. Ömer', 'Hz. Osman', 'Hz. Ali', 'Hz. Ebu Bekir'],
    correctAnswerIndex: 3,
    category: 'İslam Tarihi',
    explanation: 'Hz. Ebu Bekir ilk halifedir.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 42,
    question: 'Kur\'an-ı Kerim hangi halife döneminde kitap haline getirildi?',
    options: ['Hz. Ebu Bekir', 'Hz. Ömer', 'Hz. Osman', 'Hz. Ali'],
    correctAnswerIndex: 0,
    category: 'İslam Tarihi',
    explanation: 'Kur\'an Hz. Ebu Bekir döneminde mushaf haline getirildi.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 43,
    question: 'Kur\'an-ı Kerim hangi halife döneminde çoğaltıldı?',
    options: ['Hz. Ebu Bekir', 'Hz. Ömer', 'Hz. Osman', 'Hz. Ali'],
    correctAnswerIndex: 2,
    category: 'İslam Tarihi',
    explanation: 'Kur\'an Hz. Osman döneminde çoğaltılarak dağıtıldı.',
    difficulty: DifficultyLevel.medium,
  ),
  QuizQuestion(
    id: 44,
    question: 'Adalet simgesi olarak bilinen halife kimdir?',
    options: ['Hz. Ebu Bekir', 'Hz. Ömer', 'Hz. Osman', 'Hz. Ali'],
    correctAnswerIndex: 1,
    category: 'İslam Tarihi',
    explanation: 'Hz. Ömer adaleti ile meşhurdur.',
    difficulty: DifficultyLevel.easy,
  ),
  QuizQuestion(
    id: 45,
    question: 'Osmanlı Devleti\'ni kim kurdu?',
    options: ['Osman Gazi', 'Orhan Gazi', 'Fatih Sultan Mehmed', 'Kanuni Sultan Süleyman'],
    correctAnswerIndex: 0,
    category: 'İslam Tarihi',
    explanation: 'Osmanlı Devleti 1299\'da Osman Gazi tarafından kuruldu.',
    difficulty: DifficultyLevel.easy,
  ),
];

/// Kategoriye göre soruları getir
List<QuizQuestion> getQuestionsByCategory(String category) {
  if (category == 'Tümü') {
    return allQuestions;
  }
  return allQuestions.where((q) => q.category == category).toList();
}

/// Rastgele sorular getir
List<QuizQuestion> getRandomQuestions(int count, {String? category}) {
  List<QuizQuestion> questions;
  if (category != null && category != 'Tümü') {
    questions = getQuestionsByCategory(category);
  } else {
    questions = List.from(allQuestions);
  }
  questions.shuffle();
  return questions.take(count).toList();
}

/// Zorluk seviyesine göre sorular
List<QuizQuestion> getQuestionsByDifficulty(DifficultyLevel difficulty) {
  return allQuestions.where((q) => q.difficulty == difficulty).toList();
}
