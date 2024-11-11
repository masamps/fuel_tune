enum Combustivel {
  E5,
  E10,
  E20,
  E25,
  E70,
  E75,
  E85,
  E95,
  E100,
  Alcool,
  Gasolina,
}

List<String> getCombustivelValues() {
  return Combustivel.values.map((e) => e.toString().split('.').last).toList();
}