import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/Screens/Profil/profil_user.dart';
import 'package:mobile_presensi_kdtg/screens/screens.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List _screens = [
    HomeScreen(),
    StatsScreen(),
    ProfilUser(),
    Scaffold(),
    Scaffold(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 30.0,
        items:
            [Icons.home, Icons.history_outlined, Icons.account_circle_outlined]
                .asMap()
                .map((key, value) => MapEntry(
                      key,
                      BottomNavigationBarItem(
                        label: "",
                        icon: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: _currentIndex == key
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Icon(value),
                        ),
                      ),
                    ))
                .values
                .toList(),
      ),
    );
  }
}
