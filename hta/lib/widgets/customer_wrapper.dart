import 'package:flutter/material.dart';

import '../Pages/App Pages/home_page_card_info_page.dart';
import '../models/Transaction_model.dart';

class CustomerDataWrapper extends StatelessWidget {
  final Map<String, dynamic> customerData;

  CustomerDataWrapper({required this.customerData});

  @override
  Widget build(BuildContext context) {
    final customer = Customer.fromMap(customerData);

    return DetailedCardPage(customerData: customer);
  }
}
