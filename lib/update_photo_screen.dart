import 'package:flutter/material.dart';
import 'dart:io';
import 'database_helper.dart';
import 'photo.dart';

class UpdatePhotoScreen extends StatefulWidget {
  final Photo photo;

  UpdatePhotoScreen(this.photo);

  @override
  _UpdatePhotoScreenState createState() => _UpdatePhotoScreenState();
}

class _UpdatePhotoScreenState extends State<UpdatePhotoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.photo.title);
    _descriptionController = TextEditingController(text: widget.photo.description);
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Report Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              child: Image.file(File(widget.photo.path), fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                widget.photo.title = _titleController.text;
                widget.photo.description = _descriptionController.text;

                await DatabaseHelper.instance.updatePhoto(widget.photo);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal, // Set the button color
              ),
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
