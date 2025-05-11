// 📄 image_preview_page.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'services/firebase_storage_service.dart';
import 'services/onnx_model_service.dart';
import 'diagnosis_result_page.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  const ImagePreviewPage({super.key, required this.imagePath});

  // 🔁 Méthode pour télécharger l'image vers Firebase Storage
  Future<void> uploadImageToFirestore(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Upload image to Firebase Storage
      final downloadUrl = await FirebaseStorageService.uploadImage(imagePath);
      
      // Close loading indicator
      Navigator.pop(context);
      
      if (downloadUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image enregistrée dans Firebase Storage ✅")),
        );
      } else {
        throw Exception("Failed to get download URL");
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      debugPrint("Erreur Firebase Storage : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur d'enregistrement dans Firebase Storage")),
      );
    }
  }
  
  // 🔍 Méthode pour analyser l'image avec le modèle ONNX
  Future<void> analyzeImage(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Load the model if not already loaded
      await OnnxModelService.loadModel();
      
      // Run the model on the image
      final predictions = await OnnxModelService.classifyImage(imagePath);
      
      // Get the diagnosis result - we'll need to implement this in OnnxModelService or handle it here
      final diagnosisResult = _getDiagnosisResult(predictions);
      
      // Close loading indicator
      Navigator.pop(context);
      
      // Navigate to the diagnosis result page
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosisResultPage(
            imagePath: imagePath,
            diagnosisResult: diagnosisResult,
            predictions: predictions,
          ),
        ),
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      debugPrint("Erreur d'analyse d'image : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'analyse de l'image")),
      );
    }
  }

  // Helper method to get diagnosis result from predictions
  Map<String, dynamic> _getDiagnosisResult(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return {
        'diagnosis': 'Unknown',
        'confidence': 0.0,
        'description': 'No prediction could be made. Please try again with a clearer image.',
        'recommendation': 'Take another photo with better lighting and focus.'
      };
    }

    // Sort predictions by confidence (highest first)
    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    // Get the highest confidence prediction
    final topPrediction = predictions.first;
    final String label = topPrediction['label'] as String;
    final double confidence = topPrediction['confidence'] as double;
    
    // Format the diagnosis result
    return {
      'diagnosis': label,
      'confidence': confidence,
      'description': _getDescriptionForDiagnosis(label),
      'recommendation': _getRecommendationForDiagnosis(label, confidence)
    };
  }

  // Helper method to get description for a diagnosis
  String _getDescriptionForDiagnosis(String diagnosis) {
    // These descriptions should be reviewed by medical professionals
    final descriptions = {
      'melanoma': 'Melanoma is a serious form of skin cancer that develops in the cells (melanocytes) that produce melanin.',
      'benign': 'This appears to be a benign (non-cancerous) skin lesion.',
      // Add more descriptions for other classes as needed
    };
    
    return descriptions[diagnosis.toLowerCase()] ?? 
      'This is classified as $diagnosis. Please consult with a dermatologist for proper evaluation.';
  }

  // Helper method to get recommendation based on diagnosis and confidence
  String _getRecommendationForDiagnosis(String diagnosis, double confidence) {
    if (confidence < 0.7) {
      return 'The confidence level is low. We strongly recommend consulting a dermatologist for proper evaluation.';
    }
    
    if (diagnosis.toLowerCase() == 'melanoma' || diagnosis.toLowerCase().contains('malignant')) {
      return 'Please consult with a dermatologist as soon as possible for proper evaluation and treatment options.';
    }
    
    return 'For peace of mind, consider having this checked by a dermatologist during your next regular skin examination.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview")),
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.cloud_upload,
                      color: Colors.blue, size: 36),
                  onPressed: () => uploadImageToFirestore(context),
                  tooltip: 'Valider et enregistrer',
                ),
                ElevatedButton(
                  onPressed: () => analyzeImage(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Start Diagnosis",
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
