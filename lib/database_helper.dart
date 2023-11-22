import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'photo.dart';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'photo_database.db');
    return await openDatabase(path,
        version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        path TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        timestamp INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE photos ADD COLUMN timestamp INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertPhoto(Photo photo) async {
    try {
      await photo.updateTimestamp();
      Database db = await instance.database;
      return await db.insert('photos', photo.toMap());
    } catch (e) {
      print('Error inserting photo: $e');
      return -1;
    }
  }

  Future<List<Photo>> getPhotos() async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> maps = await db.query('photos');
      return List.generate(maps.length, (i) {
        return Photo(
          maps[i]['title'],
          maps[i]['description'],
          maps[i]['path'],
          latitude: maps[i]['latitude'],
          longitude: maps[i]['longitude'],
          address: maps[i]['address'],
          id: maps[i]['id'],
          timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        );
      });
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }

  Future<int> updatePhoto(Photo photo) async {
    try {
      await photo.updateTimestamp();
      Database db = await instance.database;
      return await db.update('photos', photo.toMap(),
          where: 'id = ?', whereArgs: [photo.id]);
    } catch (e) {
      print('Error updating photo: $e');
      return -1;
    }
  }

  Future<int> deletePhoto(int id) async {
    try {
      Database db = await instance.database;
      return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting photo: $e');
      return -1;
    }
  }
}
