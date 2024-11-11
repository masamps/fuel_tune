import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bem-vindo à página Settings!'),
          SizedBox(height: 10),
          Text('Aqui você pode ajustar as configurações.'),
        ],
      ),
    );
  }
}
