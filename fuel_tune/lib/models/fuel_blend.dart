class FuelBlendOption {
  const FuelBlendOption({
    required this.id,
    required this.label,
    this.ethanolPercentage,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final int? ethanolPercentage;
  final bool isCustom;

  double resolveEthanolFraction(double? customPercentage) {
    final percentage =
        isCustom ? customPercentage : ethanolPercentage?.toDouble();

    if (percentage == null || percentage < 0 || percentage > 100) {
      throw ArgumentError('Informe um percentual de etanol entre 0 e 100.');
    }

    return percentage / 100;
  }
}

const List<FuelBlendOption> fuelBlendOptions = [
  FuelBlendOption(id: 'e50', label: 'E50', ethanolPercentage: 50),
  FuelBlendOption(id: 'e75', label: 'E75', ethanolPercentage: 75),
  FuelBlendOption(id: 'e85', label: 'E85', ethanolPercentage: 85),
  FuelBlendOption(id: 'e100', label: 'E100', ethanolPercentage: 100),
  FuelBlendOption(id: 'custom', label: 'Personalizada', isCustom: true),
];

FuelBlendOption fuelBlendById(String id) {
  return fuelBlendOptions.firstWhere(
    (option) => option.id == id,
    orElse: () => fuelBlendOptions[1],
  );
}
