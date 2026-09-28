import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/narcseal_theme.dart';
import 'core/theme/night_ops_theme.dart';
import 'core/theme/colors.dart';
import 'services/theme_service.dart';
import 'navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode and set system UI overlay style
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system status bar / nav bar to match the light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: NarcSealColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NarcSealApp());
}

/// Root widget for the NarcSeal forensic drug test evidence sealing app.
class NarcSealApp extends StatefulWidget {
  const NarcSealApp({super.key});

  @override
  State<NarcSealApp> createState() => _NarcSealAppState();
}

class _NarcSealAppState extends State<NarcSealApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NarcSeal',
      debugShowCheckedModeBanner: false,
      theme: NarcSealTheme.lightTheme(),
      darkTheme: NightOpsTheme.theme(),
      themeMode: _themeService.isNightOps ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
