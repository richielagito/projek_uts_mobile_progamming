import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/home_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/profile_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/search_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/searchprofile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, Object? userData});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  static List<Widget> listOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
    const SearchProfileScreen(
      username: '',
    ),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      // ignore: avoid_print
      print('Selected Index: $selectedIndex'); // Debugging
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: listOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: ' ',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: ' ',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: ' ',
              backgroundColor: Colors.black),
        ],
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false, // Tidak tampilkan label
        iconSize: 30,
        currentIndex: selectedIndex,
        selectedItemColor: Colors.white,
        onTap: onItemTapped,
      ),
    );
  }
}
