// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page_card_info_page.dart';

class PayBillPage extends StatefulWidget {
  final customerId;

  const PayBillPage({required this.customerId});

  @override
  State<PayBillPage> createState() => _RaiseBillPageState();
}

class _RaiseBillPageState extends State<PayBillPage> {
  var customerId1;
  final dateController = TextEditingController(
      text: DateFormat.yMd().add_jm().format(DateTime.now()));
  final amount = TextEditingController();
  final description = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      customerId1 = widget.customerId;
    });
    print(customerId1);

    super.initState();
  }

  Future<void> payBill() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      print('hello1234');

      final url = Uri.parse(
          'https://hta.hatimtechnologies.in/api/transactions/addTransaction');

      final body = {
        "orderId": "",
        "customer": customerId1['_id'],
        "amount": amount.text,
        "createdAt": dateController.text,
        "paymentStatus": "",
        "message": description.text,
        "picture": "",
        "orderStatus": "PAYMENT-COLLECTED",
        "pendingAmount": '7869820020'
      };
      final header = {
        'Authorization': 'Bearer $token',
      };
      print('gfre');
      print(body);

      final response = await http.post(url, body: body, headers: header);

      print('hello');

      print(response.body);
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Transaction completed succesfully'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailedCardPage(
                            customerData: customerId1,
                            customerData1: customerId1,
                          )));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Material(
        child: Form(
            key: _formKey,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Color.fromRGBO(37, 211, 102, 1),
                        height: 130,

                        // padding: EdgeInsets.only(left: 30, top: 50),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 35, vertical: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pay BILL',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Amount cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Type your amount here",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                              prefixIcon: Icon(
                                Icons.currency_rupee,
                                size: 19.0,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: description,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Description cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Type your comment here",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                              prefixIcon: Icon(
                                Icons.message,
                                size: 19.0,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.calendar_month_rounded,
                                size: 19.0,
                                color: Color.fromRGBO(62, 13, 59, 1),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      child: Icon(
                        Icons.add,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 40.0, horizontal: 30),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(37, 211, 102, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(350, 50),
                          ),
                          onPressed: () {
                            payBill();
                          },
                          child: Text("PAY BILL"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
