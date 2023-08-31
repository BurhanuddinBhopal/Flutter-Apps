import 'package:flutter/material.dart';

import '../../models/Transaction_model.dart';

class ParentWidget extends StatefulWidget {
  final List<Customer> customerData;

  ParentWidget({required this.customerData});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
