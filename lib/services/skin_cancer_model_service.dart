import 'dart:io';
import 'package:flutter/material.dart';
import 'onnx_model_service.dart';

class SkinCancerModelService {
  static bool _modelLoaded = false;

  /// Initialize the ONNX model
  static Future<void> loadModel() async {
    if (_modelLoaded) return;
    
    try {
      // Call the ONNX model service's loadModel method
      await OnnxModelService.loadModel();
      _modelLoaded = true;
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  /// Run the model on the provided image and return the results
  static Future<List<Map<String, dynamic>>> classifyImage(String imagePath) async {
    if (!_modelLoaded) {
      await loadModel();
    }

    try {
      // Use the ONNX model service to classify the image
      return await OnnxModelService.classifyImage(imagePath);
    } catch (e) {
      debugPrint('Error classifying image: $e');
      return [];
    }
  }

  /// Clean up resources when done
  static Future<void> disposeModel() async {
    if (_modelLoaded) {
      // No explicit cleanup needed for ONNX runtime as it's handled internally
      _modelLoaded = false;
    }
  }

  /// Get a user-friendly diagnosis result based on the highest confidence prediction
  static Map<String, dynamic> getDiagnosisResult(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return {
        'diagnosis': 'Unknown',
        'confidence': 0.0,
        'risk_level': 'Unknown',
        'description': 'Could not determine a diagnosis. Please try again with a clearer image.',
      };
    }

    // Sort predictions by confidence (highest first)
    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    // Get the highest confidence prediction
    final topPrediction = predictions.first;
    final String label = topPrediction['label'];
    final double confidence = topPrediction['confidence'];
    
    // Determine risk level based on confidence and type
    String riskLevel = 'Low';
    if (label.contains('Melanoma') || label.contains('Squamous Cell Carcinoma')) {
      riskLevel = confidence > 0.7 ? 'High' : 'Moderate';
    } else if (label.contains('Basal Cell Carcinoma')) {
      riskLevel = confidence > 0.7 ? 'Moderate' : 'Low';
    } else if (confidence > 0.8) {
      riskLevel = 'Low';
    }
    
    // Create a description based on the diagnosis
    String description = 'Based on our analysis, this appears to be $label with ${(confidence * 100).toStringAsFixed(1)}% confidence.';
    
    if (riskLevel == 'High') {
      description += ' We recommend consulting a dermatologist as soon as possible.';
    } else if (riskLevel == 'Moderate') {
      description += ' We recommend scheduling a check-up with a dermatologist.';
    } else {
      description += ' Regular skin checks are still recommended.';
    }
    
    return {
      'diagnosis': label,
      'confidence': confidence,
      'risk_level': riskLevel,
      'description': description,
    };
  }
}