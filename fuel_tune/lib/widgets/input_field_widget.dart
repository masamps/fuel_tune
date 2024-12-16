import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final VoidCallback? onEditingComplete;

  const InputFieldWidget({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
      ),
    );
  }
}
