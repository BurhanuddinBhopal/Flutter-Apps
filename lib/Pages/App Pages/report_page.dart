// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import '../../language/language_constant.dart';

class ReportPage extends StatefulWidget {
  final Function(String)? onYearSelected;

  const ReportPage({super.key, this.onYearSelected});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  var transactionDetails = {};
  var todayRaised;
  var todayCollected;
  var monthlyRaised;
  var monthlyCollected;
  var yearlyRaised;
  var yearlyCollected;
  bool isLoading = false;
  String? countryCode;
  bool _isConnected = false;
  String selectedYear = 'Select Year';

  List<String> months = [];
  List<int> values = [];

  // List<String> months = [
  //   "Jan",
  //   "Feb",
  //   "Mar",
  //   "Apr",
  //   "May",
  //   "Jun",
  //   "Jul",
  //   "Aug",
  //   "Sep",
  //   "Oct",
  //   "Nov",
  //   "Dec"
  // ];
  // List<int> values = [
  //   50,
  //   100,
  //   150,
  //   200,
  //   250,
  //   300,
  //   350,
  //   400,
  //   450,
  //   500,
  //   550,
  //   600
  // ];

  List<String> years = [];
  List<double> yearlyValues = [];
  String currentYear = DateTime.now().year.toString();

  var token;

  @override
  void initState() {
    customerData();
    _getCountryCode();
    _checkConnectivity();
    customersMonthlyTransactionData();
    customersYearlyTransactionData();
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 5; i++) {
      years.add((currentYear - i).toString());
    }

    super.initState();
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
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
    });
  }

  Future<void> customerData() async {
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
      transactionDetails = responseData['report'];
      monthlyRaised = responseData['report']['thisMonth']['billRaised'];
      monthlyCollected = responseData['report']['thisMonth']['amountCollected'];
      todayRaised = responseData['report']['today']['billRaised'];
      todayCollected = responseData['report']['today']['amountCollected'];
      yearlyRaised = responseData['report']['thisYear']['billRaised'];
      yearlyCollected = responseData['report']['thisYear']['amountCollected'];
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> customersYearlyTransactionData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
      '${AppConstants.backendUrl}/api/report/getYearlyReport',
    );

    final body = {
      "customerId": "all",
    };

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

      // Update the state with the response data
      setState(() {
        updateYearlyData(responseData);
      });
    } else {
      print('Failed to send customer IDs: ${response.statusCode}');
    }
  }

  void updateYearlyData(Map<String, dynamic> responseData) {
    if (responseData['years'] != null && responseData['amounts'] != null) {
      // Convert years to a list of strings
      years = List<String>.from(
          responseData['years'].map((year) => year.toString()));

      // Convert amounts to a list of doubles, handling int to double conversion
      yearlyValues = List<double>.from(
        responseData['amounts']
            .map((amount) => (amount is int) ? amount.toDouble() : amount),
      );

      // Print years and yearlyValues before setting state

      setState(() {
        // Update the state with the converted values
      });
    } else {
      // If the data is null or empty, reset the values
      years = [];
      yearlyValues = [];
      print('No data available');
      setState(() {
        years = [];
        yearlyValues = [];
      });
    }
  }

  Future<void> customersMonthlyTransactionData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    final url = Uri.parse(
      '${AppConstants.backendUrl}/api/report/getMonthlyReportPerYear',
    );

    final body = {
      "customerId": "all",
      "year": currentYear,
    };

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
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      List<String> responseMonths = List<String>.from(responseData['months']);
      List<int> responseAmounts = List<int>.from(
          responseData['amounts'].map((amount) => amount.toInt()));

      setState(() {
        months = responseMonths.map((month) => month.substring(0, 3)).toList();
        values = responseAmounts;
      });
      print('response: ${response.body}');
    } else {
      print('Failed to send customer IDs: ${response.statusCode}');
    }
  }

  Future<void> _refresh() async {
    customerData();
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translation(context)!.confirmExit,
                style: const TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text(translation(context)!.sureExit),
            actions: <Widget>[
              TextButton(
                child: Text(translation(context)!.yes,
                    style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              TextButton(
                child: Text(translation(context)!.no,
                    style: TextStyle(fontSize: 18.0)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }) as bool;
    return exitApp;
  }

  String formatNumber(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(0)}L';
    } else if (value >= 9999) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        centerTitle: true,
        title: Text(
          translation(context)!.welcometoHTA,
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(62, 13, 59, 1),
              ),
            )
          : RefreshIndicator(
              color: Color.fromRGBO(62, 13, 59, 1),
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: WillPopScope(
                  onWillPop: () => _onBackButtonPressed(context),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(6),
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Card(
                          color: Color.fromRGBO(62, 13, 59, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  translation(context)!
                                      .remainingAmountFromCustomers,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      countryCode == 'KW'
                                          ? Container(
                                              width: 25,
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              child: ColorFiltered(
                                                colorFilter:
                                                    const ColorFilter.mode(
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
                                              size: 21,
                                              color: Color.fromRGBO(
                                                  243, 31, 31, 1),
                                            ),
                                      Text(
                                        transactionDetails[
                                                'remainingFromCustomer'] ??
                                            '',
                                        style: const TextStyle(
                                          color: Color.fromRGBO(243, 31, 31, 1),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 5),
                          width: MediaQuery.of(context).size.width * 1,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Center(
                            child: Text(
                              translation(context)!.thisMonth,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 9),
                        height: MediaQuery.of(context).size.height * 0.065,
                        color: Color.fromRGBO(62, 13, 59, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: const EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
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
                                Text(
                                  monthlyRaised ?? '',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(243, 31, 31, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: const EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color.fromRGBO(52, 135, 89,
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
                                        color: Color.fromRGBO(52, 135, 89, 1),
                                      ),
                                Text(
                                  monthlyCollected ?? '',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(52, 135, 89, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      Container(
                          margin: EdgeInsets.only(top: 20, bottom: 5),
                          width: MediaQuery.of(context).size.width * 1,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Center(
                            child: Text(
                              translation(context)!.thisYear,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 9),
                        height: MediaQuery.of(context).size.height * 0.065,
                        color: Color.fromRGBO(62, 13, 59, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: const EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
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
                                Text(
                                  yearlyRaised ?? '',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(243, 31, 31, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 22,
                                        margin: const EdgeInsets.only(right: 5),
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color.fromRGBO(52, 135, 89,
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
                                        color: Color.fromRGBO(52, 135, 89, 1),
                                      ),
                                Text(
                                  yearlyCollected ?? '',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(52, 135, 89, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        width: MediaQuery.of(context).size.width * 1,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PopupMenuButton<String>(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Text(
                                        currentYear,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            5), // Adds some space between text and the icon
                                    const Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                              onSelected: (String selectedYear) {
                                setState(() {
                                  this.selectedYear = selectedYear;
                                  currentYear = selectedYear;
                                });
                                customersMonthlyTransactionData();
                              },
                              itemBuilder: (BuildContext context) {
                                return List.generate(4, (index) {
                                  String year =
                                      (DateTime.now().year - index).toString();
                                  return PopupMenuItem(
                                    value: year,
                                    child: Text(year),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 300,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: values.isNotEmpty
                                  ? values
                                          .reduce((a, b) => a > b ? a : b)
                                          .toDouble() *
                                      1.1
                                  : 0.0,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final style = const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      );
                                      return Text(
                                        months.isNotEmpty
                                            ? months[value.toInt()]
                                            : '',
                                        style: style,
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final style = const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      );
                                      return Text(formatNumber(value),
                                          style: style);
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false, // Hides the top titles
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false, // Hides the right titles
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  top: BorderSide.none, // Hides the top border
                                  right:
                                      BorderSide.none, // Hides the right border
                                ),
                              ),
                              barGroups: months.isNotEmpty && values.isNotEmpty
                                  ? List.generate(
                                      values.length,
                                      (index) => BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: values[index].toDouble(),
                                            color: const Color.fromRGBO(
                                                62, 13, 59, 1),
                                            width: 15,
                                            borderRadius: BorderRadius
                                                .zero, // Square corners
                                          ),
                                        ],
                                      ),
                                    )
                                  : [],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width * 1,
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: Text(
                            translation(context)!.yearlyGraph,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 300,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: yearlyValues.isNotEmpty
                                  ? yearlyValues
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble()
                                  : 0,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final style = const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      );
                                      return Text(
                                        years.isNotEmpty &&
                                                value.toInt() < years.length
                                            ? years[value.toInt()]
                                            : '',
                                        style: style,
                                      );
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final style = const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      );
                                      return Text(formatNumber(value),
                                          style: style);
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false, // Hides the top titles
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false, // Hides the right titles
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  top: BorderSide.none, // Hides the top border
                                  right:
                                      BorderSide.none, // Hides the right border
                                ),
                              ),
                              barGroups: List.generate(
                                yearlyValues.length,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: yearlyValues[index].toDouble(),
                                      color:
                                          const Color.fromRGBO(62, 13, 59, 1),
                                      width: 15,
                                      borderRadius:
                                          BorderRadius.zero, // Square corners
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Container(
                      //   margin: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      //   height: MediaQuery.of(context).size.height * 0.17,
                      //   child: Card(
                      //     color: Color.fromRGBO(62, 13, 59, 1),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(0),
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Padding(
                      //                 padding: EdgeInsets.symmetric(vertical: 15),
                      //                 child: Text(
                      //                   'Supplier Summary',
                      //                   style: TextStyle(
                      //                       color: Colors.white, fontSize: 20),
                      //                 ),
                      //               )
                      //             ]),
                      //         Padding(
                      //           padding: EdgeInsets.symmetric(vertical: 10),
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //             children: [
                      //               Column(
                      //                 children: [
                      //                   Text(
                      //                     'Bill Recieved',
                      //                     style: TextStyle(
                      //                       color: Colors.white,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 10),
                      //                     child: Text(
                      //                       '0.0',
                      //                       style: TextStyle(
                      //                         color: Color.fromRGBO(243, 31, 31, 1),
                      //                         fontWeight: FontWeight.bold,
                      //                         fontSize: 20,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               Column(
                      //                 children: [
                      //                   Text(
                      //                     'Payment Given',
                      //                     style: TextStyle(
                      //                       color: Colors.white,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 10),
                      //                     child: Text(
                      //                       '0.0',
                      //                       style: TextStyle(
                      //                         color: Color.fromRGBO(243, 31, 31, 1),
                      //                         fontWeight: FontWeight.bold,
                      //                         fontSize: 20,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(62, 13, 59, 1),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: const Size(350, 50),
                          ),
                          onPressed: () {
                            _refresh();
                          },
                          child: Text(translation(context)!.refresh),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
