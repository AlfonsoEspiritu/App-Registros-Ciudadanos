import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'photo.dart';
import 'package:geocoding/geocoding.dart';

class AddPhotoScreen extends StatefulWidget {
  @override
  _AddPhotoScreenState createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  double? _latitude;
  double? _longitude;
  String _address = 'Location not available';

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _getLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        if (_latitude != null && _longitude != null) {
          List<Placemark> placemarks =
              await placemarkFromCoordinates(_latitude!, _longitude!);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            setState(() {
              _address =
                  '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
            });
          }
        }
      } catch (e) {
        print('Error obtaining location: $e');
      }
    } else {
      print('Location permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _getImage();
              },
              child: Icon(Icons.camera_alt),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _getLocation();
              },
              child: Icon(Icons.location_on),
            ),
            SizedBox(height: 16.0),
            if (_image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            if (_latitude != null && _longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Latitude: $_latitude',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Longitude: $_longitude',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Address:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    _address,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_image != null) {
                  String title = _titleController.text;
                  String description = _descriptionController.text;

                  print(
                    'Title: $title, Description: $description, Image Path: ${_image!.path}, Latitude: $_latitude, Longitude: $_longitude, Address: $_address',
                  );

                  await DatabaseHelper.instance.insertPhoto(
                    Photo(
                      title,
                      description,
                      _image!.path,
                      latitude: _latitude,
                      longitude: _longitude,
                      address: _address,
                    ),
                  );

                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal, // Set the button color
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
