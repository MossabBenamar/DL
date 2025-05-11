# ONNX Model Integration

## Overview
This application has been updated to use ONNX (Open Neural Network Exchange) models instead of TensorFlow Lite. This change was made because Gradle 8 is not compatible with TFLite.

## Changes Made

1. **Model Format**: Changed from `.tflite` to `.onnx`
   - The model file is now located at `DLModel/converted_model.onnx`

2. **Dependencies**:
   - Removed TFLite dependency
   - Added Flutter ONNX Runtime dependency (`flutter_onnx_runtime: ^0.0.1`)

3. **Code Changes**:
   - Created a new `onnx_model_service.dart` to replace the TFLite implementation
   - Updated imports in relevant files to use the new ONNX service
   - Maintained the same API interface for compatibility with existing code

## Using the ONNX Model

### Model Placement
Ensure that your ONNX model file is placed in the `DLModel` directory and named `converted_model.onnx`.

### Labels File
If your model requires a labels file, place it at `DLModel/labels.txt` with one label per line.

## Implementation Details

The ONNX model service provides the same functionality as the previous TFLite service:

- `loadModel()`: Initializes the ONNX runtime and loads the model
- `classifyImage(String imagePath)`: Processes an image and returns classification results
- `getDiagnosisResult(List<Map<String, dynamic>> predictions)`: Converts raw predictions into user-friendly diagnosis information

## Preprocessing Requirements

The current implementation includes placeholder preprocessing code. You may need to update the `_preprocessImage` method in `onnx_model_service.dart` to match your specific model's input requirements:

- Input shape (dimensions)
- Normalization parameters
- Color channel ordering

## Troubleshooting

If you encounter issues with the ONNX model:

1. Check that the model file exists and is correctly formatted
2. Verify that the input preprocessing matches your model's requirements
3. Ensure the output tensor name is correctly referenced in the code
4. Check debug logs for detailed error messages