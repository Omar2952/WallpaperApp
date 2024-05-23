import 'package:flutter/material.dart';

import '../Utils/app_colors.dart';
import '../Utils/text_style.dart';


class ContainerButton extends StatelessWidget {
  final void Function()? onTap;
  final Color? buttonColor;
  final String text;
  final Color? textColor;
  const ContainerButton({super.key, this.onTap, required this.text, this.buttonColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: buttonColor ?? sliderColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: textStyle(size: 18,family: bold, color: textColor ?? whiteColor)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
