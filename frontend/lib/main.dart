import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'utils/theme_provider.dart';
import 'utils/routes.dart';
import 'widgets/theme_switcher.dart';
import 'services/compression_controller.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Load saved theme before building app so splash gets the right theme
  final preferences = await SharedPreferences.getInstance();
  final savedDark = preferences.getBool('theme_mode') ?? true; // default dark

  // Make system bars transparent
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: savedDark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: savedDark ? Brightness.light : Brightness.dark,
    ),
  );

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialDark: savedDark)),
        ChangeNotifierProvider(create: (_) => CompressionController()),
      ],
      child: const ThemeSwitcher(child: DeepFractApp()),
    ),
  );
}

class DeepFractApp extends StatelessWidget {
  const DeepFractApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DeepFract',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // Hide scrollbars globally
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: child!,
            );
          },
          // Disable default transition as we handle it manually
          themeAnimationDuration: Duration.zero,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
