import 'package:flutter/material.dart';
import 'package:maarif_app/pages/SpinningLogo.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SpinningLogo(),
        ));
  }
}
