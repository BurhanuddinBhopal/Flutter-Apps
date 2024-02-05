import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/language/language_constant.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class CustomerReportPage extends StatefulWidget {
  final customerData;

  const CustomerReportPage({super.key, required this.customerData});
  @override
  State<CustomerReportPage> createState() => _CustomerReportPageState();
}

class _CustomerReportPageState extends State<CustomerReportPage> {
  var transactionDetails = {};
  var todayRaised;
  var todayCollected;
  var monthlyRaised;
  var monthlyCollected;
  var yearlyRaised;
  var yearlyCollected;
  var monthlyRaisedForChart;
  var monthlyCollectedForChart;
  var yearlyRaisedForChart;
  var yearlyCollectedForChart;
  bool isLoading = false;

  var _customerData = {};
  var _organizationName;

  Future<void> customerData() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/transactions/getOrganisationReportForOneCustomer');
    final body = {"customerId": _customerData['_id']};
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
      monthlyCollectedForChart = (responseData['report']['thisMonth']
              ['amountCollected']
          .replaceAll(',', ''));
      monthlyRaisedForChart = (responseData['report']['thisMonth']['billRaised']
          .replaceAll(',', ''));
      yearlyCollectedForChart = (responseData['report']['thisYear']
              ['amountCollected']
          .replaceAll(',', ''));
      yearlyRaisedForChart = (responseData['report']['thisYear']['billRaised']
          .replaceAll(',', ''));
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refresh() async {
    customerData();
    // You can do part here what you want to refresh
  }

  // Future<bool> _onBackButtonPressed(BuildContext context) async {
  //   bool exitApp = await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Confirm Exit?',
  //               style: new TextStyle(color: Colors.black, fontSize: 20.0)),
  //           content: Text('Are you sure you want to exit the app?'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text('Yes', style: new TextStyle(fontSize: 18.0)),
  //               onPressed: () {
  //                 SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //               },
  //             ),
  //             TextButton(
  //               child: Text('No', style: new TextStyle(fontSize: 18.0)),
  //               onPressed: () => Navigator.pop(context),
  //             )
  //           ],
  //         );
  //       }) as bool;
  //   return exitApp;
  // }

  @override
  void initState() {
    customerData();
    // TODO: implement initState
    setState(() {
      _customerData = widget.customerData;
      print(_customerData);
      _organizationName = _customerData['organisationName'];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          _organizationName,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(62, 13, 59, 1),
              ),
            )
          : RefreshIndicator(
              color: Color.fromRGBO(62, 13, 59, 1),
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(6),
                          height: MediaQuery.of(context).size.height * 0.138,
                          child: Card(
                            color: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                            translation(context).overview,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        )
                                      ]),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Column(
                                        //   children: [
                                        //     Text(
                                        //       'Due to supplier',
                                        //       style: TextStyle(
                                        //         color: Colors.white,
                                        //       ),
                                        //     ),
                                        //     Padding(
                                        //       padding: EdgeInsets.symmetric(vertical: 10),
                                        //       child: Text(
                                        //         '0.0',
                                        //         style: TextStyle(
                                        //           color: Color.fromRGBO(243, 31, 31, 1),
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 20,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        Column(
                                          children: [
                                            Text(
                                              translation(context)
                                                  .remainingAmountFromCustomers,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Text(
                                                transactionDetails[
                                                            'remainingFromCustomer'] !=
                                                        null
                                                    ? transactionDetails[
                                                        'remainingFromCustomer']
                                                    : '',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      243, 31, 31, 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
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
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Card(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          translation(context).todays,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.138,
                          child: Card(
                            color: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          translation(context).customerSummary,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      )
                                    ]),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            translation(context).billRaised,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                size: 16,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  todayRaised != null
                                                      ? todayRaised.toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            translation(context)
                                                .paymentCollected,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  todayCollected != null
                                                      ? todayCollected
                                                          .toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Card(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          translation(context).thisMonth,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.138,
                          child: Card(
                            color: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          translation(context).customerSummary,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      )
                                    ]),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            translation(context).billRaised,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  monthlyRaised != null
                                                      ? monthlyRaised.toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            translation(context)
                                                .paymentCollected,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  monthlyCollected != null
                                                      ? monthlyCollected
                                                          .toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Card(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          translation(context).thisYear,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.138,
                          child: Card(
                            color: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          translation(context).customerSummary,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      )
                                    ]),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            translation(context).billRaised,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  yearlyRaised != null
                                                      ? yearlyRaised.toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            translation(context)
                                                .paymentCollected,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee_sharp,
                                                color: Color.fromRGBO(
                                                    243, 31, 31, 1),
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  yearlyCollected != null
                                                      ? yearlyCollected
                                                          .toString()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        243, 31, 31, 1),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

                        // Container(
                        //   height: 300,
                        //   child: BarChart(
                        //     BarChartData(
                        //       titlesData: FlTitlesData(
                        //         leftTitles: SideTitles(
                        //           showTitles: true,

                        //           interval: 5, // Customize based on your data
                        //         ),
                        //         bottomTitles: SideTitles(
                        //           showTitles: true,
                        //           getTitles: (double value) {
                        //             // Customize your bottom titles based on the data
                        //             switch (value.toInt()) {
                        //               case 0:
                        //                 return 'Monthly';
                        //               case 1:
                        //                 return 'Yearly';
                        //               default:
                        //                 return '';
                        //             }
                        //           },
                        //         ),
                        //       ),
                        //       gridData: FlGridData(show: false),
                        //       borderData: FlBorderData(show: true),
                        //       barGroups: [
                        //         BarChartGroupData(
                        //           x: 0,
                        //           barsSpace: 4,
                        //           barRods: [
                        //             BarChartRodData(
                        //               y: double.tryParse(
                        //                       monthlyRaisedForChart) ??
                        //                   0.0,
                        //               colors: [Color.fromRGBO(186, 0, 0, 1)],
                        //             ),
                        //             BarChartRodData(
                        //               y: double.tryParse(
                        //                       monthlyCollectedForChart) ??
                        //                   0.0,
                        //               colors: [Color.fromRGBO(52, 135, 89, 1)],
                        //             ),
                        //           ],
                        //         ),
                        //         BarChartGroupData(
                        //           x: 1,
                        //           barsSpace: 4,
                        //           barRods: [
                        //             BarChartRodData(
                        //               y: double.tryParse(
                        //                       yearlyRaisedForChart) ??
                        //                   0.0,
                        //               colors: [Color.fromRGBO(186, 0, 0, 1)],
                        //             ),
                        //             BarChartRodData(
                        //               y: double.tryParse(
                        //                       yearlyCollectedForChart) ??
                        //                   0.0,
                        //               colors: [Color.fromRGBO(52, 135, 89, 1)],
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
