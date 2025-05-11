import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class OnnxModelService {
  static bool _modelLoaded = false;
  static OrtSession? _session;
  static List<String>? _labels;

  /// Initialize the ONNX model
  static Future<void> loadModel() async {
    if (_modelLoaded) return;
    
    try {
      // Initialize the ONNX runtime
      OrtEnv.instance.init();

      // Load the model file from the assets bundle
      final modelData = await rootBundle.load('DLModel/converted_model.onnx');
      final modelBytes = modelData.buffer.asUint8List();

      // Create an ONNX session from the model bytes
      // Using the correct method fromFile with temporary file approach
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/converted_model.onnx';
      final modelFile = File(tempPath);
      await modelFile.writeAsBytes(modelBytes);
      _session = await OrtSession.fromFile(modelFile, OrtSessionOptions());
      debugPrint('ONNX session created successfully with model size: ${modelBytes.length} bytes');
      debugPrint('ONNX session created successfully');
      
      // Load labels from assets bundle
      try {
        final labelsData = await rootBundle.loadString('DLModel/labels.txt');
        _labels = labelsData.split('\n');
        _labels = _labels!.map((label) => label.trim()).toList();
        _labels!.removeWhere((label) => label.isEmpty);
      } catch (e) {
        debugPrint('Warning: Could not load labels file: $e');
      }
      
      _modelLoaded = true;
      debugPrint('ONNX model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load ONNX model: $e');
    }
  }

  /// Run the model on the provided image and return the results
  static Future<List<Map<String, dynamic>>> classifyImage(String imagePath) async {
    if (!_modelLoaded) {
      await loadModel();
    }

    if (_session == null) {
      debugPrint('Error: ONNX session not initialized');
      return [];
    }

    try {
      // Preprocess the image (resize, normalize, etc.)
      final File imageFile = File(imagePath);
      final preprocessedData = await _preprocessImage(imageFile);
      
      // Create input tensor from preprocessed data
      final inputShape = [1, 3, 75, 100]; // [batch, channels, height, width]
      
      // Create input tensor directly using OrtValueTensor instead of OnnxCpuSession
      final inputTensor = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(preprocessedData),
        inputShape,
      );
      debugPrint('Input tensor created successfully with shape: $inputShape');
      debugPrint('Input tensor created successfully');
      
      // Run inference with the model
      // Try different common input tensor names if 'input' doesn't work
      late List<OrtValue?> outputList;
      try {
        final runOptions = OrtRunOptions(); // Create OrtRunOptions
        final inputMap = {'input': inputTensor};
        outputList = await _session!.run(runOptions, inputMap); // Pass both args
      } catch (e) {
        debugPrint('Error with input tensor name "input", trying alternatives: $e');
        try {
          // Try with 'images' as input name
          final inputMap = {'images': inputTensor};
          outputList = await _session!.run(OrtRunOptions(), inputMap);
        } catch (e2) {
          // Try with 'input_1' as input name
          final inputMap = {'input_1': inputTensor};
          outputList = await _session!.run(OrtRunOptions(), inputMap);
        }
      }
      debugPrint('Inference completed successfully');
      
      // Convert the list to a map for compatibility with the rest of the code
      Map<String, OrtValue> outputs = {};
      if (outputList.isNotEmpty && outputList[0] != null) {
        outputs['output'] = outputList[0]!;
      }
      
      // Remove the duplicate inference code - we already have the results in outputList
      // and have converted them to the outputs map above
      
      // Process the outputs to get prediction results
      final results = _processResults(outputs);
      debugPrint('Processed ${results.length} prediction results');
      
      // Note: Clean up tensor resources if needed
      // Clean up tensor resources
      inputTensor.release();
      
      return results;
    } catch (e) {
      debugPrint('Error during image classification: $e');
      return [];
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
      description += ' We recommend monitoring this area and consulting a dermatologist if you notice any changes.';
    } else {
      description += ' This appears to be a benign skin condition, but monitor for any changes.';
    }
    
    return {
      'diagnosis': label,
      'confidence': confidence,
      'risk_level': riskLevel,
      'description': description,
    };
  }

  /// Preprocess the image for the ONNX model
  static Future<List<double>> _preprocessImage(File imageFile) async {
    try {
      debugPrint('Starting image preprocessing for file: ${imageFile.path}');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }
      
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      debugPrint('Image size: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        throw Exception('Image file is empty');
      }
      
      // Decode image
      final img = await decodeImageFromList(bytes);
      debugPrint('Original image dimensions: ${img.width}x${img.height}');
      
      // Resize image to match model input size (100x75 as specified in training)
      final resizedImg = await _resizeImage(img, 100, 75);
      debugPrint('Resized image to 100x75');
      
      // Convert to RGB format and normalize pixel values using training normalization
      final inputData = await _imageToTensor(resizedImg);
      debugPrint('Converted image to tensor with ${inputData.length} values');
      
      return inputData;
    } catch (e) {
      debugPrint('Error preprocessing image: $e');
      rethrow;
    }
  }
  
  /// Resize an image to the specified dimensions
  static Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    
    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(width, height);
    
    return resizedImage;
  }
  
  /// Convert an image to a normalized tensor in NCHW format
  static Future<List<double>> _imageToTensor(ui.Image image) async {
    // Get pixel data from the image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final buffer = byteData!.buffer.asUint8List();
    
    // Create a list to hold the normalized pixel values in NCHW format
    // [batch, channels, height, width] = [1, 3, 75, 100]
    final inputData = List<double>.filled(1 * 3 * 75 * 100, 0.0);
    
    // Use fixed normalization values that match training
    // Standard normalization uses mean=0.5, std=0.5 for each channel
    const double mean = 0.5;
    const double std = 0.5;
    
    debugPrint('Using fixed normalization: mean=$mean, std=$std');
    
    // Fill the tensor in NCHW format (batch, channels, height, width)
    // For a single image, batch dimension is 1
    // We need to organize as [channel][height][width]
    for (int c = 0; c < 3; c++) { // Channels (R, G, B)
      for (int h = 0; h < 75; h++) { // Height
        for (int w = 0; w < 100; w++) { // Width
          // Get the pixel value from the RGBA buffer
          final rgbaIndex = (h * 100 + w) * 4;
          final pixelValue = buffer[rgbaIndex + c].toDouble();
          
          // Normalize pixel value to range [0,1] and then apply mean/std normalization
          // RGBA values are in range [0,255]
          final normalizedValue = (pixelValue / 255.0 - mean) / std;
          
          // Calculate index in the NCHW tensor
          // For batch=0, channel=c, height=h, width=w
          final tensorIndex = c * (75 * 100) + h * 100 + w;
          inputData[tensorIndex] = normalizedValue;
        }
      }
    }
    
    return inputData;
  }
  
  /// Clean up resources when done
  static Future<void> disposeModel() async {
    if (_modelLoaded && _session != null) {
      _session!.release();
      _session = null;
      _modelLoaded = false;
      debugPrint('ONNX model resources released');
    }
  }

  /// Process the model output into a list of predictions
  static List<Map<String, dynamic>> _processResults(Map<String, OrtValue> outputs) {
    try {
      if (outputs.isEmpty) {
        debugPrint('Error: Empty outputs from model');
        return [];
      }
      
      // Get the output tensor (usually named 'output' or similar)
      final outputTensor = outputs.values.first;
      
      // Extract data from the output tensor
      // Instead of getDoubleList() and getShape(), use the correct methods for Dart OrtValue
      final outputData = (outputTensor.value as List<double>); // Access the tensor data directly
      final outputShape = [outputData.length]; // Infer shape from data length
      debugPrint('Output shape: $outputShape, data length: ${outputData.length}');
      
      // Validate output data
      if (outputData.isEmpty) {
        debugPrint('Error: Empty output data from model');
        return [];
      }
      
      // Apply softmax to convert logits to probabilities if needed
      List<double> probabilities = _applySoftmax(outputData);
      
      // Create a list to hold the prediction results
      final List<Map<String, dynamic>> results = [];
      
      // If we have labels, map the output values to labels
      if (_labels != null && _labels!.isNotEmpty) {
        // For classification models, the output is typically a 1D array of class probabilities
        for (int i = 0; i < probabilities.length && i < _labels!.length; i++) {
          results.add({
            'label': _labels![i],
            'confidence': probabilities[i],
          });
        }
        
        // Sort by confidence (highest first)
        results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      } else {
        // If no labels are available, just return the raw values
        for (int i = 0; i < probabilities.length; i++) {
          results.add({
            'label': 'Class $i',
            'confidence': probabilities[i],
          });
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error processing model output: $e');
      return [];
    } finally {
      // Clean up output tensor resources
      for (var tensor in outputs.values) {
        tensor.release();
      }
    }
  }
  
  /// Apply softmax function to convert logits to probabilities
  static List<double> _applySoftmax(List<double> logits) {
    // Find the maximum value to prevent overflow
    double maxLogit = logits.reduce((a, b) => math.max(a, b));
    
    // Calculate exp(logit - maxLogit) for each logit
    List<double> expValues = logits.map((logit) => math.exp(logit - maxLogit)).toList();
    
    // Calculate the sum of all exp values
    double sumExp = expValues.reduce((a, b) => a + b);
    
    // Normalize by the sum to get probabilities
    return expValues.map((expVal) => expVal / sumExp).toList();
  }

  // Note: Using disposeModel() instead of dispose() for consistency with other methods

}