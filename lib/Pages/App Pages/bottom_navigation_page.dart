import 'package:flutter/material.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:hta/Pages/App%20Pages/today_transaction_page.dart';

import '../../language/language_constant.dart';
import '../../models/Transaction_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  // List<Widget> widgetList = [];
  // int _selectedIndex = 0;
  // bool isLoading = false;

  // var transactionData1 = [];

  // var customerData;
  // List<dynamic>? transactionData;
  // List<Transaction>? transactions;

  // // var _fullCustomerData = [];

  // @override
  // void initState() {
  //   super.initState();
  //   widgetList = [HomePage(), TodayPage(), ReportPage()];
  // }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  int _currentIndex = 0;

  // Cache the pages to prevent reloading and maintain state
  final List<Widget> _pages = [
    HomePage(),
    TodayPage(),
    ReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const FaIcon(
              FontAwesomeIcons.rectangleList,
              size: 20,
            ),
            label: translation(context)!.customers,
          ),
          BottomNavigationBarItem(
              icon: const FaIcon(
                FontAwesomeIcons.user,
                size: 20,
              ),
              label: translation(context)!.today),
          BottomNavigationBarItem(
              icon: const FaIcon(
                FontAwesomeIcons.calendar,
                size: 20,
              ),
              label: translation(context)!.report),
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
      ),
    );
  }
}
