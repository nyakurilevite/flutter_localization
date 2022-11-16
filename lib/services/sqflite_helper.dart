import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'blogapp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> savePost(
       String title, String description) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
    final id = await db.insert('posts', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await SQLHelper.db();

    return db.query('posts', orderBy: "id");
  }


   static Future<List<Map<String, dynamic>>> getPostById(
      int id) async {
    final db = await SQLHelper.db();
    
    return db.query('posts',
        where: 'id = ?', whereArgs: [id]);
  }


  static Future<int> updatePost(
      int id,String title,String description) async {
    final db = await SQLHelper.db();
  
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
  
    final result =
    await db.update('posts', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
  
  


  static Future<void> deletePost(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("posts",
          where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
