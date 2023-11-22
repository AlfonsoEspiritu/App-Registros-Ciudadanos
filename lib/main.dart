import 'package:flutter/material.dart';
import 'photo_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: Colors.grey[900], // Fondo del AppBar
          iconTheme: IconThemeData(
            color: Colors.white, // Color de los iconos en el AppBar
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.teal,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.teal,
          ),
        ),
      ),
      home: PhotoList(),
    );
  }
}