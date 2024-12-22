import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _sizeMessage = "Calculando...";

  @override
  void initState() {
    super.initState();
    _calcularTamanhoMemoria();
  }

  Future<void> _limparDados() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos os dados foram apagados!')),
    );
    _calcularTamanhoMemoria();
  }

  Future<void> _calcularTamanhoMemoria() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int totalSize = 0;

    final Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      final dynamic value = prefs.get(key);

      if (value is String) {
        totalSize += value.length;
      } else if (value is int) {
        totalSize += 4;
      } else if (value is double) {
        totalSize += 8;
      } else if (value is bool) {
        totalSize += 1;
      } else if (value is List<String>) {
        totalSize += value.fold(0, (sum, item) => sum + item.length);
      }
    }

    setState(() {
      _sizeMessage = "Tamanho estimado dos dados: $totalSize bytes";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Limpar dados salvos'),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                _limparDados();
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _sizeMessage,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
