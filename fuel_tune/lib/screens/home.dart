import 'package:flutter/material.dart';
import 'home/mixture_page.dart';
import 'home/autonomy_page.dart';
import 'home/settings_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    MixturePage(),
    AutonomyPage(),
    SettingsPage(),
  ];

  final List<String> _pageTitles = [
    'Mistura',
    'Autonomia',
    'Configurações',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _pageTitles[_selectedIndex],
                style: const TextStyle(fontSize: 35, color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Mistura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Autonomia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
