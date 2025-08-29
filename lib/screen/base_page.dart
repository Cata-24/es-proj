import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Widget Function(BuildContext) buildChild;

  const BasePage({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.buildChild,
  });

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
          centerTitle: true,
        title: Text(
            widget.title,
            style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            )
        ),
      ),
      body: Container(
        color: widget.backgroundColor,
        child: widget.buildChild(context),
      ),
    );
  }
}
