import 'package:flutter/material.dart';

extension ColorExtension on ColorScheme {
  Color get onImage =>
      brightness == Brightness.light ? inversePrimary : onPrimaryContainer;
}
