import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/adaptive_scaffold.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/dictionary_screen.dart';
import 'presentation/screens/practice/ai_writing_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Verb360App()));
}

class Verb360App extends StatelessWidget {
  const Verb360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '360 Động từ bất quy tắc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onNavigateToDictionary: () {
          setState(() => _currentIndex = 1);
        },
      ),
      const DictionaryScreen(),
      const AiWritingScreen(),
      const ProfileScreen(),
    ];

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Trang chủ',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Tra cứu 360',
      ),
      NavigationDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology_rounded),
        label: 'Gia sư AI',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Cá nhân',
      ),
    ];

    return AdaptiveScaffold(
      initialIndex: _currentIndex,
      pages: pages,
      destinations: destinations,
    );
  }
}
