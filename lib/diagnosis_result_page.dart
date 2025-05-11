import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/firebase_storage_service.dart';

class DiagnosisResultPage extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic>? diagnosisResult;
  final List<Map<String, dynamic>>? predictions;
  
  const DiagnosisResultPage({
    super.key, 
    required this.imagePath, 
    this.diagnosisResult, 
    this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    // Use the predictions from the model if available, otherwise use sample data
    final Map<String, double> cancerProbabilities = {};
    
    if (predictions != null && predictions!.isNotEmpty) {
      for (var prediction in predictions!) {
        cancerProbabilities[prediction['label']] = prediction['confidence'] * 100;
      }
    } else {
      // Sample data as fallback
      cancerProbabilities.addAll({
        'Actinic Keratosis': 70,
        'Basal Cell Carcinoma': 45,
        'Dermatofibroma': 30,
        'Melanoma': 85,
        'Nevus': 20,
        'Pigmented Benign Keratosis': 15,
        'Seborrheic Keratosis': 40,
        'Squamous Cell Carcinoma': 60,
        'Vascular Lesion': 10,
      });
    }
    
    // Get diagnosis information
    final String diagnosis = diagnosisResult?['diagnosis'] ?? 'Melanoma';
    final double confidence = diagnosisResult?['confidence'] != null 
        ? (diagnosisResult!['confidence'] * 100) 
        : 85.0;
    final String riskLevel = diagnosisResult?['risk_level'] ?? 'High';
    final String description = diagnosisResult?['description'] ?? 
        'Based on our analysis, this appears to be Melanoma with 85.0% confidence. We recommend consulting a dermatologist as soon as possible.';

    return Scaffold(
      appBar: AppBar(title: const Text("Your skin report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Image.file(File(imagePath), height: 220),
            const SizedBox(height: 16),
            const Text("Skin test results",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("AI analysis of skin cancer risk"),
            const SizedBox(height: 20),

            // Save diagnosis to Firebase
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Save Diagnosis to Cloud"),
              onPressed: () async {
                try {
                  final downloadUrl = await FirebaseStorageService.uploadImage(
                    imagePath,
                    diagnosis: diagnosis,
                  );
                  
                  if (downloadUrl != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Diagnosis saved to cloud ✅")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving diagnosis: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description of diagnosis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Score global
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _scoreBox("Score", "90%"),
                _scoreBox("Date", "20 Apr 2025"),
              ],
            ),
            const SizedBox(height: 20),

            // Diagramme circulaire
            const Text("Skin test statistics",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: cancerProbabilities.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      title: '${e.value.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Liste des cancers
            ...cancerProbabilities.entries.map((e) => ListTile(
                  leading: const Icon(Icons.circle, size: 10),
                  title: Text(e.key),
                  trailing: Text("${e.value.toInt()}%"),
                )),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Repeat"),
            )
          ],
        ),
      ),
    );
  }

  Widget _scoreBox(String label, String value) {
    return Container(
      width: 130,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
