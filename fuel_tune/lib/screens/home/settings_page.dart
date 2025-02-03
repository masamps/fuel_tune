import 'dart:convert';
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
    _calcularTamanhoSharedPreferences();
  }

  Future<void> _calcularTamanhoSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    int totalSize = 0;

    prefs.getKeys().forEach((key) {
      final value = prefs.get(key);
      if (value != null) {
        totalSize += utf8.encode(value.toString()).length;
      }
    });

    setState(() {
      _sizeMessage = "Uso de armazenamento: ${_formatarTamanho(totalSize)}";
    });
  }

  String _formatarTamanho(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }

  Future<void> _limparSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _sizeMessage = "Uso de armazenamento: 0 B";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos foram limpos com sucesso.')),
    );
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
              onTap: _limparSharedPreferences,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _sizeMessage,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
