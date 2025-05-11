import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload an image to Firebase Storage and save its metadata to Firestore
  static Future<String?> uploadImage(String imagePath, {String? diagnosis}) async {
    try {
      // Create a unique file name using timestamp
      final String fileName = 'skin_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create a reference to the file location in Firebase Storage
      final Reference storageRef = _storage.ref().child('skin_images/$fileName');
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(File(imagePath));
      
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      // Save metadata to Firestore
      final DocumentReference docRef = await _firestore.collection('skin_images').add({
        'image_url': downloadUrl,
        'file_name': fileName,
        'upload_time': FieldValue.serverTimestamp(),
        'diagnosis': diagnosis,
      });
      
      debugPrint('Image uploaded successfully. Document ID: ${docRef.id}');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Retrieve all skin images from Firestore
  static Future<List<Map<String, dynamic>>> getSkinImages() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('skin_images')
          .orderBy('upload_time', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'image_url': data['image_url'],
          'upload_time': data['upload_time'],
          'diagnosis': data['diagnosis'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error retrieving skin images: $e');
      return [];
    }
  }

  /// Delete an image from both Storage and Firestore
  static Future<bool> deleteImage(String documentId, String imageUrl) async {
    try {
      // Delete from Firestore
      await _firestore.collection('skin_images').doc(documentId).delete();
      
      // Extract file name from URL and delete from Storage
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Update the diagnosis for an existing image
  static Future<bool> updateDiagnosis(String documentId, String diagnosis) async {
    try {
      await _firestore.collection('skin_images').doc(documentId).update({
        'diagnosis': diagnosis,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating diagnosis: $e');
      return false;
    }
  }
}