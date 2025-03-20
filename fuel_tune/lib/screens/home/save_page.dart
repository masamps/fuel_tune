import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? registrosJson = prefs.getString('abastecimentos');
    if (registrosJson != null) {
      setState(() {
        registros = List<Map<String, dynamic>>.from(json.decode(registrosJson));
      });
    }
  }

  /// Salva os dados no SharedPreferences
  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('abastecimentos', json.encode(registros));
  }

  /// Deleta um registro com base no índice
  Future<void> _deletarRegistro(int index) async {
    setState(() {
      registros.removeAt(index);
    });
    await _salvarDados();
  }

  /// Formata a data para exibição no formato dd/MM/yyyy HH:mm
  String _formatarData(String dataHora) {
    DateTime data = DateTime.parse(dataHora);
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: registros.isEmpty
          ? const Center(child: Text('Nenhum registro salvo.'))
          : ListView.builder(
        itemCount: registros.length,
        itemBuilder: (context, index) {
          final registro = registros[index];
          return Dismissible(
            key: Key(index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deletarRegistro(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro deletado')),
              );
            },
            child: ListTile(
              title: Text(
                'KM: ${registro['km_percorrido']} - Litros: ${registro['litros']}',
              ),
              subtitle: Text(
                'Data: ${_formatarData(registro['dt_abastecimento'])} - Média: ${registro['media_consumo'] ?? 'N/A'}',
              ),
            ),
          );
        },
      ),
    );
  }
}
