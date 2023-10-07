import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:hta/Pages/App%20Pages/today_transaction_page.dart';

import '../../models/Transaction_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigationPage extends StatefulWidget {
  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  List<Widget> widgetList = [];
  int _selectedIndex = 0;
  bool isLoading = false;

  var transactionData1 = [];

  var customerData;
  List<dynamic>? transactionData;
  List<Transaction>? transactions;

  // var _fullCustomerData = [];

  @override
  void initState() {
    super.initState();
    widgetList = [TodayPage(), HomePage(), ReportPage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedWidget =
        widgetList.isNotEmpty ? widgetList[_selectedIndex] : HomePage();

    return Scaffold(
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.calendar,
                size: 20,
              ),
              label: 'Today'),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.user,
                size: 20,
              ),
              label: 'Customers'),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.rectangleList,
                size: 20,
              ),
              label: 'Report'),
        ],
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
