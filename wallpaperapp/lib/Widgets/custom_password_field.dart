import 'package:flutter/material.dart';

import '../Utils/app_colors.dart';


class CustomPasswordField extends StatefulWidget {
  bool obscureText;
  final String hint;
  final IconData iconData;
  final TextEditingController controller;
  CustomPasswordField({super.key, this.obscureText = true, required this.hint, required this.iconData, required this.controller});

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        obscureText: widget.obscureText,
        style: const TextStyle(
          color: Colors.white,
        ),
        controller: widget.controller,
        cursorColor: const Color(0xFFA26FFD),
        decoration: InputDecoration(
          prefixIcon:  Icon(
            widget.iconData,
            color: const Color(0xFFBDBDBD),
          ),
          suffixIcon:  GestureDetector(
            onTap: (){
              setState(() {
                widget.obscureText = !widget.obscureText;
              });
            },
            child: widget.obscureText
                ? const Icon(
              Icons.visibility_off,
              color: Colors.grey,
            )
                : const Icon(
              Icons.visibility,
              color:  Color(0xFFA26FFD),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
            const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.purpleAccent),
            borderRadius: BorderRadius.circular(15),
          ),
          hintText: widget.hint,
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
