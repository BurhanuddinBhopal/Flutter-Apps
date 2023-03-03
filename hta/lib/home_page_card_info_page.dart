// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hta/card_info_page_raise_bill_button_page.dart';
import 'package:hta/home_page.dart';
import 'package:hta/home_page_detailed_card_info_page.dart';
import 'package:hta/widgets/refresh.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_info_page_pay_bill_button_page.dart';

class DetailedCardPage extends StatefulWidget {
  final customerData;
  final customerData1;

  const DetailedCardPage(
      {required this.customerData, required this.customerData1});
  @override
  State<DetailedCardPage> createState() => _DetailedCardPageState();
}

class _DetailedCardPageState extends State<DetailedCardPage> {
  var _customerData = {};
  var transactionData1 = [];
  var width;
  var height;
  bool isLoading = false;

  @override
  void initState() {
    transactionData();
    setState(() {
      _customerData = widget.customerData;
      _customerData = widget.customerData1;
      width = window.physicalSize.width;
      height = window.physicalSize.height;
    });
    print(width);
    print(height);
    print(widget.customerData1);

    super.initState();
  }

  Future<void> transactionData() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 200));
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
      });

      // print(response.body);
      print(transactionData1);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text('${_customerData["organisationName"]}'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: 10 / 1080 * width,
                    right: 10 / 1080 * width,
                    top: 10 / 2361 * height),
                height: 80 / 2361 * height,
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    elevation: 0,
                    color: const Color.fromARGB(228, 244, 242, 242),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: 10 / 1080 * width, top: 6 / 2361 * height),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // margin: const EdgeInsets.all(6),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 7 / 1080 * width),
                                      child: const Icon(
                                        Icons.map_outlined,
                                        size: 17,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10 / 1080 * width),
                                      child: Text(
                                        '${_customerData["location"]}',
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(62, 13, 59, 1),
                                            fontWeight: FontWeight.w500),
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
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${_customerData["lastName"]}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 3 / 2361 * height),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 6 / 1080 * width,
                                      top: 6 / 2361 * height),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            right: 0 / 1080 * width),
                                        child: Icon(
                                          Icons.call,
                                          size: 17,
                                          color: Color.fromRGBO(62, 13, 59, 1),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 10 / 1080 * width,
                                        ),
                                        child: Text(
                                          '${_customerData["mobileNumber"]}',
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(62, 13, 59, 1),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 3 / 2361 * height),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.currency_rupee,
                                        size: 20,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                      Text(
                                        '${_customerData["pendingAmount"]}',
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(62, 13, 59, 1),
                                            fontWeight: FontWeight.w500),
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
              Container(
                height: MediaQuery.of(context).size.height * 0.719,
                margin: EdgeInsets.only(
                  left: 100 / 1080 * width,
                  right: 20 / 1080 * width,
                ),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshWidget(
                        onRefresh: transactionData,
                        child: ListView.builder(
                          itemCount: transactionData1.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: (() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailedInfoPage(
                                              customerOrganization:
                                                  transactionData1[index],
                                              customerId: _customerData,
                                            )));
                              }),
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 10 / 2361 * height),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: transactionData1[index]
                                              ["orderStatus"] ==
                                          'PAYMENT-COLLECTED'
                                      ? Colors.green[300]
                                      : Color.fromARGB(255, 243, 17, 17),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 10 / 2361 * height,
                                              left: 10 / 1080 * width,
                                              bottom: 10 / 2361 * height),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bill Amount',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 10 / 2361 * height),
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
                                                            color: Colors.white,
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
                                              bottom: 10 / 2361 * height,
                                              right: 10 / 1080 * width,
                                              top: 10 / 2361 * height),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Raised on',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 10 / 2361 * height),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 20 /
                                                              1080 *
                                                              width),
                                                      child: Icon(
                                                        Icons.calendar_today,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left:
                                                              0 / 1080 * width),
                                                      child: Text(
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                transactionData1[
                                                                        index][
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
                          backgroundColor: Colors.green[300],
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PayBillPage(
                                      customerId: _customerData,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_to_photos),
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
                            backgroundColor: Color.fromARGB(255, 243, 17, 17),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            )),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RaiseBillPage(
                                        customerId: _customerData,
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_sharp),
                            Text('RAISE BILL'),
                          ],
                        ),
                      ))
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
