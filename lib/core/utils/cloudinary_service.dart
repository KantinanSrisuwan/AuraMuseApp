import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dojwszq0e/image/upload';
  static const String _uploadPreset = 'auramuse_preset';

  // ฟังก์ชันอัพโหลดรูปไปยัง Cloudinary
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      // อ่าน bytes จากไฟล์
      final bytes = await imageFile.readAsBytes();
      
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));

      // เพิ่ม fields สำหรับ Cloudinary
      request.fields['upload_preset'] = _uploadPreset;

      // เพิ่มไฟล์รูปภาพจาก bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

      // ส่ง request
      final response = await request.send();

      if (response.statusCode == 200) {
        // แปลง response เป็น String
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);

        // แปลง String เป็น JSON
        final jsonResponse = jsonDecode(responseString);
        
        if (jsonResponse.containsKey('secure_url')) {
          print('Upload successful: ${jsonResponse['secure_url']}');
          return jsonResponse['secure_url'];
        }

        return null;
      } else {
        print('Upload failed with status code: ${response.statusCode}');
        final errorData = await response.stream.bytesToString();
        print('Error details: $errorData');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // ฟังก์ชันอัพโหลดรูปจาก file path
  static Future<String?> uploadImageFromPath(String imagePath) async {
    try {
      // อ่าน bytes จาก file path
      final bytes = await File(imagePath).readAsBytes();
      final fileName = imagePath.split('/').last;
      
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));

      // เพิ่ม fields สำหรับ Cloudinary
      request.fields['upload_preset'] = _uploadPreset;

      // เพิ่มไฟล์รูปภาพจาก bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      // ส่ง request
      final response = await request.send();

      if (response.statusCode == 200) {
        // แปลง response เป็น String
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);

        // แปลง String เป็น JSON
        final jsonResponse = jsonDecode(responseString);
        
        if (jsonResponse.containsKey('secure_url')) {
          print('Upload successful: ${jsonResponse['secure_url']}');
          return jsonResponse['secure_url'];
        }

        return null;
      } else {
        print('Upload failed with status code: ${response.statusCode}');
        final errorData = await response.stream.bytesToString();
        print('Error details: $errorData');
        return null;
      }
    } catch (e) {
      print('Error uploading image from path: $e');
      return null;
    }
  }

  // ฟังก์ชันสำหรับเลือกรูปจาก gallery
  static Future<XFile?> pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}