// ignore_for_file: unnecessary_brace_in_string_interps, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hta/models/Usermodel.dart';

import 'package:hta/widgets/refresh.dart';

import 'package:intl/intl.dart';
import 'package:hta/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import 'addCustomer_page.dart';
import 'home_page_card_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String finalNumber = '';
  bool isLoading = false;
  var _pendingAmount;
  String countryCode = 'IN';
  bool _isConnected = true;
  var _customerData = {};
  var customerData;
  var person;
  var organizationName;
  double? pendingAmount;
  var transactionData1 = [];
  var date;
  List<Item> filteredList = [];
  List<Item> allCutomerList = [];
  var filteredCustomerData = [];
  var allCutomerData = [];
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    for (var node in _focusNodes) {
      node.addListener(() {});
      setState(() {});
    }

    super.initState();

    fetchData();
    _checkConnectivity();
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

  String formatPendingAmount(double amount) {
    // Check if the value has decimal places
    if (amount % 1 == 0) {
      // Display as whole number if there's no decimal part
      return amount.toStringAsFixed(0);
    } else {
      // Display with two decimal places if there is a decimal part
      return amount.toStringAsFixed(2);
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var token = sharedPreferences.getString('token');
    var organisation = sharedPreferences.getString('organisation');
    countryCode = sharedPreferences.getString('country') ?? 'IN';

    final url = Uri.parse(
        '${AppConstants.backendUrl}/api/customer/getAllCustomersForOrgainsationAdmin');
    final body = {"userType": "costomer", "organisation": organisation};
    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Fetch customer data
    final response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> itemListJson = responseData['allCustomer'];

      // Sort the customers by 'createdAt' in descending order
      itemListJson.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt']);
        final dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA); // Newest first
      });

      // Save sorted customer data to state
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

  void filterItems(String query) {
    List<String> terms = query.toLowerCase().split(' '); // Split query by space

    setState(() {
      filteredList = allCutomerList.where((item) {
        // Check that all terms match any of the fields
        return terms.every((term) =>
            item.name.toLowerCase().contains(term) ||
            item.lastName.toLowerCase().contains(term) ||
            item.organisationName.toLowerCase().contains(term) ||
            item.mobileNumber.toLowerCase().contains(term));
      }).toList();

      filteredCustomerData = allCutomerData.where((item) {
        // Check that all terms match any of the fields in the map
        return terms.every((term) =>
            item['name'].toLowerCase().contains(term) ||
            item['lastName'].toLowerCase().contains(term) ||
            item['organisationName'].toLowerCase().contains(term) ||
            item['mobileNumber'].toLowerCase().contains(term));
      }).toList();
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

  // final List<Widget> widgetList = <Widget>[HomePage(), ReportPage()];

  int suggestionsCount = 12;
  final focus = FocusNode();

  List<String> imageUrls = [];

  void updateImageUrls(List<String> newImageUrls) {
    // Update the state or perform other actions
    setState(() {
      imageUrls = newImageUrls;
    });
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
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        title: SizedBox(
          height: 38,
          child: Center(
            child: TextField(
              onChanged: (query) {
                filterItems(query);
              },
              style: TextStyle(color: Colors.white54),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 30),
                  hintText: '${filteredList.length} Customers',
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
          IconButton(
              onPressed: (() {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: AddCustomerPage(),
                    ));
              }),
              icon: Icon(Icons.add))
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
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
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
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final currentItem = filteredList[index];
                                  return GestureDetector(
                                      onTap: (() {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: DetailedCardPage(
                                                customerData:
                                                    filteredCustomerData[index],
                                              ),
                                            ));
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
                                                        radius: MediaQuery.of(
                                                                    context)
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
                                                    margin:
                                                        EdgeInsets.symmetric(
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
                                                          currentItem
                                                              .organisationName,
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
                                                                  currentItem
                                                                      .name,
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
                                                                    currentItem
                                                                        .lastName,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                )
                                                              ],
                                                            )),
                                                        SizedBox(
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
                                                                        top:
                                                                            10),
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
                                                                          color:
                                                                              Colors.black26,
                                                                        ),
                                                                        Text(
                                                                          currentItem
                                                                              .location,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black26),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 12),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          countryCode == 'KW'
                                                                              ? SizedBox(
                                                                                  width: 14,
                                                                                  child: ColorFiltered(
                                                                                      colorFilter: ColorFilter.mode(
                                                                                        Colors.black.withOpacity(0.8),
                                                                                        BlendMode.srcIn,
                                                                                      ),
                                                                                      child: Image.asset('assets/images/kwd.png')),
                                                                                )
                                                                              : Icon(
                                                                                  Icons.currency_rupee,
                                                                                  size: 12,
                                                                                  color: Color.fromRGBO(62, 13, 59, 1),
                                                                                ),
                                                                          SizedBox(
                                                                              width: 4), // Add some space between icon/image and text
                                                                          Text(
                                                                            formatPendingAmount(currentItem.pendingAmount),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w900,
                                                                              color: Color.fromRGBO(62, 13, 59, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  top: 10,
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(right: 5),
                                                                            child: Icon(Icons.call,
                                                                                size: 12,
                                                                                color: Colors.black26),
                                                                          ),
                                                                          Text(
                                                                            currentItem.mobileNumber,
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
                                                                              top: 12),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(
                                                                              right: 5,
                                                                            ),
                                                                            child:
                                                                                Icon(
                                                                              Icons.calendar_month_rounded,
                                                                              size: 12,
                                                                              color: Colors.black26,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            DateFormat('dd-MM-yyyy').format(DateTime.parse(currentItem.date.toString())),
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
            ),
      drawer: AppDrawer(),
    );
  }
}
