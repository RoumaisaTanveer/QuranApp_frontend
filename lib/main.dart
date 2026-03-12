import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/journal_screen.dart';
import 'screens/history_screen.dart';
import 'screens/wellbeing_screen.dart';
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
        home: const SplashScreen(child: MainShell()),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;

  Widget _screen() {
    switch (_i) {
      case 0:
        return const JournalScreen();
      case 1:
        return const HistoryScreen(initialTab: 0); // History → Entries
      case 2:
        return const HistoryScreen(initialTab: 1); // Saved → Saved Ayahs
      case 3:
        return const WellbeingScreen();
      default:
        return const JournalScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(key: ValueKey(_i), child: _screen()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bg2,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _NavBtn(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  active: _i == 0,
                  onTap: () => setState(() => _i = 0),
                ),
                _NavBtn(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history_rounded,
                  label: 'History',
                  active: _i == 1,
                  onTap: () => setState(() => _i = 1),
                ),
                // Center orb
                GestureDetector(
                  onTap: () => setState(() => _i = 0),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.purple, Color(0xFF5B3CC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleGlow,
                          blurRadius: 18,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                _NavBtn(
                  icon: Icons.bookmark_outline_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'Saved',
                  active: _i == 2,
                  onTap: () => setState(() => _i = 2),
                ),
                _NavBtn(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Wellbeing',
                  active: _i == 3,
                  onTap: () => setState(() => _i = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 22,
                color: active
                    ? AppColors.purple
                    : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: active
                      ? AppColors.purple
                      : AppColors.textMuted,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
}
