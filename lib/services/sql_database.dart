import 'package:TimeConvertor/data/time_zone_data.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class SQLDatabase{

  static const String tableName = 'time_zones';

  static Future<Database> loadDatabase() async {
    return await openDatabase(
      path.join(await getDatabasesPath(), "$tableName.db"),
      onCreate: (db, version) async {
        print("Creating table");
        await db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY, name TEXT, offset INTEGER, latitude DOUBLE PRECISION, longitude DOUBLE PRECISION)',
        );

        await add(db, TimeZoneData(0, "Home", 0, 0, 0));
      },
      version: 1,
    );
  }

  static Future<void> add(Database database, TimeZoneData tzd) async {
    await database.insert(
      tableName,
      tzd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<void> delete(Database database, int index) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [index],
    );
  }
  static Future<void> swapIndex(Database database, TimeZoneData tzd1, TimeZoneData tzd2) async {
    await Future.wait([delete(database, tzd1.id), delete(database, tzd2.id)]);

    int temp = tzd1.id;
    tzd1.id = tzd2.id;
    tzd2.id = temp;

    await Future.wait([add(database, tzd1), add(database, tzd2)]);
  }

  static Future<List<TimeZoneData>> getAll(Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    return List.generate(maps.length, (i) {
      return TimeZoneData.fromMap(maps[i]);
    });
  }
}