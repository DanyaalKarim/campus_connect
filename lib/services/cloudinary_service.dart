import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final _cloudinary = CloudinaryPublic(
    'nkdxoqjp',
    'campus_connect_preset',
    cache: false,
  );

  Future<String?> uploadEventPoster(File image) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'event_posters',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading poster: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(File image) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_images',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading profile: $e');
      return null;
    }
  }

  Future<String?> uploadEventPhoto(File image, String eventId) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'event_photos/$eventId',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }
}