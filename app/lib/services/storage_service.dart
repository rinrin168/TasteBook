import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a recipe image to Firebase Storage and returns the public download URL.
  /// Uses the user ID and current timestamp to ensure a unique file path.
  Future<String> uploadRecipeImage(XFile file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${file.name}';
      
      // We store it under recipe_images / userId / fileName
      final Reference ref = _storage.ref().child('recipe_images').child(userId).child(fileName);

      // We read as bytes to support both Web and Mobile platforms
      final Uint8List fileBytes = await file.readAsBytes();

      final metadata = SettableMetadata(
        contentType: 'image/jpeg', // We assume jpeg, though it could be png
      );

      final UploadTask uploadTask = ref.putData(fileBytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to storage: $e');
      rethrow;
    }
  }
}
