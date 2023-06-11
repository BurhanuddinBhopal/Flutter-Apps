// ignore_for_file: unnecessary_brace_in_string_interps, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Drawer%20Pages/report_page.dart';

import 'package:hta/widgets/refresh.dart';
import 'package:intl/intl.dart';
import 'package:hta/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addCustomer_page.dart';
import 'home_page_card_info_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String finalNumber = '';
  bool isLoading = false;

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  var customerData;
  var serverData = [];

  var data1 = [];
  var pendingAmount;
  // List<Product> allProducts = [];

  var date;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var token = sharedPreferences.getString('token');
    print(token);
    var lastName = sharedPreferences.getString('lastName');

    var organisation = sharedPreferences.getString('organisation');

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
      final responseData = jsonDecode(response.body.toString());
      var list = responseData['allCustomer'] as List<dynamic>;

      setState(() {
        // allProducts = [];

        pendingAmount = responseData['dueAmount'];
        serverData = responseData['allCustomer'];
        data1 = responseData['allCustomer'];
        print(pendingAmount);

        print(data1);
      });
    }
    setState(() {
      isLoading = false;
    });
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

  PageController pageController = PageController();
  // List<Widget> pages = [HomePage(), ReportPage(customerData: ,)];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        title: Container(
          height: 38,
          child: Center(
            child: TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 30),
                  hintText: '${data1.length} Customers',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 80, 46, 78),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: (() {}), icon: Icon(Icons.notifications_none))
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(62, 13, 59, 1),
              ),
            )
          : RefreshWidget(
              color: Color.fromRGBO(62, 13, 59, 1),
              onRefresh: fetchData,
              child: WillPopScope(
                onWillPop: () => _onBackButtonPressed(context),
                child: Container(
                  color: Color.fromRGBO(62, 13, 59, 1),
                  child: Column(
                    children: [
                      // Container(
                      //   height: MediaQuery.of(context).size.height * 0.06,
                      //   color: Colors.black,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Container(
                      //         margin: EdgeInsets.only(left: 18),
                      //         child: Text(
                      //           "Today's",
                      //           style:
                      //               TextStyle(fontSize: 20, color: Colors.white),
                      //         ),
                      //       ),
                      //       Row(
                      //         children: [
                      //           Container(
                      //             margin: EdgeInsets.only(right: 65),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.currency_rupee,
                      //                   color: Color.fromRGBO(186, 0, 0, 1),
                      //                 ),
                      //                 Text(
                      //                   '0.00',
                      //                   style: TextStyle(
                      //                     fontSize: 20,
                      //                     color: Color.fromRGBO(186, 0, 0, 1),
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //           Container(
                      //             margin: EdgeInsets.only(right: 18),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.currency_rupee,
                      //                   color: Color.fromRGBO(52, 135, 89, 1),
                      //                 ),
                      //                 Text(
                      //                   '0.00',
                      //                   style: TextStyle(
                      //                     fontSize: 20,
                      //                     color: Color.fromRGBO(52, 135, 89, 1),
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           )
                      //         ],
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   height: MediaQuery.of(context).size.height * 0.06,
                      //   color: Colors.black,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Container(
                      //         margin: EdgeInsets.only(left: 18),
                      //         child: Text(
                      //           "This month",
                      //           style:
                      //               TextStyle(fontSize: 20, color: Colors.white),
                      //         ),
                      //       ),
                      //       Row(
                      //         children: [
                      //           Container(
                      //             margin: EdgeInsets.only(right: 65),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.currency_rupee,
                      //                   color: Color.fromRGBO(186, 0, 0, 1),
                      //                 ),
                      //                 Text(
                      //                   '0.00',
                      //                   style: TextStyle(
                      //                     fontSize: 20,
                      //                     color: Color.fromRGBO(186, 0, 0, 1),
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //           Container(
                      //             margin: EdgeInsets.only(right: 18),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.currency_rupee,
                      //                   color: Color.fromRGBO(52, 135, 89, 1),
                      //                 ),
                      //                 Text(
                      //                   '0.00',
                      //                   style: TextStyle(
                      //                     fontSize: 20,
                      //                     color: Color.fromRGBO(52, 135, 89, 1),
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           )
                      //         ],
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: data1.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: (() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailedCardPage(
                                                    customerData: data1[index],
                                                  )));
                                    }),
                                    child: Container(
                                      margin: EdgeInsets.all(6),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.18,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 12),
                                                    child: CircleAvatar(
                                                      radius:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                      backgroundImage: AssetImage(
                                                          'assets/profile_img/profile_pic.jpg'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 23),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${data1[index]["organisationName"]}',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 6),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                '${data1[index]["name"]}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            5),
                                                                child: Text(
                                                                  '${data1[index]["lastName"]}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size:
                                                                            12,
                                                                        color: Colors
                                                                            .black26,
                                                                      ),
                                                                      Text(
                                                                        '${data1[index]["location"]}',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black26),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                12),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .currency_rupee,
                                                                          size:
                                                                              12,
                                                                          color: Color.fromRGBO(
                                                                              62,
                                                                              13,
                                                                              59,
                                                                              1),
                                                                        ),
                                                                        Text(
                                                                          '${data1[index]["pendingAmount"]}',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w900,
                                                                            color: Color.fromRGBO(
                                                                                62,
                                                                                13,
                                                                                59,
                                                                                1),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                top: 10,
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(right: 5),
                                                                          child: Icon(
                                                                              Icons.call,
                                                                              size: 12,
                                                                              color: Colors.black26),
                                                                        ),
                                                                        Text(
                                                                          '${data1[index]["mobileNumber"]}',
                                                                          style: TextStyle(
                                                                              color: Colors.black26,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                12),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(
                                                                            right:
                                                                                5,
                                                                          ),
                                                                          child:
                                                                              Icon(
                                                                            Icons.calendar_month_rounded,
                                                                            size:
                                                                                12,
                                                                            color:
                                                                                Colors.black26,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          DateFormat('dd-MM-yyyy').format(DateTime.parse(data1[index]
                                                                              [
                                                                              "createdAt"])),
                                                                          style: TextStyle(
                                                                              color: Colors.black26,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      drawer: AppDrawer(),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 18.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 60),
          height: 46.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddCustomerPage(
                            organization: data1,
                          )));
            },
            icon: Icon(Icons.person_add),
            label: Text("Add Customer"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.note_add)),
      //     BottomNavigationBarItem(icon: Icon(Icons.note_add))
      //   ],
      // ),
    );
  }
}
