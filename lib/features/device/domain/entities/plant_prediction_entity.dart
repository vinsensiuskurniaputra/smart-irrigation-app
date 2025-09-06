class PlantPredictionEntity {
  final double confidence;
  final int labelIndex;
  final String prediction;

  PlantPredictionEntity({
    required this.confidence,
    required this.labelIndex,
    required this.prediction,
  }) {
    // Validate label index is in valid range (0-4)
    if (labelIndex < 0 || labelIndex > 4) {
      throw ArgumentError('Label index must be between 0 and 4, got: $labelIndex');
    }
  }

  bool get isConfident => confidence >= 0.7;
  bool get isValidLabelIndex => labelIndex >= 0 && labelIndex <= 4;
}
