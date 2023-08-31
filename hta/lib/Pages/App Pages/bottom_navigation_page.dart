import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:hta/Pages/App%20Pages/today_transaction_page.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/Transaction_model.dart';

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
  var _customerId;
  List<dynamic>? transactionData;
  List<Transaction>? transactions;

  // var _fullCustomerData = [];

  @override
  void initState() {
    super.initState();

    todayData();
  }

  Future<void> todayData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var token = sharedPreferences.getString('token');
    var organisation = sharedPreferences.getString('organisation');
    final DateTime today = DateTime.now();
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/customer/getAllCustomersForOrgainsationAdmin');

    final body = {"userType": "costomer", "organisation": organisation};
    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey("allCustomer") &&
          responseData["allCustomer"] is List) {
        final List<dynamic> allCustomers = responseData["allCustomer"];

        List<Customer> customerList = [];

        for (customerData in allCustomers) {
          _customerId = customerData["_id"];
          print('Fetching data for customer with ID: $_customerId');

          final String _organisationName = customerData["organisationName"];
          final String _name = customerData["name"];
          final String _lastName = customerData["lastName"];
          final String _location = customerData["location"];
          final String _mobileNumber = customerData['mobileNumber'];
          final int _pendingAmount = customerData['pendingAmount'];
          final DateTime _createdAt = DateTime.parse(customerData['createdAt']);

          List<Transaction> todayTransactions = [];

          // Fetch transactions for the current customer
          todayTransactions = (await fetchTransactionsForCustomer())!;
          print('Fetched transactions for customer with ID: $_customerId');

          try {
            // Filter transactions for today
            todayTransactions = todayTransactions
                .where((transaction) =>
                    transaction.date.year == today.year &&
                    transaction.date.month == today.month &&
                    transaction.date.day == today.day)
                .toList();
          } catch (error) {
            print('Error fetching customer details: $error');
          }

          if (todayTransactions.isNotEmpty) {
            print('Adding customer with ID $_customerId to the list');
            customerList.add(Customer(
              lastName: _lastName,
              name: _name,
              organisationName: _organisationName,
              transactions: todayTransactions,
              location: _location,
              mobileNumber: _mobileNumber,
              date: _createdAt,
              pendingAmount: _pendingAmount,
            ));
          }
        }

        print('Final customer list: $customerList');
        setState(() {
          widgetList = [
            HomePage(),
            TodayPage(
              customerData: customerList,
            ),
            ReportPage()
          ];
        });
      }
    }
  }

  Future<List<Transaction>?> fetchTransactionsForCustomer() async {
    if (_customerId == null) {
      print('Customer ID is null. Cannot fetch transactions.');
      return null; // or an empty list, depending on your use case
    }
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/transactions/getAllTransaction');
    final body = {"customer": _customerId};

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    final responseData = json.decode(response.body);

    if (responseData != null && responseData is Map) {
      if (responseData.containsKey('allTransaction') &&
          responseData['allTransaction'] is List) {
        transactionData = responseData['allTransaction'];

        transactions = transactionData!
            .map((data) {
              try {
                return Transaction.fromMap(data as Map<String, dynamic>);
              } catch (e) {
                print('Error processing data: $e');
                return null;
              }
            })
            .cast<Transaction>()
            .toList();

        return transactions;
      } else {
        print('No transaction data available.');
        return null;
      }
    } else {
      print('Invalid response data format.');
      return null;
    }
  }

  // Future<List<Transaction>?> fetchTransactionsForCustomer() async {
  //   final SharedPreferences sharedPreferences =
  //       await SharedPreferences.getInstance();
  //   var token = sharedPreferences.getString('token');
  //   final url = Uri.parse(
  //       'https://hta.hatimtechnologies.in/api/transactions/getAllTransaction');
  //   final body = {"customer": _customerId};

  //   final header = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //   final response = await http.post(
  //     url,
  //     headers: header,
  //     body: jsonEncode(body),
  //   );
  //   final responseData = json.decode(response.body);

  //   if (responseData != null && responseData is Map) {
  //     transactionData = responseData['allTransaction'];
  //     // print(responseData.containsKey('allTransaction'));
  //     // print("transactionData: $transactionData");

  //     if (transactionData != null) {
  //       transactions = transactionData!
  //           .map((data) {
  //             try {
  //               return Transaction.fromMap(data as Map<String, dynamic>);
  //             } catch (e) {
  //               print('Error processing data: $e');
  //               return null;
  //             }
  //           })
  //           .cast<Transaction>()
  //           .toList();

  //       return transactions;
  //     } else {
  //       print('No transaction data available.');
  //     }
  //   } else {
  //     print('Invalid response data format.');
  //   }

  //   return [];
  // }

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
              icon: Icon(Icons.note_add), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
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
