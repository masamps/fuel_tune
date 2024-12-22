import 'package:flutter/material.dart';

class AppleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AppleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blue, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(label),
    );
  }
}
