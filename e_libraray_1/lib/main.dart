import 'package:e_libraray_1/screens/FavoritePage.dart';
import 'package:e_libraray_1/screens/ProfilePage.dart';
import 'package:e_libraray_1/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:e_libraray_1/screens/HomeScreen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 2, 151, 156),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/favorites': (context) => FavoritePage(),
        '/profile': (context) => ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/bookDetails') {
          final book = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) => BookDetails(book: book),
          );
        }
        return null;
      },
      home: const BottomBar(),
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomeScreen(),
    FavoritePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        style: TabStyle.titled,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.favorite_outline, title: 'Favorites'),
          TabItem(icon: Icons.account_circle_outlined, title: 'Profile'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
