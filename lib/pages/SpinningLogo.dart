import 'dart:math';

import 'package:flutter/material.dart';

class SpinningLogo extends StatefulWidget {
  @override
  _SpinningLogoState createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Adjusts the speed of the spin.
      vsync: this,
    );

    // The sequence of actions: spin for a duration, then pause, then spin again.
    _controller.forward().whenComplete(() {
      Future.delayed(Duration(milliseconds: 500), () {
        // 500ms pause (can be adjusted).
        if (mounted) {
          _controller.reverse().whenComplete(() {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) _controller.forward();
            });
          });
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Image.asset('assets/logo.png', width: 75, height: 75),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
