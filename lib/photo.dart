import 'package:intl/intl.dart';

class Photo {
  final int? id;
  String title;
  String description;
  final String path;
  final double? latitude;
  final double? longitude;
  final String? address;
  DateTime? timestamp;

  Photo(
    this.title,
    this.description,
    this.path, {
    this.id,
    this.latitude,
    this.longitude,
    this.address,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'path': path,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  Future<void> updateTimestamp() async {
    try {
      timestamp = DateTime.now();
    } catch (e) {
      print('Error updating timestamp: $e');
    }
  }
}