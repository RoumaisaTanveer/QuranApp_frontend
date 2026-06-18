import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
    ),
  );
  runApp(const QuranJournalApp());
}

class QuranJournalApp extends StatelessWidget {
  const QuranJournalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'مع القرآن',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        navigatorKey: AuthService.navigatorKey,
        home: const SplashScreen(),
      );
}
