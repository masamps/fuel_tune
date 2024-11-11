class CalculoCombustivel {
  static Map<String, double> calcularProporcao(double litros, String tipoCombustivel) {
    double percentualAlcool;

    switch (tipoCombustivel) {
      case 'E5':
        percentualAlcool = 0.05;
        break;
      case 'E10':
        percentualAlcool = 0.10;
        break;
      case 'E20':
        percentualAlcool = 0.20;
        break;
      case 'E25':
        percentualAlcool = 0.25;
        break;
      case 'E70':
        percentualAlcool = 0.70;
        break;
      case 'E75':
        percentualAlcool = 0.75;
        break;
      case 'E85':
        percentualAlcool = 0.85;
        break;
      case 'E95':
        percentualAlcool = 0.95;
        break;
      case 'E100':
        percentualAlcool = 1.0;
        break;
      case 'Gasolina':
        percentualAlcool = 0.0;
        break;
      case 'Alcool':
        percentualAlcool = 1.0;
        break;
      default:
        percentualAlcool = 0.0;
        break;
    }

    double quantidadeAlcool = litros * percentualAlcool;
    double quantidadeGasolina = litros - quantidadeAlcool;

    return {
      'alcool': quantidadeAlcool,
      'gasolina': quantidadeGasolina,
    };
  }
}
