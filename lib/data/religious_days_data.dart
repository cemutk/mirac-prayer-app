/// Religious Days Data Model for 2025-2030
/// Includes all major Islamic calendar events with DateTime objects for smart filtering
class ReligiousDayData {
  final DateTime date;
  final String hijriDate;
  final String name;
  final String description;
  final String practices;
  final int year;

  ReligiousDayData({
    required this.date,
    required this.hijriDate,
    required this.name,
    required this.description,
    required this.practices,
    required this.year,
  });
}

/// Comprehensive religious days list for 2025-2030
/// Source: Islamic calendar calculations and official announcements
final List<ReligiousDayData> religiousDaysList = [
  // ==================== 2025 ====================
  ReligiousDayData(
    date: DateTime(2025, 6, 27),
    hijriDate: '1 Muharrem 1447',
    name: 'Hicri Yılbaşı 1447',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 7, 6),
    hijriDate: '10 Muharrem 1447',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 9, 5),
    hijriDate: '12 Rebiülevvel 1447',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 1, 13),
    hijriDate: '27 Recep 1446',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 2, 2),
    hijriDate: '27 Recep 1446',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 2, 12),
    hijriDate: '15 Şaban 1446',
    name: 'Berat Kandili',
    description: 'Bağışlanma ve kurtuluş gecesi',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 3, 1),
    hijriDate: '1 Ramazan 1446',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 3, 27),
    hijriDate: '27 Ramazan 1446',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 3, 30),
    hijriDate: '1 Şevval 1446',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 6, 5),
    hijriDate: '9 Zilhicce 1446',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2025,
  ),
  ReligiousDayData(
    date: DateTime(2025, 6, 6),
    hijriDate: '10 Zilhicce 1446',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2025,
  ),

  // ==================== 2026 ====================
  ReligiousDayData(
    date: DateTime(2026, 6, 16),
    hijriDate: '1 Muharrem 1448',
    name: 'Hicri Yılbaşı 1448',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 6, 25),
    hijriDate: '10 Muharrem 1448',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 8, 25),
    hijriDate: '12 Rebiülevvel 1448',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 1, 2),
    hijriDate: '27 Recep 1447',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 1, 22),
    hijriDate: '27 Recep 1447',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 2, 1),
    hijriDate: '15 Şaban 1447',
    name: 'Berat Kandili',
    description: 'Bağışlanma ve kurtuluş gecesi',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 2, 18),
    hijriDate: '1 Ramazan 1447',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 3, 16),
    hijriDate: '27 Ramazan 1447',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 3, 20),
    hijriDate: '1 Şevval 1447',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 5, 26),
    hijriDate: '9 Zilhicce 1447',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2026,
  ),
  ReligiousDayData(
    date: DateTime(2026, 5, 27),
    hijriDate: '10 Zilhicce 1447',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2026,
  ),

  // ==================== 2027 ====================
  ReligiousDayData(
    date: DateTime(2027, 6, 6),
    hijriDate: '1 Muharrem 1449',
    name: 'Hicri Yılbaşı 1449',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 6, 15),
    hijriDate: '10 Muharrem 1449',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 8, 14),
    hijriDate: '12 Rebiülevvel 1449',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 12, 23),
    hijriDate: '27 Recep 1448',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 1, 12),
    hijriDate: '27 Recep 1448',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 1, 22),
    hijriDate: '15 Şaban 1448',
    name: 'Berat Kandili',
    description: 'Bağışlanma ve kurtuluş gecesi',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 2, 8),
    hijriDate: '1 Ramazan 1448',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 3, 6),
    hijriDate: '27 Ramazan 1448',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 3, 10),
    hijriDate: '1 Şevval 1448',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 5, 16),
    hijriDate: '9 Zilhicce 1448',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2027,
  ),
  ReligiousDayData(
    date: DateTime(2027, 5, 17),
    hijriDate: '10 Zilhicce 1448',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2027,
  ),

  // ==================== 2028 ====================
  ReligiousDayData(
    date: DateTime(2028, 5, 26),
    hijriDate: '1 Muharrem 1450',
    name: 'Hicri Yılbaşı 1450',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 6, 4),
    hijriDate: '10 Muharrem 1450',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 8, 3),
    hijriDate: '12 Rebiülevvel 1450',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 12, 12),
    hijriDate: '27 Recep 1449',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 1, 1),
    hijriDate: '27 Recep 1449',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 1, 11),
    hijriDate: '15 Şaban 1449',
    name: 'Berat Kandili',
    description: 'Bağışlanma ve kurtuluş gecesi',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 1, 28),
    hijriDate: '1 Ramazan 1449',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 2, 23),
    hijriDate: '27 Ramazan 1449',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 2, 27),
    hijriDate: '1 Şevval 1449',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 5, 4),
    hijriDate: '9 Zilhicce 1449',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2028,
  ),
  ReligiousDayData(
    date: DateTime(2028, 5, 5),
    hijriDate: '10 Zilhicce 1449',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2028,
  ),

  // ==================== 2029 ====================
  ReligiousDayData(
    date: DateTime(2029, 5, 15),
    hijriDate: '1 Muharrem 1451',
    name: 'Hicri Yılbaşı 1451',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 5, 24),
    hijriDate: '10 Muharrem 1451',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 7, 3),
    hijriDate: '20 Safer 1451',
    name: 'Erbain',
    description: 'Hz. Hüseyin\'in şehit edilişinin 40. günü',
    practices: 'Anma ve dua',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 7, 23),
    hijriDate: '12 Rebiülevvel 1451',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 12, 1),
    hijriDate: '27 Recep 1450',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 12, 21),
    hijriDate: '27 Recep 1450',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 1, 17),
    hijriDate: '1 Ramazan 1450',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 2, 12),
    hijriDate: '27 Ramazan 1450',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 2, 16),
    hijriDate: '1 Şevval 1450',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 4, 24),
    hijriDate: '9 Zilhicce 1450',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2029,
  ),
  ReligiousDayData(
    date: DateTime(2029, 4, 25),
    hijriDate: '10 Zilhicce 1450',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2029,
  ),

  // ==================== 2030 ====================
  ReligiousDayData(
    date: DateTime(2030, 5, 5),
    hijriDate: '1 Muharrem 1452',
    name: 'Hicri Yılbaşı 1452',
    description: 'İslam takviminin yeni yıl başlangıcı',
    practices: 'Dua ve ibadet',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 5, 14),
    hijriDate: '10 Muharrem 1452',
    name: 'Aşure Günü',
    description:
        'Hz. Nuh\'un gemisinin karaya oturduğu, Hz. Musa\'nın Firavun\'dan kurtulduğu gün',
    practices: 'Aşure pişirme, oruç tutma, sadaka verme',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 6, 23),
    hijriDate: '20 Safer 1452',
    name: 'Erbain',
    description: 'Hz. Hüseyin\'in şehit edilişinin 40. günü',
    practices: 'Anma ve dua',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 7, 13),
    hijriDate: '12 Rebiülevvel 1452',
    name: 'Mevlid Kandili',
    description: 'Peygamber Efendimiz Hz. Muhammed\'in doğum günü',
    practices: 'Mevlit okuma, dua, ibadet',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 11, 20),
    hijriDate: '27 Recep 1451',
    name: 'Regaip Kandili',
    description: 'Peygamberimizin anne ve babasının evlendiği gece',
    practices: 'Gece ibadeti, dua, sadaka',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 12, 10),
    hijriDate: '27 Recep 1451',
    name: 'Miraç Kandili',
    description:
        'Peygamber Efendimiz Hz. Muhammed\'in Miraca yükseldiği mübarek gece',
    practices: 'Gece ibadeti, Kuran okuma, dua, sadaka',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 12, 20),
    hijriDate: '15 Şaban 1451',
    name: 'Berat Kandili',
    description: 'Bağışlanma ve kurtuluş gecesi',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 1, 6),
    hijriDate: '1 Ramazan 1451',
    name: 'Ramazan Başlangıcı',
    description: 'Mübarek Ramazan ayının ilk günü',
    practices: 'Oruç tutma, teravih namazı',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 2, 1),
    hijriDate: '27 Ramazan 1451',
    name: 'Kadir Gecesi',
    description:
        'Kuran-ı Kerim\'in indirilmeye başlandığı gece, bin aydan hayırlı gece',
    practices: 'Gece ibadeti, Kuran okuma, dua',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 2, 5),
    hijriDate: '1 Şevval 1451',
    name: 'Ramazan Bayramı',
    description: 'Ramazan orucunun tamamlanması nedeniyle kutlanan bayram',
    practices: 'Bayram namazı, ziyaret, sadaka',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 4, 13),
    hijriDate: '9 Zilhicce 1451',
    name: 'Arefe Günü',
    description: 'Hacıların Arafat\'ta vakfe yaptığı gün',
    practices: 'Oruç tutma, dua',
    year: 2030,
  ),
  ReligiousDayData(
    date: DateTime(2030, 4, 14),
    hijriDate: '10 Zilhicce 1451',
    name: 'Kurban Bayramı',
    description:
        'Hz. İbrahim\'in Allah\'a olan teslimiyetinin anısına kutlanan bayram',
    practices: 'Kurban kesme, bayram namazı, ziyaret',
    year: 2030,
  ),
];
