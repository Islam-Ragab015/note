import 'package:flutter_day4/db/DbHelper.dart';
import 'package:flutter_day4/util/constants.dart';
import 'package:sqflite/sqflite.dart';

import '../model/Note.dart';

class CURD {
  CURD._();

  static final CURD curd = CURD._();

  Future<int> insertNote(Note note) async {
    Database db = await DbHelper.helper.createOpenDb();
    return await db.insert(tableName, note.toMap());
  }

  Future<List<Note>> selectNotes() async {
    Database db = await DbHelper.helper.createOpenDb();
    List<Map<String, dynamic>> result =
        await db.query(tableName, orderBy: '$colDate desc');
    return result.map((e) => Note.fromNote(e)).toList();
  }

  Future<int> deleteNote(int? id) async {
    Database db = await DbHelper.helper.createOpenDb();
    return await db.delete(tableName, where: '$colId=?', whereArgs: [id]);
  }

  Future<int> updateNote(Note note) async {
    Database db = await DbHelper.helper.createOpenDb();
    return await db.update(tableName, note.toMap(),
        where: '$colId=?', whereArgs: [note.id]);
  }
}
