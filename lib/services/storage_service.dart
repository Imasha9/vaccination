import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService with ChangeNotifier {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;

  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ListResult result = await firebaseStorage.ref('posts/').listAll();
      final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

      _imageUrls = urls;
    } catch (e) {
      print("Error fetching images: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImages(String imageUrl) async {
    try {
      _imageUrls.remove(imageUrl);
      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print("Error deleting image: $e");
    } finally {
      notifyListeners();
    }
  }

  String extractPathFromUrl(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.pathSegments.join('/');
    return path;
  }

  Future<void> uploadImage() async {
    _isUploading = true;
    notifyListeners();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final File file = File(image.path);

    try {
      final String filepath = 'posts/${DateTime.now().toIso8601String()}.png';
      await firebaseStorage.ref(filepath).putFile(file);
      final String downloadUrl = await firebaseStorage.ref(filepath).getDownloadURL();

      _imageUrls.add(downloadUrl);
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
