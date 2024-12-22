import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'mixture_page/litro_info.dart';
import 'mixture_page/valor_info.dart';

class MixturePage extends StatefulWidget {
  const MixturePage({super.key});

  @override
  _MixturePageState createState() => _MixturePageState();
}

class _MixturePageState extends State<MixturePage> {
  bool isLitro = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, right: 18, left: 18),
        child: Column(
          children: [
            AnimatedToggleSwitch<bool>.dual(
              current: isLitro,
              first: true,
              second: false,
              onChanged: (value) {
                setState(() {
                  isLitro = value;
                });
              },
              style: const ToggleStyle(
                indicatorColor: Colors.blue,
                borderColor: Colors.blue,
              ),
              iconBuilder: (value) => value
                  ? const Icon(Icons.local_gas_station, color: Colors.white)
                  : const Icon(Icons.attach_money, color: Colors.white),
              textBuilder: (value) => value
                  ? const Center(
                      child:
                          Text('Litro', style: TextStyle(color: Colors.black)))
                  : const Center(
                      child:
                          Text('Valor', style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLitro ? const LitroInfo() : const ValorInfo(),
            ),
          ],
        ),
      ),
    );
  }
}
