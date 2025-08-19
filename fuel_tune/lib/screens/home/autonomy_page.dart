import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/input_field_widget.dart';
import 'package:fuel_tune/services/calculo_autonomia.dart';

class AutonomyPage extends StatefulWidget {
  const AutonomyPage({super.key});

  @override
  _AutonomyPageState createState() => _AutonomyPageState();
}

class _AutonomyPageState extends State<AutonomyPage> {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  final FocusNode litrosFocusNode = FocusNode();
  double mediaConsumo = 0.0;

  @override
  void initState() {
    super.initState();
    litrosFocusNode.addListener(_onLitrosFocusChange);
  }

  @override
  void dispose() {
    litrosFocusNode.removeListener(_onLitrosFocusChange);
    super.dispose();
  }

  void _onLitrosFocusChange() {
    if (!litrosFocusNode.hasFocus) {
      _calcularMedia();
    }
  }

  void _calcularMedia() {
    final double kmPercorridos = double.tryParse(kmController.text) ?? 0.0;
    final double litrosAbastecidos =
        double.tryParse(litrosController.text) ?? 0.0;

    setState(() {
      mediaConsumo = calcularMedia(kmPercorridos, litrosAbastecidos);
    });
  }

  Future<void> _salvarDados() async {
    if (kmController.text.isEmpty || litrosController.text.isEmpty) {
      _exibirMensagemErro();
      return;
    }

    double kmPercorrido = double.tryParse(kmController.text) ?? 0.0;
    double litrosAbastecidos = double.tryParse(litrosController.text) ?? 0.0;
    String observacao = observacaoController.text;

    Map<String, dynamic> novoRegistro = {
      'km_percorrido': kmPercorrido,
      'litros': litrosAbastecidos,
      'media_consumo': mediaConsumo,
      'observacao': observacao,
      'dt_abastecimento': DateTime.now().toIso8601String(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? registrosJson = prefs.getString('abastecimentos');

      List<Map<String, dynamic>> registros = registrosJson != null
          ? List<Map<String, dynamic>>.from(json.decode(registrosJson))
          : [];

      registros.add(novoRegistro);

      await prefs.setString('abastecimentos', json.encode(registros));

      _exibirMensagemSucesso();
    } catch (e) {
      print('Erro ao salvar os dados: $e');
    }
  }

  void _exibirMensagemSucesso() {
    const snackBar = SnackBar(
      content:
      Text('Os dados de quilometragem e litros foram salvos com sucesso.'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _limparCampos();
  }

  void _exibirMensagemErro() {
    const snackBar = SnackBar(
      content: Text(
          'Por favor, preencha ambos os campos de quilometragem e litros.'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _limparCampos() {
    setState(() {
      kmController.clear();
      litrosController.clear();
      observacaoController.clear();
      mediaConsumo = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0, right: 18, left: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite os dados abaixo para calcular a média de consumo do seu carro:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InputFieldWidget(
              controller: kmController,
              labelText: 'Quilômetros Percorridos',
              hintText: 'Ex: 200',
            ),
            const SizedBox(height: 20),
            InputFieldWidget(
              controller: litrosController,
              labelText: 'Litros Abastecidos',
              hintText: 'Ex: 21.50',
              focusNode: litrosFocusNode,
            ),
            const SizedBox(height: 30),
            InputFieldWidget(
              controller: observacaoController,
              labelText: 'Observação (opcional)',
              hintText: 'Abastecido dia 01/01/2023',
            ),
            const SizedBox(height: 30),
            Text(
              'Média de Consumo: ${mediaConsumo.toStringAsFixed(2)} km/L',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            AppleButton(
              label: 'Salvar',
              onPressed: _salvarDados,
            ),
          ],
        ),
      ),
    );
  }
}
