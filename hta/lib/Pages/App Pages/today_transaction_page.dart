import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/Transaction_model.dart';
import '../../widgets/customer_wrapper.dart';
import 'bottom_navigation_page.dart';
// import 'home_page_card_info_page.dart';

class TodayPage extends StatefulWidget {
  final List<Customer> customerData;
  // final fullCustomerData;

  TodayPage({
    required this.customerData,
    // required this.fullCustomerData,
  });

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  // var _fullCustomerData;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setState(() {
  //     // _fullCustomerData = widget.fullCustomerData ?? [];

  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print('Customer Data Length: ${widget.customerData.length}');
    final today = DateTime.now();

    // Filter customers with transactions on the current day
    List<Customer> customersWithTodayTransactions =
        widget.customerData.where((customer) {
      print('Customer: ${customer.name}');
      print('Transactions: ${customer.transactions}');
      return customer.transactions.any((transaction) {
        print('Transaction Date: ${transaction.date}');
        print('Today: $today');
        return transaction.date.year == today.year &&
            transaction.date.month == today.month &&
            transaction.date.day == today.day;
      });
    }).toList();
    for (var customer in customersWithTodayTransactions) {
      print('Customer: ${customer.name}');
      print('Transactions: ${customer.transactions}');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
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
        title: Text("Today's Transactions"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: customersWithTodayTransactions.length,
            itemBuilder: (context, index) {
              final customer = customersWithTodayTransactions[index];
              print('Customer: ${customer.name}');
              print('Transactions: ${customer.transactions}');
              return GestureDetector(
                  onTap: (() {
                    Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: CustomerDataWrapper(
                            customerData: customer.toMap(),
                          ),
                        ));
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: CircleAvatar(
                                    radius:
                                        MediaQuery.of(context).size.width * 0.1,
                                    backgroundImage: AssetImage(
                                        'assets/profile_img/profile_pic.jpg'),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 23),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.organisationName,
                                      // '${data1[index]["organisationName"]}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 6),
                                        child: Row(
                                          children: [
                                            Text(
                                              customer.name,
                                              // '${data1[index]["name"]}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                customer.lastName,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            )
                                          ],
                                        )),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 12,
                                                      color: Colors.black26,
                                                    ),
                                                    Text(
                                                      customer.location,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.black26),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.currency_rupee,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            62, 13, 59, 1),
                                                      ),
                                                      Text(
                                                        customer.pendingAmount
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Color.fromRGBO(
                                                              62, 13, 59, 1),
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
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            right: 5),
                                                        child: Icon(Icons.call,
                                                            size: 12,
                                                            color:
                                                                Colors.black26),
                                                      ),
                                                      Text(
                                                        customer.mobileNumber,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black26,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          right: 5,
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .calendar_month_rounded,
                                                          size: 12,
                                                          color: Colors.black26,
                                                        ),
                                                      ),
                                                      Text(
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(DateTime
                                                                .parse(customer
                                                                    .date
                                                                    .toString())),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black26,
                                                            fontSize: 12,
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
    );
  }
}
