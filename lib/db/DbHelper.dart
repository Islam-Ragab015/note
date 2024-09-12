import 'package:flutter_day4/util/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //1-Create single instance
  DbHelper._(); //private named constructor
  static final DbHelper helper = DbHelper._();

  //2- Db folder path
  Future<String> _getDbPath() async {
    String dbPath = await getDatabasesPath();
    String noteDbPath = join(dbPath, dbName);
    return noteDbPath;
  }

  //3- create or open
  Future<Database> createOpenDb() async {
    String path = await _getDbPath();
    return await openDatabase(path,
        version: version,
        onCreate: (db, version) => _createTable(db),
        onUpgrade: (db, oldVersion, newVersion) =>
            _onUpgrade(db, oldVersion, newVersion),
        singleInstance: true);
  }

  //4- create tables
  _createTable(Database db) {
    try {
      String sql =
          'CREATE TABLE $tableName ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colText TEXT, $colDate TEXT, $colColor INTEGER)';
      print(sql);
      db.execute(sql);
    } on DatabaseException catch (e) {
      print(e.toString());
    }
  }

  // Handle database migration if needed
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade the database to add the noteColor column
      await db.execute('ALTER TABLE $tableName ADD COLUMN $colColor INTEGER');
    }
  }
}
