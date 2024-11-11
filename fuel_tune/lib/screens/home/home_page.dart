import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'home_page/litro_info.dart';
import 'home_page/valor_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLitro = true; // Estado inicial (true para Litro, false para Valor)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toggle Switch no topo
            AnimatedToggleSwitch<bool>.dual(
              current: isLitro,
              first: true,
              second: false,
              onChanged: (value) {
                setState(() {
                  isLitro = value;
                });
              },
              iconBuilder: (value) => value
                  ? Icon(Icons.local_gas_station, color: Colors.white)
                  : Icon(Icons.attach_money, color: Colors.white),
              textBuilder: (value) => value
                  ? Center(child: Text('Litro', style: TextStyle(color: Colors.blue)))
                  : Center(child: Text('Valor', style: TextStyle(color: Colors.blue))),
            ),
            SizedBox(height: 20),

            // Exibe o widget LitroInfo se isLitro for true
            Expanded(
              child: isLitro
                  ? LitroInfo()
                  : ValorInfo(),
            ),
          ],
        ),
      ),
    );
  }
}