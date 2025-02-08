import 'package:flutter/material.dart';
import 'package:e_libraray_1/HomeScreen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

const customBlackColor = Color.fromARGB(255, 53, 53, 53);
const customWhiteColor = Color.fromARGB(255, 255, 255, 255);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: customWhiteColor),
      home: Scaffold(
        body: BottomBar(),
      ),
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Center(child: HomeScreen()),
    Center(child: Text('Favorites Page')),
    Center(child: Text('Notification Page')),
    Center(child: Text('Profile Page')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: const Color.fromARGB(255, 2, 151, 156),
        style: TabStyle.titled,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.favorite_outline, title: 'Favorites'),
          TabItem(icon: Icons.notifications_outlined, title: 'Notifications'),
          TabItem(icon: Icons.account_circle_outlined, title: 'Profile'),
        ],
        initialActiveIndex: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
