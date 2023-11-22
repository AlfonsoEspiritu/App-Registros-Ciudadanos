import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'photo.dart';
import 'add_photo_screen.dart';
import 'photo_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  List<Photo> photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() async {
    List<Photo> loadedPhotos = await DatabaseHelper.instance.getPhotos();
    loadedPhotos.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    setState(() {
      photos = loadedPhotos;
    });
  }

  void _sendToServer() async {
    for (var photo in photos) {
      // Construye la solicitud HTTP
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.16.107:5000/upload'), // Usa la dirección correcta
      );

      // Adjunta la imagen y otros datos a la solicitud
      var file = await http.MultipartFile.fromPath('file', photo.path);
      request.files.add(file);
      request.fields['title'] = photo.title;
      request.fields['description'] = photo.description;
      request.fields['latitude'] = photo.latitude.toString();
      request.fields['longitude'] = photo.longitude.toString();
      request.fields['address'] = photo.address ?? '';

      // Envía la solicitud
      try {
        var response = await request.send();

        // Lee la respuesta del servidor
        if (response.statusCode == 200) {
          print('File sent successfully');
        } else {
          print('Error sending file: ${response.reasonPhrase}');
        }
      } catch (error) {
        print('Error sending file: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      photos[index].title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photos[index].description,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Time: ${_formatDateTime(photos[index].timestamp!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photos[index].path),
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PhotoDetailScreen(photos[index]),
                        ),
                      ).then((_) {
                        _loadPhotos();
                      });
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, photos[index]);
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPhotoScreen()),
                  ).then((_) {
                    _loadPhotos();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _sendToServer,
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Send to Server',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd - hh:mm:ss a').format(dateTime);
  }

  void _showDeleteDialog(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Photo"),
          content: Text("Are you sure you want to delete this photo?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deletePhoto(photo.id!);
                Navigator.pop(context);
                _loadPhotos();
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
