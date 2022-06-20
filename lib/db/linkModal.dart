// ignore: file_names
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import '../entity/link.dart';

// ignore: camel_case_types
class linkModal {
  Database? _database;

  // A method that retrieves link from the link table.
  Future<String?> getLink() async {
    if (_database == null) {
      final database = openDatabase(
        path.join(await getDatabasesPath(), 'link_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE links(link TEXT)',
          );
        },
        version: 1,
      );

      _database = await database;
    }

    final List<Map<String, dynamic>> maps = await _database!.query('links');
    print(_database!.query('links'));
    if (maps.isNotEmpty) {
      return maps.first['link'];
    }

    return null;
  }

  Future<void> insertLink(Link link) async {
    if (_database == null) {
      final database = openDatabase(
        path.join(await getDatabasesPath(), 'link_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE links(link TEXT)',
          );
        },
        version: 1,
      );

      _database = await database;
    }

    List<Map<String, Object?>> items = await _database!.query("links");

    if (items.isEmpty) {
      await _database!.insert(
        'links',
        link.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await _database!.update("links", link.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    print(_database!.query('links'));
  }
}
