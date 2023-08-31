import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RefreshWidget extends StatefulWidget {
  final Widget child;
  final Future Function() onRefresh;
  Color color;

  RefreshWidget(
      {required this.onRefresh, required this.child, required this.color});

  @override
  State<RefreshWidget> createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  @override
  Widget build(BuildContext context) => RefreshIndicator(
        child: widget.child,
        onRefresh: widget.onRefresh,
        color: widget.color,
      );
}
