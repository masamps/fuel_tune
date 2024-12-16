import 'package:flutter/material.dart';
import 'package:fuel_tune/models/tipo_combustivel.dart';
import 'package:fuel_tune/services/calculo_combustivel.dart';
import 'package:fuel_tune/widgets/input_field_widget.dart';

class ValorInfo extends StatefulWidget {
  @override
  State<ValorInfo> createState() => _ValorInfoState();
}

class _ValorInfoState extends State<ValorInfo> {
  String? selectedCombustivel;
  TextEditingController litroController = TextEditingController();
  TextEditingController precoGasolinaController = TextEditingController();
  TextEditingController precoAlcoolController = TextEditingController();
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
          padding: EdgeInsets.only(top: 20, bottom: 20),
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
        InputFieldWidget(
          controller: litroController,
          labelText: 'Quanto em R\$ você vai abastecer?',
          hintText: 'Ex: 50',
        ),
        const SizedBox(height: 20),
        InputFieldWidget(
          controller: precoGasolinaController,
          labelText: 'Preço da Gasolina (R\$)',
          hintText: 'Ex: 5.79',
        ),
        const SizedBox(height: 20),
        InputFieldWidget(
          controller: precoAlcoolController,
          labelText: 'Preço do Álcool (R\$)',
          hintText: 'Ex: 4.29',
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _calcular,
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.blue, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(fontSize: 20),
            foregroundColor: Colors.black,
          ),
          child: const Text('Calcular'),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            const Text(
              'Álcool:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${alcool.toStringAsFixed(2)} L',
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const Text(
          'Gasolina:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${gasolina.toStringAsFixed(2)} L',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _calcular() {
    double litros = double.tryParse(litroController.text) ?? 0.0;
    double precoGasolina = double.tryParse(precoGasolinaController.text) ?? 0.0;
    double precoAlcool = double.tryParse(precoAlcoolController.text) ?? 0.0;

    if (litros > 0 && precoGasolina > 0 && precoAlcool > 0) {
      var resultado = CalculoCombustivelValor.calcularProporcao(
        litros,
        precoGasolina,
        precoAlcool,
        selectedCombustivel!,
      );

      setState(() {
        alcool = resultado['alcool']!;
        gasolina = resultado['gasolina']!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira todos os valores corretamente.'),
        ),
      );
    }
  }
}
