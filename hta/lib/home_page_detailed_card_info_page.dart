// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailedInfoPage extends StatefulWidget {
  final customerOrganization;
  final customerId;

  const DetailedInfoPage(
      {required this.customerOrganization, required this.customerId});

  @override
  State<DetailedInfoPage> createState() => _DetailedInfoPageState();
}

class _DetailedInfoPageState extends State<DetailedInfoPage> {
  var _customerData = {};
  var customerId1 = {};
  var _customerOrganization = {};
  var image;
  var width;
  var height;
  bool isLoading = false;

  @override
  void initState() {
    transactionData();
    setState(() {
      _customerOrganization = widget.customerOrganization;
      customerId1 = widget.customerId;
      image = _customerOrganization['picture'];
      width = window.physicalSize.width;
      height = window.physicalSize.height;
    });
    print(image);
    print(customerId1);

    print(_customerOrganization);
    // TODO: implement initState
    super.initState();
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
      // print(response.body);

      // print(transactionData1);
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
          title: Text('${customerId1["organisationName"]}'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ]),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            height: MediaQuery.of(context).size.height * 0.133,
            child: Card(
                elevation: 0,
                color: Color.fromARGB(228, 244, 242, 242),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bill amount'),
                          Text('Description'),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 18,
                              color: Color.fromRGBO(62, 13, 59, 1),
                            ),
                            Text('${_customerOrganization["amount"]}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(62, 13, 59, 1),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Container(
                              child: Icon(
                                color: Color.fromRGBO(62, 13, 59, 1),
                                Icons.calendar_month_outlined,
                                size: 18,
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(
                                          _customerOrganization["createdAt"])),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(62, 13, 59, 1),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          Container(
              margin: EdgeInsets.only(top: 10),
              height: MediaQuery.of(context).size.height * 0.653,
              width: MediaQuery.of(context).size.width * 1,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : image.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(top: 90, left: 90),
                          child: Text(
                            'No Image Found',
                            style: TextStyle(fontSize: 30),
                          ),
                        )
                      : Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              '${_customerOrganization["picture"]}'))),
          Container(
            height: MediaQuery.of(context).size.height * 0.09,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                    onPressed: () {},
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.message),
                          Text('Send Message'),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(37, 211, 102, 1),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            )),
                        onPressed: () {},
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.whatsapp),
                              Text('Whatsapp'),
                            ],
                          ),
                        )))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
