import 'package:flutter/material.dart';

class SavePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bem-vindo à página Save!'),
          SizedBox(height: 10),
          Text('Aqui você pode salvar informações importantes.'),
        ],
      ),
    );
  }
}
