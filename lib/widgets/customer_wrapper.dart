import 'package:flutter/material.dart';

import '../Pages/App Pages/home_page_card_info_page.dart';
import '../models/Transaction_model.dart';

class CustomerDataWrapper extends StatelessWidget {
  final Map<String, dynamic> customerData;
  final List<Transaction> todayTransactions;

  const CustomerDataWrapper({
    super.key,
    required this.customerData,
    required this.todayTransactions,
  });
  void updateImageUrls(List<String> newImageUrls) {
    // Update the state or perform other actions
  }

  @override
  Widget build(BuildContext context) {
    final customer = Customer.fromMap(customerData);

    return DetailedCardPage(
      customerData: customer,
      onUpdateImageUrls: updateImageUrls,
    );
  }
}
// class CustomerDataWrapper extends StatelessWidget {
//   final Map<String, dynamic>? customerData;

//   CustomerDataWrapper({
//     required this.customerData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (customerData == null) {
//       // Handle the case when data is null
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Error'),
//         ),
//         body: Center(
//           child: Text('No customer data available.'),
//         ),
//       );
//     }

//     // Access data using customerData
//     final String? date = customerData?['date'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Customer Details'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Text('Date: $date'), // Access data here
//             // Display other customer data
//           ],
//         ),
//       ),
//     );
//   }
// }
