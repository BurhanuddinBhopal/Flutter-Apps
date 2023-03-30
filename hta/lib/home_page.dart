// ignore_for_file: unnecessary_brace_in_string_interps, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';

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

  var data1 = [];

  var date;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var token = sharedPreferences.getString('token');
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

      setState(() {
        data1 = responseData['allCustomer'];
        print(data1);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: CircularProgressIndicator(),
            )
          : RefreshWidget(
              onRefresh: fetchData,
              child: Container(
                color: Color.fromRGBO(62, 13, 59, 1),
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: data1.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: (() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailedCardPage(
                                          customerData: data1[index],
                                          customerData1: data1[index],
                                        )));
                          }),
                          child: Container(
                            margin: EdgeInsets.all(6),
                            height: MediaQuery.of(context).size.height * 0.18,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 12),
                                      child: CircleAvatar(
                                        radius:
                                            MediaQuery.of(context).size.width *
                                                0.125,
                                        backgroundImage: AssetImage(
                                            'assets/profile_img/profile_pic.jpg'),
                                      ),
                                    ),
                                    Container(
                                        margin:
                                            EdgeInsets.only(left: 18, top: 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${data1[index]["organisationName"]}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${data1[index]["name"]}',
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Text(
                                                          '${data1[index]["lastName"]}'),
                                                    )
                                                  ],
                                                )),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              size: 13,
                                                              color: Colors
                                                                  .black26,
                                                            ),
                                                            Text(
                                                              '${data1[index]["location"]}',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black26),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 12),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .currency_rupee,
                                                                size: 13,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        62,
                                                                        13,
                                                                        59,
                                                                        1),
                                                              ),
                                                              Text(
                                                                '${data1[index]["pendingAmount"]}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Color
                                                                      .fromRGBO(
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
                                                    margin: EdgeInsets.only(
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
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            5),
                                                                child: Icon(
                                                                    Icons.call,
                                                                    size: 13,
                                                                    color: Colors
                                                                        .black26),
                                                              ),
                                                              Text(
                                                                '${data1[index]["mobileNumber"]}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black26,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 12),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  right: 5,
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .calendar_month_rounded,
                                                                  size: 13,
                                                                  color: Colors
                                                                      .black26,
                                                                ),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'dd-MM-yyyy')
                                                                    .format(DateTime.parse(
                                                                        data1[index]
                                                                            [
                                                                            "createdAt"])),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black26,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
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
      drawer: AppDrawer(),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 18.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 60),
          height: 46.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddCustomerPage()));
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
    );
  }
}
