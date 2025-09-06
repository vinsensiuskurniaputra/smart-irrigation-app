class PlantPredictionModel {
  final double confidence;
  final int labelIndex;
  final String prediction;

  PlantPredictionModel({
    required this.confidence,
    required this.labelIndex,
    required this.prediction,
  });

  factory PlantPredictionModel.fromJson(Map<String, dynamic> json) {
    return PlantPredictionModel(
      confidence: (json['confidence'] as num).toDouble(),
      labelIndex: json['label_index'] as int,
      prediction: json['prediction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'label_index': labelIndex,
      'prediction': prediction,
    };
  }
}
