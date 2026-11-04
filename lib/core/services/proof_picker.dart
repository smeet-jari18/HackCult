import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// One captured proof image, ready to upload.
class PickedProof {
  const PickedProof({
    required this.bytes,
    required this.contentType,
    required this.fileName,
  });

  final Uint8List bytes;
  final String contentType;
  final String fileName;

  int get sizeBytes => bytes.length;
}

/// Camera / gallery capture for task photos and electricity bills.
///
/// Uses `image_picker`, so it works on Android, iOS and web. Images are
/// downscaled while picking (max 1600px, quality 82) to keep uploads small —
/// the server allows max 10 MB and JPEG/PNG/WebP only.
class ProofPicker {
  ProofPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int maxBytes = 10 * 1024 * 1024;
  static const Set<String> allowedTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  /// Returns null when the user cancels. Throws [ProofPickerException] with a
  /// user-readable message on failure.
  Future<PickedProof?> pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const ProofPickerException('That image was empty. Try again.');
      }
      if (bytes.length > maxBytes) {
        throw const ProofPickerException(
          'Photo is larger than 10 MB. Please pick a smaller image.',
        );
      }

      final type = _contentType(file.mimeType, file.name);
      if (!allowedTypes.contains(type)) {
        throw const ProofPickerException(
          'Only JPEG, PNG or WebP photos are supported.',
        );
      }

      return PickedProof(
        bytes: bytes,
        contentType: type,
        fileName: file.name,
      );
    } on ProofPickerException {
      rethrow;
    } catch (error) {
      debugPrint('ProofPicker: $error');
      final text = error.toString().toLowerCase();
      if (text.contains('permission') || text.contains('denied')) {
        throw const ProofPickerException(
          'Camera/photo permission was denied. Allow it in Settings and retry.',
        );
      }
      if (text.contains('camera') && text.contains('not')) {
        throw const ProofPickerException(
          'No camera available on this device. Pick from gallery instead.',
        );
      }
      throw const ProofPickerException(
        'Could not open the camera/gallery. Please try again.',
      );
    }
  }

  static String _contentType(String? mime, String name) {
    if (mime != null && allowedTypes.contains(mime)) return mime;
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

class ProofPickerException implements Exception {
  const ProofPickerException(this.message);
  final String message;
  @override
  String toString() => message;
}
