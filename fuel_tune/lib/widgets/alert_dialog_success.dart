import 'package:flutter/material.dart';

class AlertDialogSuccess extends StatelessWidget {
  final String message;
  final VoidCallback onOkPressed;

  const AlertDialogSuccess({
    Key? key,
    required this.message,
    required this.onOkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: const Text(
        'Dados Salvos!',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            onOkPressed();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
