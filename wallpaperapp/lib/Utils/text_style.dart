import 'package:flutter/material.dart';

import 'app_colors.dart';

const bold = 'Bold';
const regular = 'Regular';
const light = 'Light';
const medium = 'Medium';

textStyle({family = regular, double? size = 14, color = whiteColor}) {
  return TextStyle(fontSize: size, color: color, fontFamily: family);
}

