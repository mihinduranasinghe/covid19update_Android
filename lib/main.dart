import 'package:flutter/material.dart';
import 'package:covid19/stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID-19 Update',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('COVID-19 Update'),
        ),
        body: StatsPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
