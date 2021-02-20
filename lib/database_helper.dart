import 'notes.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton method (run once at a time)
  static Database _database; //singleton method (run once at a time)

  // table of the database similar to excel sheet with various tables
  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._createInstance(); //create instance of database

//invoke 1 database and store everything use factory (its singleton method if database is found it will return us else it will create the database)
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //Initialize the database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,'
        '$colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //insert function
  Future<int> insertNote(Notes notes) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, notes.toMap());
    return result;
  }

  //update function

  Future<int> updatetNote(Notes notes) async {
    Database db = await this.database;
    var result = await db.update(noteTable, notes.toMap(),
        where: '$colID=?', whereArgs: [notes.id]);
    return result;
  }

  //delete function

  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable where $colID=$id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Notes>> getNotesList() async {
    var notesMapList = await getNoteMapList();
    int count = notesMapList.length;
    List<Notes> notesList = List<Notes>();
    for (var i = 0; i < count; i++) {
      notesList.add(Notes.fromMapObject(notesMapList[i]));
    }
    return notesList;
  }
}
