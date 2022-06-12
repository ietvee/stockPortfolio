import 'package:flutter/material.dart';
import 'package:stock_portfolio/pages/portfolio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Portfolio(title: "My Portfolio",)
    );
  }
}