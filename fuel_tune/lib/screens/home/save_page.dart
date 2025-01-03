import 'package:flutter/material.dart';
import 'package:fuel_tune/services/database_helper.dart';
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

  /// Carrega os dados do banco de dados SQLite
  Future<void> _carregarDados() async {
    try {
      List<Map<String, dynamic>> lista = await DatabaseHelper.instance.queryAll('abastecimentos');
      setState(() {
        registros = lista;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  /// Deleta um registro do banco de dados com base no ID
  Future<void> _deletarRegistro(int id) async {
    try {
      await DatabaseHelper.instance.delete('abastecimentos', 'id = ?', [id]);
      await _carregarDados();
    } catch (e) {
      print('Erro ao deletar registro: $e');
    }
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
            key: Key(registro['id'].toString()), // Usar o ID como chave
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              final int id = registro['id']; // Obter o ID do registro
              _deletarRegistro(id); // Deletar com base no ID
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
