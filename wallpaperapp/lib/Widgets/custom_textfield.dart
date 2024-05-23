import 'package:flutter/material.dart';

import '../Utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData iconData;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? initialValue;
  final bool? enabled;
  final TextInputType? isNumber;

  const CustomTextField(
      {super.key, required this.hint, required this.iconData, required this.controller, this.initialValue, this.enabled, this.isNumber, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        style: const TextStyle(
          color: Colors.white,
        ),
        controller: controller,
        initialValue: initialValue,
        enabled: enabled,
        onChanged: onChanged,
        keyboardType: isNumber,
        cursorColor: const Color(0xFFA26FFD),
        decoration: InputDecoration(
          prefixIcon: Icon(
            iconData,
            color: const Color(0xFFBDBDBD),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.purpleAccent),
            borderRadius: BorderRadius.circular(15),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          fillColor: Color(int.parse(greyText)),
          filled: true,
        ),
      ),
    );
  }
}
