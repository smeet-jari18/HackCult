import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BillProofStorage {
  BillProofStorage({FirebaseStorage? storage, FirebaseAuth? auth})
      : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  Future<String> uploadBillProof({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in before uploading bill proof.');
    }
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw ArgumentError('Bill proof must be between 1 byte and 10 MB.');
    }
    if (!const {'image/jpeg', 'image/png', 'image/webp'}.contains(contentType)) {
      throw ArgumentError('Bill proof must be a JPEG, PNG, or WebP image.');
    }

    final extension = switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      _ => 'webp',
    };
    final id = DateTime.now().microsecondsSinceEpoch;
    final path = 'users/$uid/bill-proofs/$id.$extension';
    await _storage.ref(path).putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
    return path;
  }
}
