double calcularMedia(double kmPercorridos, double litrosAbastecidos) {
  if (litrosAbastecidos > 0) {
    return kmPercorridos / litrosAbastecidos;
  } else {
    return 0.0;
  }
}