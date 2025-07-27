// flutter_app/lib/models/shap_explanation_model.dart
class FeatureContribution {
  final double shapValue;
  final double featureValue;
  final String impact;

  FeatureContribution({
    required this.shapValue,
    required this.featureValue,
    required this.impact,
  });

  factory FeatureContribution.fromJson(Map<String, dynamic> json) {
    return FeatureContribution(
      shapValue: json['shap_value'].toDouble(),
      featureValue: json['feature_value'].toDouble(),
      impact: json['impact'],
    );
  }
  
  bool get increasesRisk => impact == 'increases_risk';
}

class ShapExplanation {
  final String applicationId;
  final Map<String, FeatureContribution> topFeatures;
  final double baseValue;
  final double predictionValue;
  final double totalShapContribution;
  final List<String> readableExplanation;

  ShapExplanation({
    required this.applicationId,
    required this.topFeatures,
    required this.baseValue,
    required this.predictionValue,
    required this.totalShapContribution,
    required this.readableExplanation,
  });

  factory ShapExplanation.fromJson(Map<String, dynamic> json) {
    Map<String, FeatureContribution> features = {};
    
    if (json['top_features'] != null) {
      json['top_features'].forEach((key, value) {
        features[key] = FeatureContribution.fromJson(value);
      });
    }
    
    return ShapExplanation(
      applicationId: json['application_id'],
      topFeatures: features,
      baseValue: json['base_value'].toDouble(),
      predictionValue: json['prediction_value'].toDouble(),
      totalShapContribution: json['total_shap_contribution'].toDouble(),
      readableExplanation: List<String>.from(json['readable_explanation'] ?? []),
    );
  }
}
