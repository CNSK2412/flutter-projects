import 'package:flutter/material.dart';
import 'package:e_libraray_1/HomeScreen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

const customBlackColor = Color.fromARGB(255, 53, 53, 53);
const customWhiteColor = Color.fromARGB(255, 237, 237, 237);

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
      theme: ThemeData(
        // scaffoldBackgroundColor: customWhiteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: customWhiteColor,
          iconTheme: IconThemeData(color: customBlackColor),
          titleTextStyle: TextStyle(color: customBlackColor, fontSize: 20),
        ),
      ),
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
    Center(child: Text('Map Page')),
    Center(child: Text('Add Page')),
    Center(child: Text('Messages Page')),
    Center(child: Text('People Page')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.blue,
        style: TabStyle.reactCircle, // Style of the bottom navigation bar
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.map, title: 'Map'),
          TabItem(icon: Icons.add, title: 'Add'),
          TabItem(icon: Icons.message, title: 'Messages'),
          TabItem(icon: Icons.people, title: 'People'),
        ],
        initialActiveIndex: 0, // Default selected tab
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Change the selected tab
          });
        },
      ),
    );
  }
}
