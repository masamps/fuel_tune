class FuelMixResult {
  const FuelMixResult({
    required this.ethanolLiters,
    required this.gasolineLiters,
    this.totalLiters,
  });

  final double ethanolLiters;
  final double gasolineLiters;
  final double? totalLiters;
}

class FuelMixCalculator {
  static FuelMixResult calculateByLiters({
    required double totalLiters,
    required double ethanolFraction,
  }) {
    if (totalLiters <= 0) {
      throw ArgumentError('Informe quantos litros você vai abastecer.');
    }

    final ethanolLiters = totalLiters * ethanolFraction;
    final gasolineLiters = totalLiters - ethanolLiters;

    return FuelMixResult(
      ethanolLiters: ethanolLiters,
      gasolineLiters: gasolineLiters,
      totalLiters: totalLiters,
    );
  }

  static FuelMixResult calculateByValue({
    required double totalAmount,
    required double ethanolPrice,
    required double gasolinePrice,
    required double ethanolFraction,
  }) {
    if (totalAmount <= 0) {
      throw ArgumentError('Informe o valor total do abastecimento.');
    }

    if (ethanolPrice <= 0 || gasolinePrice <= 0) {
      throw ArgumentError('Informe os preços do etanol e da gasolina.');
    }

    final ethanolAmount = totalAmount * ethanolFraction;
    final gasolineAmount = totalAmount - ethanolAmount;
    final ethanolLiters = ethanolAmount / ethanolPrice;
    final gasolineLiters = gasolineAmount / gasolinePrice;

    return FuelMixResult(
      ethanolLiters: ethanolLiters,
      gasolineLiters: gasolineLiters,
      totalLiters: ethanolLiters + gasolineLiters,
    );
  }
}
