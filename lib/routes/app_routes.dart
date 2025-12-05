import 'package:flutter/material.dart';

import '../presentation/abdest_guide_screen/abdest_guide_screen.dart';
import '../presentation/city_selection_screen/city_selection_screen.dart';
import '../presentation/digital_tasbih_counter_screen/digital_tasbih_counter_screen.dart';
import '../presentation/dua_screen/dua_screen.dart';
import '../presentation/esmaul_husna_screen/esmaul_husna_screen.dart';
import '../presentation/hadith_screen/hadith_screen.dart';
import '../presentation/home_screen_prayer_times/home_screen_prayer_times.dart';
import '../presentation/mosque_finder_screen/mosque_finder_screen.dart';
import '../presentation/namaz_mechanics_screen/namaz_mechanics_screen.dart';
import '../presentation/prayer_collection_screen/prayer_collection_screen.dart';
import '../presentation/prayer_tracking_screen/prayer_tracking_screen.dart';
import '../presentation/qibla_direction_screen/qibla_direction_screen.dart';
import '../presentation/quran_i_kerim_screen/quran_i_kerim_screen.dart';
import '../presentation/quiz_screen/quiz_screen.dart';
import '../presentation/religious_days_screen/religious_days_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/travel_mode_screen/travel_mode_screen.dart';
import '../presentation/kids_mode_screen/kids_mode_screen.dart';
import '../presentation/do_not_disturb_screen/do_not_disturb_screen.dart';
import '../presentation/halal_checker_screen/halal_checker_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String homeScreenPrayerTimes = '/home-screen-prayer-times';
  static const String citySelectionScreen = '/city-selection-screen';
  static const String qiblaDirectionScreen = '/qibla-direction-screen';
  static const String digitalTasbihCounterScreen =
      '/digital-tasbih-counter-screen';
  static const String duaScreen = '/dua-screen';
  static const String esmaulHusnaScreen = '/esmaul-husna-screen';
  static const String hadithScreen = '/hadith-screen';
  static const String mosqueFinderScreen = '/mosque-finder-screen';
  static const String prayerCollectionScreen = '/prayer-collection-screen';
  static const String prayerTrackingScreen = '/prayer-tracking-screen';
  static const String quizScreen = '/quiz-screen';
  static const String quranIKerimScreen = '/quran-i-kerim-screen';
  static const String settingsScreen = '/settings-screen';
  static const String religiousDaysScreen = '/religious-days-screen';
  static const String abdestGuideScreen = '/abdest-guide-screen';
  static const String namazMechanicsScreen = '/namaz-mechanics-screen';
  static const String travelModeScreen = '/travel-mode-screen';
  static const String kidsModeScreen = '/kids-mode-screen';
  static const String doNotDisturbScreen = '/do-not-disturb-screen';
  static const String halalCheckerScreen = '/halal-checker-screen';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SplashScreen(),
        splashScreen: (context) => const SplashScreen(),
        homeScreenPrayerTimes: (context) => const HomeScreenPrayerTimes(),
        citySelectionScreen: (context) => const CitySelectionScreen(),
        qiblaDirectionScreen: (context) => const QiblaDirectionScreen(),
        digitalTasbihCounterScreen: (context) =>
            const DigitalTasbihCounterScreen(),
        duaScreen: (context) => const DuaScreen(),
        esmaulHusnaScreen: (context) => const EsmaulHusnaScreen(),
        hadithScreen: (context) => const HadithScreen(),
        mosqueFinderScreen: (context) => const MosqueFinderScreen(),
        prayerCollectionScreen: (context) => const PrayerCollectionScreen(),
        prayerTrackingScreen: (context) => const PrayerTrackingScreen(),
        quizScreen: (context) => const QuizScreen(),
        quranIKerimScreen: (context) => const QuranIKerimScreen(),
        settingsScreen: (context) => const SettingsScreen(),
        religiousDaysScreen: (context) => const ReligiousDaysScreen(),
        abdestGuideScreen: (context) => const AbdestGuideScreen(),
        namazMechanicsScreen: (context) => const NamazMechanicsScreen(),
        travelModeScreen: (context) => const TravelModeScreen(),
        kidsModeScreen: (context) => const KidsModeScreen(),
        doNotDisturbScreen: (context) => const DoNotDisturbScreen(),
        halalCheckerScreen: (context) => const HalalCheckerScreen(),
      };
}
