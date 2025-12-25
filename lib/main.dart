import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Standard localizations
import 'package:google_fonts/google_fonts.dart';
import 'package:newsappman/core/storage/hive_service.dart';
import 'package:newsappman/features/news/presentation/providers/theme_provider.dart';
import 'package:newsappman/features/news/presentation/screens/news_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize timeago locales for Arabic and Turkish
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('tr', timeago.TrMessages());

  final container = ProviderContainer();
  final hiveService = container.read(hiveServiceProvider);
  await hiveService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar'), Locale('tr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    // Dynamic font family based on locale
    // Nunito supports Turkish special characters (İ, ı, Ş, ş, Ğ, ğ, Ü, ü, Ö, ö, Ç, ç)
    TextTheme textTheme;
    String? fontFamily;

    if (context.locale.languageCode == 'ar') {
      fontFamily = GoogleFonts.cairo().fontFamily;
      textTheme = GoogleFonts.cairoTextTheme();
    } else if (context.locale.languageCode == 'tr') {
      fontFamily = GoogleFonts.nunito().fontFamily;
      textTheme = GoogleFonts.nunitoTextTheme();
    } else {
      fontFamily = GoogleFonts.lato().fontFamily;
      textTheme = GoogleFonts.latoTextTheme();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: fontFamily,
        textTheme: textTheme,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF4A4A4A), // Charcoal gray - simple and elegant
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: fontFamily,
        textTheme: context.locale.languageCode == 'ar'
            ? GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme)
            : context.locale.languageCode == 'tr'
                ? GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme)
                : GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      themeMode: themeMode,
      home: const NewsScreen(),
    );
  }
}
