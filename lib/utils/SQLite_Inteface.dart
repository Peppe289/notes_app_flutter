import 'dart:collection';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/Note.dart';

class SqliteNotes {
  static Database? database;
  static const String dbName = "notes";

  Future<void> init() async {
    // already initialized. don't do it again.
    if (database != null) {
      return;
    }

    database = await openDatabase(join(await getDatabasesPath(), "$dbName.db"),
        onCreate: (db, version) {
      // id: auto increment - title - content - date: as string in database.
      return db.execute(
        'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, date TEXT NOT NULL)',
      );
    }, version: 1);
  }

  // call this function instead "database" variable.
  // with this function we are sure to have database entry or error.
  // avoid empty usage.
  Future<Database> databaseWrapper() async {
    if (database == null) {
      await init();
    }
    return database!;
  }

  // insert note into database. this operation take only text and title. ID is auto increment and date is automatic set to now.
  Future<int> insert(Note note) async {
    Database db = await databaseWrapper();

    if (note.title.isEmpty || note.content.isEmpty) {
      return -1;
    }

    HashMap<String, String> map = HashMap();
    map["title"] = note.title;
    map["content"] = note.content;
    map["date"] = DateTime.now().toString();

    return db.insert("notes", map, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Note>> doRetrieveNotes() async {
    Database db = await databaseWrapper();

    // retrieve all items.
    final List<Map<String, Object?>> notes = await db.query(dbName);

    // convert for all items into object and return the list.
    return [
      for (final {
      'id': id as int,
      'title': title as String,
      'content': content as String,
      'date': date as String
      } in notes)
        Note(id, title, content, DateTime.parse(date)),
    ];
  }

  Future<void> updateNote(Note note) async {
    Database db = await databaseWrapper();

    HashMap<String, String> map = HashMap();
    map["title"] = note.title;
    map["content"] = note.content;
    map["date"] = DateTime.now().toString();

    // Update the given Dog.
    await db.update(
      'notes',
      map,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
}
