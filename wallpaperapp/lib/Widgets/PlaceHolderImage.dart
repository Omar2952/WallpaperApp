import 'dart:math';

import 'package:flutter/material.dart';

class PlaceholderImageWidget extends StatelessWidget {
  const PlaceholderImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      "assets/images/noimage.png",
      "assets/images/noimage2.png",
      "assets/images/noimage3.png",
      "assets/images/noimage4.png",
    ];

    final randomIndex = Random().nextInt(imagePaths.length);
    final randomImagePath = imagePaths[randomIndex];

    double randomHeight() {
      double minHeight = 280.0;
      double maxHeight = 350.0;
      double randomHeight = minHeight + Random().nextDouble() * (maxHeight - minHeight);
      return randomHeight;
    }

    return Container(
      color: Colors.grey[200],
      child: Image.asset(
        randomImagePath,
        height: randomHeight(),
      ),
    );
  }
}