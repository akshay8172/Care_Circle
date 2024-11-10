import 'package:flutter/material.dart';
import 'ipset.dart';
void main(){
  runApp(const care_circle());
}

class care_circle extends StatefulWidget {
  const care_circle({super.key});

  @override
  State<care_circle> createState() => _care_circleState();
}

class _care_circleState extends State<care_circle> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const IPSet(),
    );
  }
}

