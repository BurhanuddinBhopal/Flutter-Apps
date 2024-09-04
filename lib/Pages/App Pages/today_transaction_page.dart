// ignore_for_file: unnecessary_brace_in_string_interps, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Pages/App%20Pages/home_page_detailed_card_info_page.dart';
import 'package:hta/google%20anaylitics/anaylitics_services.dart';

import 'package:hta/models/Usermodel.dart';

import 'package:hta/widgets/refresh.dart';

import 'package:intl/intl.dart';
import 'package:hta/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import 'home_page_card_info_page.dart';
import 'package:in_app_update/in_app_update.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage>
    with AutomaticKeepAliveClientMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  String finalNumber = '';
  bool isLoading = false;
  var customerData;
  var person;
  var organizationName;
  var dailyTransaction = [];
  var data = [];

  var pendingAmount;
  bool isPaymentCollected = false;

  var date;

  // List<Item> itemList = [];

  List<Item> filteredList = [];
  List<Item> allCutomerList = [];
  bool _isConnected = false;

  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = 'Today';

  var filteredCustomerData = []; // Initialize as an empty list

  var allCutomerData = [];
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  var todayRaised;
  var todayCollected;
  String? countryCode;
  Map<String, dynamic>? selectedCustomerData;
  List<dynamic> allCustomerData = [];

  @override
  void initState() {
    for (var node in _focusNodes) {
      node.addListener(() {});
      setState(() {});
    }

    super.initState();
    todayCustomerTransactionReport();

    checkForUpdate();
    _analyticsService.trackPage('TodayPage');
    fetchData();
    _checkConnectivity();
    fetchTodayTransactionData(DateTime.now());
    _getCountryCode();

    _searchController.text = _currentFilter;
  }

  void selectCustomer(dynamic customerData) {
    setState(() {
      selectedCustomerData = customerData;
    });
  }

  Future<bool> checkInternetConnection() async {
    try {
      // Try to make a request to a reliable URL
      final response = await http.get(Uri.parse('https://www.google.com'));

      // If the response status code is 200, the device is connected
      if (response.statusCode == 200) {
        return true; // Connected to the internet
      } else {
        return false; // Not connected to the internet
      }
    } catch (e) {
      // If an exception occurs, it means there's no internet connection
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    bool isConnected = await checkInternetConnection();
    setState(() {
      _isConnected = isConnected;
    });

    if (!_isConnected) {
      // Show a dialog or a message indicating no internet connection
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkForUpdate() async {
    try {
      // Returns an UpdateStatus object
      final AppUpdateInfo updateStatus = await InAppUpdate.checkForUpdate();

      if (updateStatus.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        // An update is available, prompt the user to install
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  Future<void> todayCustomerTransactionReport() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        '${AppConstants.backendUrl}/api/transactions/getOrganisationReportForAllCustomer');
    final body = {};
    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );
    final responseData = jsonDecode(response.body);
    setState(() {
      todayRaised = responseData['report']['today']['billRaised'];
      todayCollected = responseData['report']['today']['amountCollected'];
    });
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> fetchTodayTransactionData(DateTime date) async {
//   try {
//     final SharedPreferences sharedPreferences =
//         await SharedPreferences.getInstance();
//     var token = sharedPreferences.getString('token');

//     // Convert to local date and set times for midnight boundaries
//     DateTime todayMidnight = DateTime(date.year, date.month, date.day);
//     DateTime todayEnd = todayMidnight.add(Duration(days: 1));

//     // Convert to UTC format for the API call
//     String todayStartFormatted =
//         DateFormat("yyyy-MM-ddTHH:mm:ss.000Z").format(todayMidnight.toUtc());
//     String todayEndFormatted =
//         DateFormat("yyyy-MM-ddTHH:mm:ss.000Z").format(todayEnd.toUtc());

//     final url = Uri.parse(
//         '${AppConstants.backendUrl}/api/transactions/getDailyTransaction');

//     final body = {
//       'startDate': todayStartFormatted,
//       'endDate': todayEndFormatted,
//     };

//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };

//     final response = await http.post(
//       url,
//       headers: headers,
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);

//       dailyTransaction = responseData['dailyTransaction'];

//       // Sort the transactions by creation time in descending order
//       dailyTransaction.sort((a, b) => DateTime.parse(b["createdAt"])
//           .compareTo(DateTime.parse(a["createdAt"])));

//       setState(() {
//         _searchController.text = _currentFilter;
//       });
//     } else {
//       print('Response body: ${response.body}');
//     }
//   } catch (e) {
//     print('Error occurred: $e');
//   } finally {
//     setState(() {
//       // Update the UI with the fetched transactions
//     });
//   }
// }

  Future<void> fetchTodayTransactionData(DateTime date) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      String selectedDateTime =
          DateFormat("yyyy-MM-ddTHH:mm:ss.000Z").format(date.toUtc());
      final url = Uri.parse(
          '${AppConstants.backendUrl}/api/transactions/getDailyTransaction');
      final body = {'date': selectedDateTime};
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        dailyTransaction = responseData['dailyTransaction'];
        dailyTransaction.sort((a, b) => DateTime.parse(b["createdAt"])
            .compareTo(DateTime.parse(a["createdAt"])));
        setState(() {
          _searchController.text = _currentFilter;
        });
      } else {
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {});
      setState(() {
        // Update the UI with the fetched transactions
      });
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var token = sharedPreferences.getString('token');

    // ignore: unused_local_variable
    var lastName = sharedPreferences.getString('lastName');

    var organisation = sharedPreferences.getString('organisation');

    countryCode = sharedPreferences.getString('country') ?? 'IN';

    final url = Uri.parse(
        '${AppConstants.backendUrl}/api/customer/getAllCustomersForOrgainsationAdmin');

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
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> itemListJson = responseData['allCustomer'];

      setState(() {
        allCutomerList =
            itemListJson.map((itemJson) => Item.fromJson(itemJson)).toList();
        filteredList = allCutomerList;
        filteredCustomerData = responseData['allCustomer'];
        allCutomerData = responseData['allCustomer'];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _fetchToday() {
    fetchTodayTransactionData(DateTime.now());
  }

  void _fetchYesterday() {
    fetchTodayTransactionData(DateTime.now().subtract(Duration(days: 1)));
  }

  void filterItems(String query) {
    setState(() {
      filteredList = allCutomerList
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.lastName.toLowerCase().contains(query.toLowerCase()) ||
              item.organisationName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.mobileNumber.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Exit?',
                style: TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                child: Text('Yes', style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              TextButton(
                child: Text('No', style: TextStyle(fontSize: 18.0)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }) as bool;
    return exitApp;
  }

  int suggestionsCount = 12;
  final focus = FocusNode();

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
    });
  }

  Future<void> _refreshTransactions(String newFilter) async {
    setState(() {
      _currentFilter = newFilter;
      // Update the TextField with the new filter value
      _searchController.text = newFilter;
    });
    await todayCustomerTransactionReport();
    await fetchTodayTransactionData(DateTime.now());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        title: SizedBox(
          height: 38,
          child: Center(
            child: TextField(
              controller: _searchController,
              readOnly: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 80, 46, 78),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'Today') {
                _currentFilter = 'Today';
                _fetchToday();
              } else if (value == 'Yesterday') {
                _currentFilter = 'Yesterday';
                _fetchYesterday();
              } else if (value == 'Calendar') {
                // Calculate the day before yesterday
                final DateTime lastSelectableDate =
                    DateTime.now().subtract(Duration(days: 2));

                // Open a date picker and fetch transactions for the selected date
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: lastSelectableDate,
                  firstDate: DateTime(2000),
                  lastDate:
                      lastSelectableDate, // Restrict to dates before yesterday
                );

                if (selectedDate != null) {
                  _currentFilter =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  await fetchTodayTransactionData(selectedDate);
                }
              }

              setState(() {
                _searchController.text = _currentFilter;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Today',
                  child: Text('Today'),
                ),
                PopupMenuItem(
                  value: 'Yesterday',
                  child: Text('Yesterday'),
                ),
                PopupMenuItem(
                  value: 'Calendar',
                  child: Text('Select Date'),
                ),
              ];
            },
            icon: Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: isLoading
          ? Container(
              color: Color.fromRGBO(62, 13, 59,
                  1), // Set background color to match your app's theme
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors
                      .white, // Set the color of the loading indicator to white
                ),
              ),
            )
          : RefreshWidget(
              color: Color.fromRGBO(62, 13, 59, 1),
              onRefresh: () async {
                await _refreshTransactions('Today');
              },
              child: WillPopScope(
                onWillPop: () => _onBackButtonPressed(context),
                child: Container(
                  color: Color.fromRGBO(62, 13, 59, 1),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        width: MediaQuery.of(context).size.width * 1,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            Color.fromRGBO(243, 31, 31,
                                                1), // Darken the image
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                              'assets/images/kwd.png'),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.currency_rupee_sharp,
                                        size: 18,
                                        color: Color.fromRGBO(243, 31, 31, 1),
                                      ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    todayRaised ?? '',
                                    style: TextStyle(
                                      color: Color.fromRGBO(243, 31, 31, 1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            Color.fromRGBO(52, 135, 89,
                                                1), // Darken the image
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                              'assets/images/kwd.png'),
                                        ),
                                      )
                                    : const Icon(Icons.currency_rupee_sharp,
                                        size: 18,
                                        color: Color.fromRGBO(52, 135, 89, 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    todayCollected ?? '',
                                    style: TextStyle(
                                      color: Color.fromRGBO(52, 135, 89, 1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          margin:
                              EdgeInsets.only(left: 100, right: 20, top: 10),
                          child: ListView.builder(
                            itemCount: dailyTransaction.length,
                            itemBuilder: (context, index) {
                              String customerName =
                                  dailyTransaction[index]["customer"]["name"];
                              String customerLastname = dailyTransaction[index]
                                  ["customer"]["lastName"];
                              String customerOrganizationName =
                                  dailyTransaction[index]["customer"]
                                      ["organisationName"];

                              return GestureDetector(
                                onTap: () {
                                  String customerId = dailyTransaction[index]
                                      ["customer"]["_id"];

                                  var customerData =
                                      filteredCustomerData.firstWhere(
                                    (customer) => customer['_id'] == customerId,
                                    orElse: () => null,
                                  );

                                  if (customerData != null) {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: DetailedInfoPage(
                                          customerOrganization:
                                              dailyTransaction[index],
                                          customerData: customerData,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print(
                                        "Customer not found for transaction.");
                                    // Handle the case where the customer was not found
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 3),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: dailyTransaction[index]
                                                ["orderStatus"] ==
                                            'PAYMENT-COLLECTED'
                                        ? Color.fromRGBO(52, 135, 89, 1)
                                        : Color.fromRGBO(186, 0, 0, 1),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                customerOrganizationName,
                                                style: TextStyle(
                                                  color: Colors
                                                      .white, // Adjust text color if needed
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    customerName,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white, // Adjust text color if needed
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      customerLastname,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // Adjust text color if needed
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 10,
                                                    left: 10,
                                                    bottom: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    dailyTransaction[index][
                                                                "orderStatus"] ==
                                                            'PAYMENT-COLLECTED'
                                                        ? Text(
                                                            'Paid Amount',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        : Text(
                                                            'Bill Amount',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Row(
                                                        children: [
                                                          countryCode == 'KW'
                                                              ? Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              5),
                                                                  width: 20,
                                                                  child:
                                                                      ColorFiltered(
                                                                    colorFilter:
                                                                        ColorFilter
                                                                            .mode(
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              1),
                                                                      BlendMode
                                                                          .srcIn,
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                            'assets/images/kwd.png'),
                                                                  ),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .currency_rupee_sharp,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          Container(
                                                            child: Text(
                                                              '${dailyTransaction[index]["amount"]}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 10,
                                                    right: 10,
                                                    top: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    dailyTransaction[index][
                                                                "orderStatus"] ==
                                                            'PAYMENT-COLLECTED'
                                                        ? Text(
                                                            'Paid on',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        : Text(
                                                            'Raised on',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 20),
                                                            child: Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              size: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 0),
                                                            child: Text(
                                                              DateFormat(
                                                                      'hh:mm a')
                                                                  .format(DateTime.parse(
                                                                      dailyTransaction[
                                                                              index]
                                                                          [
                                                                          "createdAt"])),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      drawer: AppDrawer(),
    );
  }
}
