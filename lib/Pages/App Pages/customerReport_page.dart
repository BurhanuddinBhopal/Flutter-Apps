import 'dart:convert';
// import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:hta/language/language_constant.dart';

import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

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
  String? countryCode;
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
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
    DateTime currentDate, // Add currentDate parameter
  ) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Minimum selectable date
      lastDate: currentDate, // Set the maximum date to currentDate
    );

    if (selectedDate != null && selectedDate != initialDate) {
      onDateSelected(selectedDate);
    }
  }

  // void _showDateRangeDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select Date Range'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               readOnly: true,
  //               decoration: const InputDecoration(
  //                 labelText: 'Start Date',
  //               ),
  //               onTap: () => _selectDate(
  //                 context,
  //                 _startDate ?? DateTime.now(),
  //                 (selectedDate) {
  //                   setState(() {
  //                     _startDate = selectedDate;
  //                     _startDateController.text =
  //                         DateFormat('yyyy-MM-dd').format(selectedDate);
  //                   });
  //                 },
  //                 DateTime.now(), // Pass current date for validation
  //               ),
  //               controller: _startDateController,
  //             ),
  //             TextField(
  //               readOnly: true,
  //               decoration: const InputDecoration(
  //                 labelText: 'End Date',
  //               ),
  //               onTap: () => _selectDate(
  //                 context,
  //                 _endDate ?? DateTime.now(),
  //                 (selectedDate) {
  //                   setState(() {
  //                     _endDate = selectedDate;
  //                     _endDateController.text =
  //                         DateFormat('yyyy-MM-dd').format(selectedDate);
  //                   });
  //                 },
  //                 DateTime.now(), // Pass current date for validation
  //               ),
  //               controller: _endDateController,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             child: const Center(
  //                 child: Text(
  //               'Submit',
  //               style: TextStyle(fontWeight: FontWeight.w600),
  //             )),
  //             onPressed: () {
  //               shareStatementData(
  //                 _customerData['_id'],
  //                 _startDate!,
  //                 _endDate!,
  //               );
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> shareStatementData(
  //     String customerId, DateTime startDate, DateTime endDate) async {
  //   final SharedPreferences sharedPreferences =
  //       await SharedPreferences.getInstance();
  //   var token = sharedPreferences.getString('token');

  //   final url = Uri.parse('${AppConstants.backendUrl}/api/report/getStatement');

  //   final body = {
  //     "customerId": customerId,
  //     "startDate": startDate.toUtc().toIso8601String(),
  //     "endDate": endDate.toUtc().toIso8601String(),
  //   };

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(body),
  //     );
  //     final responseData = jsonDecode(response.body.toString());

  //     if (response.statusCode == 200) {
  //       print("responseData: $responseData");
  //     } else {
  //       print('Failed to share statement data: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred while sharing statement data: $e');
  //   }
  // }
  // Future<void> shareStatementData(
  //     String customerId, DateTime startDate, DateTime endDate) async {
  //   final SharedPreferences sharedPreferences =
  //       await SharedPreferences.getInstance();
  //   var token = sharedPreferences.getString('token');

  //   final url = Uri.parse('${AppConstants.backendUrl}/api/report/getStatement');

  //   final body = {
  //     "customerId": customerId,
  //     "startDate": startDate.toUtc().toIso8601String(),
  //     "endDate": endDate.toUtc().toIso8601String(),
  //   };

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(body),
  //     );
  //     final responseData = jsonDecode(response.body.toString());

  //     if (response.statusCode == 200) {
  //       final transactions =
  //           responseData['cutomerTransaction'] as List<dynamic>? ?? [];

  //       final pdf = pw.Document();
  //       double totalDebit = 0;
  //       double totalCredit = 0;

  //       pdf.addPage(
  //         pw.Page(
  //           build: (pw.Context context) {
  //             return pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Text('Transaction Statement',
  //                     style: const pw.TextStyle(fontSize: 24)),
  //                 pw.SizedBox(height: 20),
  //                 pw.Text(
  //                     'Organisation: ${responseData['organisation']['OrganisationName']}'),
  //                 pw.Text(
  //                     'Contact: ${responseData['organisation']['OrganisationContact']}'),
  //                 pw.SizedBox(height: 20),
  //                 if (transactions.isEmpty)
  //                   pw.Text(
  //                       'No transactions available for the selected date range.'),
  //                 if (transactions.isNotEmpty)
  //                   pw.Table.fromTextArray(
  //                     headers: [
  //                       'Date',
  //                       'Transaction Type',
  //                       'Debit',
  //                       'Credit',
  //                       'Remaining Balance',
  //                     ],
  //                     data: transactions.map((transaction) {
  //                       final date = DateTime.parse(
  //                           transaction['orderPlaceHolder']['date']);
  //                       final orderStatus = transaction['orderStatus'];
  //                       final amount = transaction['amount'] ?? 0.0;
  //                       final dueAmount = transaction['dueAmount'] ?? 0.0;
  //                       final isCredit = orderStatus == 'PAYMENT-COLLECTED';

  //                       if (isCredit) {
  //                         totalCredit += amount;
  //                       } else {
  //                         totalDebit += amount;
  //                       }

  //                       return [
  //                         DateFormat('yyyy-MM-dd').format(date),
  //                         orderStatus,
  //                         isCredit ? '-' : amount.toString(),
  //                         isCredit ? amount.toString() : '-',
  //                         dueAmount.toString(),
  //                       ];
  //                     }).toList(),
  //                   ),
  //                 pw.SizedBox(height: 20),
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.end,
  //                   children: [
  //                     pw.Text('Total Debit: $totalDebit'),
  //                   ],
  //                 ),
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.end,
  //                   children: [
  //                     pw.Text('Total Credit: $totalCredit'),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );

  //       final output = await getTemporaryDirectory();
  //       final file = File("${output.path}/statement.pdf");
  //       await file.writeAsBytes(await pdf.save());

  //       await Share.shareXFiles(
  //         [XFile(file.path)],
  //         text: 'Here is your transaction statement',
  //       );
  //     } else {
  //       print('Failed to share statement data: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred while sharing statement data: $e');
  //   }
  // }

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
      print(countryCode);
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
        '${AppConstants.backendUrl}/api/transactions/getOrganisationReportForOneCustomer');
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
  }

  Future<void> customersYearlyTransactionData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
      '${AppConstants.backendUrl}/api/report/getYearlyReport',
    );

    final body = {
      "customerId": _customerData["_id"],
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
      print('Customer IDs sent successfully for year: ${response.body}');

      // Update the state with the response data
      setState(() {
        updateYearlyData(responseData);
      });
    } else {
      print('Failed to send customer IDs: ${response.statusCode}');
    }
  }

  void updateYearlyData(Map<String, dynamic> responseData) {
    print('Response Data: $responseData');

    if (responseData['years'] != null && responseData['amounts'] != null) {
      // Convert years to a list of strings
      years = List<String>.from(
          responseData['years'].map((year) => year.toString()));

      // Convert amounts to a list of doubles directly
      yearlyValues = List<double>.from(responseData['amounts']);

      // Print years and yearlyValues before setting state
      print('Years: $years');
      print('Yearly Values: $yearlyValues');

      setState(() {
        // Update the state
        // The state is already updated in this method
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
    print("currentYear: $currentYear");

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    print('token: $token');

    final url = Uri.parse(
      '${AppConstants.backendUrl}/api/report/getMonthlyReportPerYear',
    );

    final body = {
      "customerId": _customerData["_id"],
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
      print(_customerData["_id"]);
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
  void initState() {
    customerData();
    _getCountryCode();
    customersMonthlyTransactionData();
    customersYearlyTransactionData();
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 5; i++) {
      years.add((currentYear - i).toString());
    }
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
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          _organizationName,
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
              color: const Color.fromRGBO(62, 13, 59, 1),
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: WillPopScope(
                  onWillPop: () async {
                    return true;
                  },
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
                          margin: EdgeInsets.only(top: 10),
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
                          margin: EdgeInsets.only(top: 20),
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
                                      .toDouble() // Dynamically set maxY
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
