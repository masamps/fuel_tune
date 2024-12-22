import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? listaString = prefs.getString('lista_abastecimentos');
    if (listaString != null) {
      List<dynamic> lista = jsonDecode(listaString);
      setState(() {
        registros = lista.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _deletarRegistro(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    registros.removeAt(index);
    await prefs.setString('lista_abastecimentos', jsonEncode(registros));
    setState(() {});
  }

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
                      'KM: ${registro['km_percorrido']} - Litros: ${registro['litros_abastecidos']}',
                    ),
                    subtitle: Text(
                      'Data: ${_formatarData(registro['data_hora'])} - Média: ${registro['media_consumo']}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
