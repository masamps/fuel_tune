import 'package:flutter/material.dart';

class ValorInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações sobre Litros',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Aqui estão as informações específicas para a opção Litro.'),
        SizedBox(height: 8),
        Text('Exemplo 1: Quantidade de litros usados.'),
        Text('Exemplo 2: Média de litros por semana.'),
        // Adicione mais informações ou componentes aqui conforme necessário
      ],
    );
  }
}
