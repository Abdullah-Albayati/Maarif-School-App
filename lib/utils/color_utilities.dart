import 'package:flutter/material.dart';

Color avatarBackgroundColor(String input) {
  return Color((input.hashCode & 0xFFFFFF).toInt()).withOpacity(1.0);
}
