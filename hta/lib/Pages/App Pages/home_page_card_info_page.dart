// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Pages/App%20Pages/card_info_page_raise_bill_button_page.dart';

import 'package:hta/widgets/refresh.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation_page.dart';
import 'card_info_page_pay_bill_button_page.dart';
import 'home_page_detailed_card_info_page.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class DetailedCardPage extends StatefulWidget {
  final dynamic customerData;

  const DetailedCardPage({required this.customerData});

  // factory DetailedCardPage.fromCustomer({required Customer customer, required customerData}) {
  //   return DetailedCardPage(customerData: customer);
  // }
  @override
  State<DetailedCardPage> createState() => _DetailedCardPageState();
}

class _DetailedCardPageState extends State<DetailedCardPage> {
  var _customerData = {};
  var transactionData1 = [];
  var pendingAmount;

//pendingAmount
  bool isLoading = false;
  var mobileNumber;

  @override
  void initState() {
    transactionData();
    customerData();
    setState(() {
      _customerData = widget.customerData;
      print('data after recieved: $widget.$_customerData');

      mobileNumber = _customerData["mobileNumber"];
    });

    print("asdfdsafadsfadsfadsfdsafdsaadsfdad");

    print(_customerData["pendingAmount"]);

    super.initState();
  }

  Future<void> customerData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/customer/getOneCustomersForOrgainsationAdmin');
    final body = {
      'customerId': _customerData["_id"],
      'userType': 'costomer',
      'organisation': _customerData["organisation"],
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
    final responseData = jsonDecode(response.body.toString());
    setState(() {
      pendingAmount = responseData['customer']['pendingAmount'];
    });
    print(responseData);
    print(pendingAmount);
  }

  Future<void> transactionData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/transactions/getAllTransaction');
    final body = {"customer": _customerData["_id"]};

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
      final responseData = jsonDecode(response.body.toString());
      setState(() {
        transactionData1 = responseData['allTransaction'];
        _customerData = widget.customerData;
      });

      // print(response.body);

      print('transactions after api: $transactionData1');
    }
    setState(() {
      isLoading = false;
    });

    // void deleteUser(user) async {
    //   var url = Uri.parse(
    //       'https://hta.hatimtechnologies.in/api/transactions/getAllTransaction/${user['_id']}');
    //   http.delete(url);
    // }
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Exit"),
            content: Text("Are you sure you want to exit?"),
            actions: <Widget>[
              TextButton(
                child: Text("YES"),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          );
        }) as bool;
    return exitApp;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: BottomNavigationPage()),
              );
            },
            icon: Icon(Icons.arrow_back)),
        title: Text('${_customerData["organisationName"]}'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              UrlLauncher.launch("tel://$mobileNumber");
            },
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                height: 80,
                child: isLoading
                    ? Center(child: null)
                    : RefreshWidget(
                        color: Color.fromRGBO(62, 13, 59, 1),
                        onRefresh: customerData,
                        child: GestureDetector(
                          onTap: () {},
                          child: Card(
                            elevation: 0,
                            color: const Color.fromARGB(228, 244, 242, 242),
                            child: Container(
                              margin: EdgeInsets.only(right: 10, top: 6),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: const Icon(
                                                Icons.map_outlined,
                                                size: 17,
                                                color: Color.fromRGBO(
                                                    62, 13, 59, 1),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                '${_customerData["location"]}',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        62, 13, 59, 1),
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${_customerData["name"]}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                '${_customerData["lastName"]}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                              'Due amount',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black38),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.only(left: 6, top: 6),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 0),
                                                child: Icon(
                                                  Icons.call,
                                                  size: 17,
                                                  color: Color.fromRGBO(
                                                      62, 13, 59, 1),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                child: Text(
                                                  '${_customerData["mobileNumber"]}',
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          62, 13, 59, 1),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.currency_rupee,
                                                size: 20,
                                                color: Color.fromRGBO(
                                                    62, 13, 59, 1),
                                              ),
                                              Text(
                                                pendingAmount?.toString() ?? '',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        62, 13, 59, 1),
                                                    fontWeight:
                                                        FontWeight.w500),
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
                        ),
                      ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                margin: EdgeInsets.only(left: 100, right: 20),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(62, 13, 59, 1),
                        ),
                      )
                    : RefreshWidget(
                        color: Color.fromRGBO(62, 13, 59, 1),
                        onRefresh: transactionData,
                        child: ListView.builder(
                          itemCount: transactionData1.length,
                          itemBuilder: (context, index) {
                            return WillPopScope(
                              onWillPop: () async {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: (BottomNavigationPage())),
                                );
                                return false;
                              },
                              child: GestureDetector(
                                onTap: (() {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: DetailedInfoPage(
                                          customerOrganization:
                                              transactionData1[index],
                                          customerData: _customerData,
                                        )),
                                  );
                                }),
                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: transactionData1[index]
                                                ["orderStatus"] ==
                                            'PAYMENT-COLLECTED'
                                        ? Color.fromRGBO(52, 135, 89, 1)
                                        : Color.fromRGBO(186, 0, 0, 1),
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 10, bottom: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                transactionData1[index]
                                                            ["orderStatus"] ==
                                                        'PAYMENT-COLLECTED'
                                                    ? Text(
                                                        'Paid Amount',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : Text(
                                                        'Bill Amount',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .currency_rupee_sharp,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          '${transactionData1[index]["amount"]}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                bottom: 10, right: 10, top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                transactionData1[index]
                                                            ["orderStatus"] ==
                                                        'PAYMENT-COLLECTED'
                                                    ? Text(
                                                        'Paid on',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Text(
                                                        'Raised on',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            right: 20),
                                                        child: Icon(
                                                          Icons.calendar_today,
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 0),
                                                        child: Text(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime.parse(
                                                                  transactionData1[
                                                                          index]
                                                                      [
                                                                      "createdAt"])),
                                                          style: TextStyle(
                                                            color: Colors.white,
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
          Column(
            children: [
              Row(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(52, 135, 89, 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PayBillPage(
                                      customerData: _customerData,
                                      pendingAmount: pendingAmount,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.add_to_photos),
                          ),
                          Text('PAY BILL'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(186, 0, 0, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            )),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RaiseBillPage(
                                        customerData: _customerData,
                                        pendingAmount: pendingAmount,
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.menu_book_sharp),
                            ),
                            Text('RAISE BILL'),
                          ],
                        ),
                      ))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
