import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import '../app_config.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static final ImagePicker _picker = ImagePicker();

  static Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<File?> takePicture() async {
    if (!await requestCameraPermission()) {
      throw Exception('Camera permission denied');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConfig.maxImageSize.toDouble(),
        maxHeight: AppConfig.maxImageSize.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        return await _processImage(imageFile);
      }
    } catch (e) {
      debugPrint('Failed to take picture: $e');
      throw Exception('Failed to take picture: $e');
    }
    return null;
  }

  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConfig.maxImageSize.toDouble(),
        maxHeight: AppConfig.maxImageSize.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        return await _processImage(imageFile);
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e');
      throw Exception('Failed to pick image: $e');
    }
    return null;
  }

  static Future<File> _processImage(File imageFile) async {
    try {
      // Read image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if necessary
      if (image.width > AppConfig.maxImageSize || image.height > AppConfig.maxImageSize) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? AppConfig.maxImageSize : null,
          height: image.height > image.width ? AppConfig.maxImageSize : null,
        );
      }

      // Enhance image for better disease detection
      image = _enhanceImageForML(image);

      // Save processed image
      final processedBytes = img.encodeJpg(image, quality: AppConfig.imageQuality);
      await imageFile.writeAsBytes(processedBytes);

      return imageFile;
    } catch (e) {
      debugPrint('Image processing failed: $e');
      return imageFile; // Return original if processing fails
    }
  }

  static img.Image _enhanceImageForML(img.Image image) {
    // Apply image enhancements for better ML detection
    
    // Adjust contrast and brightness
    image = img.adjustColor(
      image,
      contrast: 1.1,
      brightness: 1.05,
    );

    // Apply slight sharpening
    image = img.convolution(image, [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0
    ]);

    return image;
  }

  static Future<Uint8List> imageToBytes(File imageFile) async {
    return await imageFile.readAsBytes();
  }

  static String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  static Future<bool> validateImage(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        return false;
      }

      // Check minimum size requirements
      if (image.width < 224 || image.height < 224) {
        return false;
      }

      // Check file size (max 10MB)
      if (imageBytes.length > 10 * 1024 * 1024) {
        return false;
      }

      // Check if image format is supported
      final String extension = imageFile.path.split('.').last.toLowerCase();
      if (!AppConfig.supportedImageFormats.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static void dispose() {
    _controller?.dispose();
  }

  static bool get isInitialized => _controller?.value.isInitialized ?? false;
  
  static CameraController? get controller => _controller;
  
  static List<CameraDescription>? get cameras => _cameras;
}