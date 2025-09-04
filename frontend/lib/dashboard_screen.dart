import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardGrid(),
    Center(child: Text('SOS')),
    Center(child: Text('Profile')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7EBE1),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sos),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(6, (i) => _DashboardCard(index: i));
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: List.generate(cards.length, (int index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: cards[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final int index;
  const _DashboardCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.book,
      Icons.map,
      Icons.favorite,
      Icons.event,
      Icons.chat,
      Icons.settings,
    ];
    final titles = [
      'Guides',
      'Map',
      'Favorites',
      'Events',
      'Chat',
      'Settings',
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icons[index], size: 48, color: Colors.pinkAccent),
              const SizedBox(height: 12),
              Text(
                titles[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.pink[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}