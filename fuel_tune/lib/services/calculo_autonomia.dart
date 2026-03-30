double calculateAverageConsumption(double distanceKm, double litersFilled) {
  if (litersFilled <= 0) {
    return 0.0;
  }

  return distanceKm / litersFilled;
}
