import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputNewLocationPage extends StatelessWidget {
  const InputNewLocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new location"),
        centerTitle: true,
      ),
    );
  }
}
