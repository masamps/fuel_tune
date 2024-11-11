import 'package:flutter/material.dart';
import 'package:fuel_tune/models/tipo_combustivel.dart';
import 'package:fuel_tune/services/calculo_combustivel.dart';

class LitroInfo extends StatefulWidget {
  @override
  _LitroInfoState createState() => _LitroInfoState();
}

class _LitroInfoState extends State<LitroInfo> {
  String? selectedCombustivel;
  TextEditingController litroController = TextEditingController();
  double alcool = 0.0;
  double gasolina = 0.0;

  @override
  void initState() {
    super.initState();
    selectedCombustivel = getCombustivelValues().last;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Selecione o Tipo de Combustível',
            style: TextStyle(fontSize: 18),
          ),
        ),
        Center(
          child: DropdownButton<String>(
            value: selectedCombustivel,
            items: getCombustivelValues().map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCombustivel = newValue;
              });
            },
            hint: const Text("Selecione o Combustível"),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Quantos litros quer abastecer?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: litroController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 10',
            labelText: 'Litros',
            hintStyle: TextStyle(color: Colors.grey),
            labelStyle: TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          onEditingComplete: () {
            double litros = double.tryParse(litroController.text) ?? 0.0;

            var resultado = CalculoCombustivel.calcularProporcao(litros, selectedCombustivel!);

            setState(() {
              alcool = resultado['alcool']!;
              gasolina = resultado['gasolina']!;
            });
          },
        ),

        const SizedBox(height: 20),
        Text(
          'Álcool: ${alcool.toStringAsFixed(2)} litros',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Gasolina: ${gasolina.toStringAsFixed(2)} litros',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
