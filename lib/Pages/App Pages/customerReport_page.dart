// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hta/google%20anaylitics/anaylitics_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hta/language/language_constant.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class CustomerReportPage extends StatefulWidget {
  final customerData;

  const CustomerReportPage({super.key, required this.customerData});
  @override
  State<CustomerReportPage> createState() => _CustomerReportPageState();
}

class _CustomerReportPageState extends State<CustomerReportPage> {
  final AnalyticsService _analyticsService = AnalyticsService();
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

  void _showDateRangeDialog() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                ),
                onTap: () => _selectDate(
                  context,
                  _startDate ?? DateTime.now(),
                  (selectedDate) {
                    setState(() {
                      _startDate = selectedDate;
                      _startDateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  },
                  DateTime.now(),
                ),
                controller: _startDateController,
              ),
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                ),
                onTap: () => _selectDate(
                  context,
                  _endDate ?? DateTime.now(),
                  (selectedDate) {
                    setState(() {
                      _endDate = selectedDate;
                      _endDateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  },
                  DateTime.now(),
                ),
                controller: _endDateController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Center(
                  child: Text(
                'Submit',
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
              onPressed: () {
                _showLoadingDialog(context); // Show the loading dialog
                shareStatementData(
                  _customerData['_id'],
                  _startDate!,
                  _endDate!,
                ).then((_) {
                  Navigator.of(context).pop(); // Close the loading dialog
                  Navigator.of(context).pop(); // Close the date range dialog
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Make the dialog background transparent
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text('Generating PDF, please wait...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  Future<void> shareStatementData(
      String customerId, DateTime startDate, DateTime endDate) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    final url = Uri.parse('${AppConstants.backendUrl}/api/report/getStatement');

    final body = {
      "customerId": customerId,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final responseData = jsonDecode(response.body.toString());

      if (response.statusCode == 200) {
        final transactions =
            responseData['cutomerTransaction'] as List<dynamic>? ?? [];

        final pdf = pw.Document();
        double totalDebit = 0;
        double totalCredit = 0;
        double totalRemainingBalance = 0;

        // Load font
        final pdfFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
        );
        final pdfFontBold = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
        );
        final logoImage = pw.MemoryImage(
          (await rootBundle.load('assets/images/TransperantLogo.png'))
              .buffer
              .asUint8List(),
        );

        // Get country code
        final countryCurrencyCode = await _getCountryCurrencyCode();

        // Determine currency symbol
        final currencySymbol = countryCurrencyCode == 'KW' ? 'KD' : '₹';

        // Determine formatting function
        String formatAmount(double amount) {
          return amount % 1 == 0
              ? '$currencySymbol ${amount.toStringAsFixed(0)}'
              : '$currencySymbol ${amount.toStringAsFixed(2)}';
        }

        const int rowsPerPageFirstPage = 18;
        const int rowsPerPageSubsequentPages = 30;

        pw.TableRow createTableRow(transaction) {
          final date = DateTime.parse(transaction['orderPlaceHolder']['date']);
          final orderStatus = transaction['orderStatus'];
          final amount = (transaction['amount'] ?? 0.0).toDouble();
          final dueAmount = (transaction['dueAmount'] ?? 0.0).toDouble();
          final isCredit = orderStatus == 'PAYMENT-COLLECTED';

          // Format amounts
          final formattedAmount = formatAmount(amount);
          final formattedDueAmount = formatAmount(dueAmount);

          if (isCredit) {
            totalCredit += amount;
          } else {
            totalDebit += amount;
          }

          totalRemainingBalance = dueAmount; // Update total remaining balance

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: pw.Text(
                  DateFormat('dd-MM-yyyy').format(date),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text(orderStatus),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: pw.Text(isCredit ? '-' : formattedAmount),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: pw.Text(isCredit ? formattedAmount : '-'),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: pw.Text(formattedDueAmount),
              ),
            ],
          );
        }

        void addFirstPage(List transactions, int startIndex, int endIndex,
            {bool isLastPage = false}) {
          // Identify the first transaction in the selected date range
          final firstTransaction =
              transactions.isNotEmpty ? transactions.first : null;
          double beginningBalance = 0;
          double firstTransactionAmount = 0;
          bool isFirstTransactionCredit = false;

          if (firstTransaction != null) {
            final firstTransactionDate =
                DateTime.parse(firstTransaction['orderPlaceHolder']['date']);
            final orderStatus = firstTransaction['orderStatus'];
            firstTransactionAmount =
                (firstTransaction['amount'] ?? 0.0).toDouble();
            final remainingBalance =
                (firstTransaction['dueAmount'] ?? 0.0).toDouble();

            // Calculate beginning balance based on first transaction
            if (orderStatus == 'PAYMENT-COLLECTED') {
              isFirstTransactionCredit = true;
              beginningBalance =
                  remainingBalance - firstTransactionAmount; // Credit: subtract
            } else {
              isFirstTransactionCredit = false;
              beginningBalance =
                  remainingBalance + firstTransactionAmount; // Debit: add
            }
          }

          // Add the first page with beginning balance and first transaction details
          pdf.addPage(
            pw.Page(
              margin: pw.EdgeInsets.all(16),
              build: (pw.Context context) {
                final pageWidth = context.page.pageFormat.availableWidth;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left side with logo
                        pw.Image(
                          logoImage,
                          width: pageWidth * 0.3,
                        ),

                        // Right side with organization details
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Organisation name: ${responseData['organisation']['OrganisationName']}',
                              style:
                                  pw.TextStyle(fontSize: 18, font: pdfFontBold),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Phone no.: ${responseData['organisation']['OrganisationContact'].startsWith('+91') ? responseData['organisation']['OrganisationContact'] : '+91${responseData['organisation']['OrganisationContact']}'}',
                              style: pw.TextStyle(fontSize: 16, font: pdfFont),
                            ),
                            pw.Text(
                              'Address: ${countryCurrencyCode == 'KW' ? 'Kuwait' : 'India'}',
                              style: pw.TextStyle(fontSize: 16, font: pdfFont),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 20),
                    // Centered and bold heading
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Transaction Statement',
                          style: pw.TextStyle(
                            fontSize: 24,
                            font: pdfFontBold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),

                    // Organization and Contact details
                    pw.Text(
                      'Organisation name: ${responseData['customer']['organisationName']}',
                      style: pw.TextStyle(fontSize: 20, font: pdfFontBold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Contact no.: ${responseData['customer']['mobileNumber']}',
                      style: pw.TextStyle(fontSize: 16, font: pdfFont),
                    ),
                    pw.Text(
                      'Address: ${responseData['customer']['address']}',
                      style: pw.TextStyle(fontSize: 16, font: pdfFont),
                    ),
                    pw.SizedBox(height: 20),

                    // Date Range
                    pw.Text(
                      'Duration: From ${DateFormat('dd-MM-yyyy').format(startDate)} to ${DateFormat('dd-MM-yyyy').format(endDate)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: pdfFontBold,
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Conditional display for transactions
                    if (transactions.isEmpty)
                      pw.Text(
                        'No transactions available for the selected date range.',
                        style: pw.TextStyle(
                          fontSize: 20,
                          font: pdfFontBold,
                          color: PdfColors.black,
                        ),
                      )
                    else
                      pw.Container(
                        child: pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.black,
                            width: 1,
                          ),
                          columnWidths: {
                            0: pw.FixedColumnWidth(120),
                            1: pw.FixedColumnWidth(200),
                            2: pw.FixedColumnWidth(130),
                            3: pw.FixedColumnWidth(130),
                            4: pw.FixedColumnWidth(150),
                          },
                          children: [
                            // Header row
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey400,
                              ),
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: pw.Text(
                                    'Date',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    'Transaction Type',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    'Debit',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    'Credit',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    'Remaining Balance',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Beginning balance row
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: pw.Text(
                                    DateFormat('dd-MM-yyyy').format(startDate),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  child: pw.Text('Beginning Balance'),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child: pw.Text(isFirstTransactionCredit
                                      ? formatAmount(beginningBalance)
                                      : '-'),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child: pw.Text(isFirstTransactionCredit
                                      ? '-'
                                      : formatAmount(beginningBalance)),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child:
                                      pw.Text(formatAmount(beginningBalance)),
                                ),
                              ],
                            ),

                            // Data rows for the first page
                            ...transactions
                                .skip(startIndex)
                                .take(endIndex - startIndex)
                                .map((transaction) =>
                                    createTableRow(transaction))
                                .toList(),
                            if (isLastPage)
                              pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey400,
                                ),
                                children: [
                                  pw.Container(),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: pw.Text(
                                      'Total',
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        font: pdfFontBold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: pw.Text(
                                      formatAmount(totalDebit),
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        font: pdfFontBold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: pw.Text(
                                      formatAmount(totalCredit),
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        font: pdfFontBold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: pw.Text(
                                      formatAmount(totalRemainingBalance),
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        font: pdfFontBold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }

        void addSubsequentPage(
            List transactions, int startIndex, int endIndex, bool isLastPage) {
          pdf.addPage(
            pw.Page(
              margin: pw.EdgeInsets.all(16),
              build: (pw.Context context) {
                return pw.Column(
                  children: [
                    pw.Container(
                      child: pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.black,
                          width: 1,
                        ),
                        columnWidths: {
                          0: pw.FixedColumnWidth(120),
                          1: pw.FixedColumnWidth(200),
                          2: pw.FixedColumnWidth(130),
                          3: pw.FixedColumnWidth(130),
                          4: pw.FixedColumnWidth(150),
                        },
                        children: [
                          // Header row (repeated on each subsequent page)
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey400,
                            ),
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: pw.Text(
                                  'Date',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: pdfFontBold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: pw.Text(
                                  'Transaction Type',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: pdfFontBold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: pw.Text(
                                  'Debit',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: pdfFontBold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: pw.Text(
                                  'Credit',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: pdfFontBold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: pw.Text(
                                  'Remaining Balance',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: pdfFontBold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Data rows for subsequent pages
                          ...transactions
                              .skip(startIndex)
                              .take(endIndex - startIndex)
                              .map((transaction) => createTableRow(transaction))
                              .toList(),
                          // If this is the last page, add the total row
                          if (isLastPage)
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey400,
                              ),
                              children: [
                                pw.Container(),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: pw.Text(
                                    'Total',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    formatAmount(totalDebit),
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    formatAmount(totalCredit),
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: pw.Text(
                                    formatAmount(totalRemainingBalance),
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: pdfFontBold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }

// Main function to handle PDF generation with multiple pages
        if (transactions.isEmpty) {
          // No transactions, only add the first page with no rows.
          addFirstPage(transactions, 0, 0, isLastPage: true);
        } else {
          // Calculate the total number of pages
          int totalPages = ((transactions.length - rowsPerPageFirstPage) /
                      rowsPerPageSubsequentPages)
                  .ceil() +
              1;

          // Add the first page
          addFirstPage(transactions, 0,
              rowsPerPageFirstPage.clamp(0, transactions.length),
              isLastPage: totalPages == 1);

          // Add subsequent pages if there are more than one
          for (int i = 1; i < totalPages; i++) {
            int startIndex =
                rowsPerPageFirstPage + (i - 1) * rowsPerPageSubsequentPages;
            int endIndex = startIndex + rowsPerPageSubsequentPages;

            if (endIndex > transactions.length) {
              endIndex = transactions.length;
            }

            // Check if this is the last page
            bool isLastPage = i == totalPages - 1;

            // Add subsequent page with a check for the last page
            addSubsequentPage(transactions, startIndex, endIndex, isLastPage);
          }
        }

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/statement.pdf");
        await file.writeAsBytes(await pdf.save());

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Here is your transaction statement',
        );
      } else {
        print('Failed to share statement data: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sharing statement data: $e');
    }
  }

  Future<String> _getCountryCurrencyCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getString('country') ?? 'IN';
  }

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
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

      // Update the state with the response data
      setState(() {
        updateYearlyData(responseData);
      });
    } else {}
  }

  void updateYearlyData(Map<String, dynamic> responseData) {
    if (responseData['years'] != null && responseData['amounts'] != null) {
      // Convert years to a list of strings
      years = List<String>.from(
          responseData['years'].map((year) => year.toString()));

      // Convert amounts to a list of doubles, handling int to double conversion
      yearlyValues = List<double>.from(
        responseData['amounts']
            .map((amount) => (amount is int) ? amount.toDouble() : amount),
      );

      setState(() {
        // Update the state with the converted values
      });
    } else {
      // If the data is null or empty, reset the values
      years = [];
      yearlyValues = [];

      setState(() {
        years = [];
        yearlyValues = [];
      });
    }
  }

  Future<void> customersMonthlyTransactionData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

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
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      List<String> responseMonths = List<String>.from(responseData['months']);
      List<int> responseAmounts = List<int>.from(
          responseData['amounts'].map((amount) => amount.toInt()));

      setState(() {
        months = responseMonths.map((month) => month.substring(0, 3)).toList();
        values = responseAmounts;
      });
    } else {}
  }

  String formatNumber(double value) {
    if (value >= 100000) {
      double lakhsValue = value / 100000;
      // Show one decimal place for non-integers like 1.5L
      if (lakhsValue % 1 != 0) {
        return '${lakhsValue.toStringAsFixed(1)}L';
      } else {
        return '${lakhsValue.toStringAsFixed(0)}L';
      }
    } else if (value >= 10000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toInt().toString();
    }
  }

  // Future<void> _initData(
  //     String customerId, DateTime startDate, DateTime endDate) async {
  //   // Call async methods
  //   await shareStatementData(customerId, startDate, endDate);
  // }

  @override
  void initState() {
    customerData();
    _getCountryCode();
    _analyticsService.trackPage('CustomerReportPage');
    customersMonthlyTransactionData();
    customersYearlyTransactionData();

    int currentYear = DateTime.now().year;
    for (int i = 0; i < 5; i++) {
      years.add((currentYear - i).toString());
    }
    String? customerId;
    DateTime? startDate;
    DateTime? endDate;
    setState(() {
      _customerData = widget.customerData;
      _organizationName = _customerData['organisationName'];
      customerId = _customerData['_id'];
      startDate = DateTime.now()
          .subtract(const Duration(days: 30)); // Example: 30 days back
      endDate = DateTime.now();
    });
    // if (customerId != null && startDate != null && endDate != null) {
    //   _initData(customerId!, startDate!, endDate!);
    // }
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
                          margin: EdgeInsets.only(top: 10, bottom: 5),
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
                          margin: EdgeInsets.only(top: 20, bottom: 5),
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
                              vertical: 20, horizontal: 15),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: values.isNotEmpty
                                  ? values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble()
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
                                            width: 20, // Increased width
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
                              vertical: 20, horizontal: 15),
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
                            _showDateRangeDialog();
                          },
                          child: Text(translation(context)!.shareStatement),
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
