# Backend Integration Guide

This document provides a comprehensive guide for integrating the AI-powered fractal compression backend with the DeepFract Flutter app.

## Overview

The DeepFract app is structured to easily integrate with an AI-powered backend for fractal image compression. The compression flow is:

1. **User uploads image** (from camera or gallery)
2. **Frontend sends image to backend** via HTTP API
3. **Backend converts to grayscale** (for easier compression)
4. **AI-powered fractal compression** is applied
5. **Compressed image returned** to frontend
6. **User downloads/shares** the result

---

## Backend API Specification

### Base URL
```
https://your-api-domain.com/api
```

### Endpoint: Compress Image

**POST** `/compress`

#### Request

**Content-Type:** `multipart/form-data`

**Body Parameters:**
- `image` (file, required): The image file to compress
- `quality` (string, optional): Compression quality level (`low`, `medium`, `high`)
- `algorithm` (string, optional): Compression algorithm (`fractal_ai`)

**Example Request:**
```bash
curl -X POST https://your-api-domain.com/api/compress \
  -F "image=@photo.jpg" \
  -F "quality=high" \
  -F "algorithm=fractal_ai"
```

#### Response

**Success (200 OK):**

```json
{
  "success": true,
  "compressed_image": "base64_encoded_image_data",
  "original_size": 10485760,
  "compressed_size": 1048576,
  "compression_ratio": 90.0,
  "is_grayscale": true,
  "processing_time_ms": 2500,
  "metadata": {
    "width": 1920,
    "height": 1080,
    "format": "jpeg"
  }
}
```

**Error (400/500):**

```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

---

## Frontend Integration Steps

### 1. Add Required Dependencies

Add HTTP client to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  path_provider: ^2.1.1  # For temporary file storage
```

### 2. Update CompressionService

The `lib/services/compression_service.dart` file contains placeholders for backend integration. Follow these steps:

#### Step 1: Import required packages

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
```

#### Step 2: Set your API URL

```dart
static const String _apiBaseUrl = 'https://your-api-domain.com';
```

#### Step 3: Uncomment and use the implementation

The `compressImage` method contains a commented example implementation. Uncomment it and adjust as needed.

### 3. Update Home Screen

The home screen (`lib/screens/home_screen.dart`) is already structured to use the compression service:

```dart
// In _compressImage method:
final compressionService = CompressionService();

try {
  final result = await compressionService.compressImage(_selectedImage!);
  
  // Navigate to result screen with actual data
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CompressionResultScreen(
        originalImage: result.originalFile,
        compressedImage: result.compressedFile,  // Add this parameter
        originalSize: result.formattedOriginalSize,
        compressedSize: result.formattedCompressedSize,
        compressionTime: compressionTime,
      ),
    ),
  );
} catch (e) {
  // Handle compression error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Compression failed: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### 4. Update CompressionResultScreen

Add a parameter for the actual compressed image:

```dart
class CompressionResultScreen extends StatelessWidget {
  final File originalImage;
  final File compressedImage;  // Add this
  final String originalSize;
  final String compressedSize;
  final Duration compressionTime;

  const CompressionResultScreen({
    super.key,
    required this.originalImage,
    required this.compressedImage,  // Add this
    required this.originalSize,
    required this.compressedSize,
    required this.compressionTime,
  });

  // In build method, display compressedImage instead of originalImage
}
```

---

## Code Integration Checklist

Use this checklist when integrating the backend:

- [ ] Backend API is deployed and accessible
- [ ] API endpoint URL is configured in `compression_service.dart`
- [ ] HTTP dependencies added to `pubspec.yaml`
- [ ] Imports added to `compression_service.dart`
- [ ] `compressImage` method implementation uncommented and tested
- [ ] Error handling tested for network failures
- [ ] File upload/download tested with real images
- [ ] Compression result screen updated to show actual compressed image
- [ ] Loading overlay duration tested with real API response time
- [ ] File size calculations verified
- [ ] Grayscale conversion verified
- [ ] Download functionality implemented
- [ ] Share functionality implemented
- [ ] API authentication added (if required)
- [ ] Rate limiting handled (if applicable)

---

## Backend Processing Flow

### Expected Backend Behavior

1. **Receive Image**
   - Accept multipart/form-data POST request
   - Validate image format (JPEG, PNG, etc.)
   - Validate file size limits

2. **Convert to Grayscale**
   - Convert RGB image to grayscale
   - This simplifies the compression algorithm
   - Reduces data complexity for fractal analysis

3. **Apply AI-Powered Fractal Compression**
   - Use neural network to identify fractal patterns
   - Apply fractal compression algorithm
   - Optimize for quality vs. compression ratio
   - Target: 80-95% size reduction

4. **Return Compressed Image**
   - Encode compressed image as base64
   - Include metadata (sizes, ratios, timing)
   - Send JSON response

---

## Error Handling

### Frontend Error Scenarios

| Error Type | Handling Strategy |
|------------|-------------------|
| Network timeout | Show retry dialog with timeout message |
| Server error (500) | Show error message, log details |
| Invalid image format | Validate before upload, show format error |
| File too large | Check size before upload, show size limit |
| No internet connection | Detect offline, show connectivity error |

### Example Error Handling

```dart
try {
  final result = await compressionService.compressImage(imageFile);
  // Success
} on CompressionException catch (e) {
  // Handle compression-specific errors
  showErrorDialog(context, 'Compression Error', e.message);
} on SocketException {
  // Handle network errors
  showErrorDialog(context, 'Network Error', 'No internet connection');
} catch (e) {
  // Handle unexpected errors
  showErrorDialog(context, 'Error', 'An unexpected error occurred');
}
```

---

## Testing Backend Integration

### 1. Local Testing

Use a local backend server for development:

```dart
static const String _apiBaseUrl = 'http://localhost:3000';
```

Note: Android emulator uses `10.0.2.2` instead of `localhost`

### 2. Mock Response Testing

Test with mock data first:

```dart
// In compression_service.dart
Future<CompressionResult> compressImage(File imageFile) async {
  if (kDebugMode) {
    // Use mock data in debug mode
    return _getMockResult(imageFile);
  } else {
    // Use real API in release mode
    return _realApiCall(imageFile);
  }
}
```

### 3. Performance Testing

Monitor and optimize:
- Upload time
- Compression time
- Download time
- Total user wait time (should be < 10 seconds for best UX)

---

## Security Considerations

1. **HTTPS Only**
   - Always use HTTPS in production
   - Never send images over HTTP

2. **File Size Limits**
   - Implement client-side file size checks
   - Backend should enforce max file size

3. **API Authentication**
   - Consider adding API key or JWT authentication
   - Rate limit requests per user

4. **Input Validation**
   - Validate file types on both client and server
   - Sanitize file names

---

## Performance Optimization

### 1. Image Preprocessing

Before sending to backend:
```dart
// Resize large images on client side
final resized = await FlutterImageCompress.compressWithFile(
  imageFile.path,
  minWidth: 1920,
  minHeight: 1080,
  quality: 85,
);
```

### 2. Progress Indicators

Show upload/download progress:
```dart
request.send().asStream().listen((response) {
  // Track upload progress
  final progress = response.contentLength / totalSize;
  updateProgressUI(progress);
});
```

### 3. Caching

Cache compressed results:
```dart
// Store in local database or shared preferences
final compressedPath = await cacheCompressedImage(result);
```

---

## Example Backend Implementation (Python/Flask)

```python
from flask import Flask, request, jsonify
import cv2
import numpy as np
import base64
from ai_fractal_compressor import AIFractalCompressor

app = Flask(__name__)
compressor = AIFractalCompressor()

@app.route('/api/compress', methods=['POST'])
def compress_image():
    try:
        # Get uploaded file
        image_file = request.files['image']
        image_bytes = image_file.read()
        
        # Decode image
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply AI-powered fractal compression
        compressed = compressor.compress(gray)
        
        # Encode result
        _, buffer = cv2.imencode('.jpg', compressed)
        compressed_base64 = base64.b64encode(buffer).decode('utf-8')
        
        # Calculate sizes
        original_size = len(image_bytes)
        compressed_size = len(buffer)
        ratio = ((original_size - compressed_size) / original_size) * 100
        
        return jsonify({
            'success': True,
            'compressed_image': compressed_base64,
            'original_size': original_size,
            'compressed_size': compressed_size,
            'compression_ratio': ratio,
            'is_grayscale': True
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## TODO Comments in Codebase

Search for `TODO: Backend Integration` in the codebase to find all integration points:

1. `lib/services/compression_service.dart` - Main API implementation
2. `lib/screens/home_screen.dart` - Calculate actual file sizes
3. `lib/screens/compression_result_screen.dart` - Display actual compressed image
4. `lib/widgets/compression_loading_overlay.dart` - Adjust timing based on real API

---

## Support & Resources

- Flutter HTTP Package: https://pub.dev/packages/http
- Path Provider Package: https://pub.dev/packages/path_provider
- Image Picker Package: https://pub.dev/packages/image_picker
- Flutter Best Practices: https://flutter.dev/docs/development/data-and-backend/networking

---

## Contact

For backend integration support, refer to your backend team's documentation or contact your technical lead.

