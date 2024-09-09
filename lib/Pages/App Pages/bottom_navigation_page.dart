import 'package:flutter/material.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:hta/Pages/App%20Pages/today_transaction_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../language/language_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  // Cache the pages to prevent reloading and maintain state
  final List<Widget> _pages = [
    HomePage(),
    TodayPage(),
    ReportPage(),
  ];

  Future<String> _getBottomNavLabel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedMode = prefs.getString('selectedMode') ?? 'Sales';
    return selectedMode == 'Purchase' ? 'Suppliers' : 'Customers';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FutureBuilder<String>(
        future: _getBottomNavLabel(),
        builder: (context, snapshot) {
          String label = 'Customers'; // Default to Customers
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            label = snapshot.data!;
          }

          return BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: const FaIcon(
                  FontAwesomeIcons.rectangleList,
                  size: 20,
                ),
                label: label,
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(
                  FontAwesomeIcons.user,
                  size: 20,
                ),
                label: translation(context)!.today,
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(
                  FontAwesomeIcons.calendar,
                  size: 20,
                ),
                label: translation(context)!.report,
              ),
            ],
            backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}
