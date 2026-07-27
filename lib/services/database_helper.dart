import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'memo_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        color INTEGER NOT NULL DEFAULT 0xFFFEF7E0
      )
    ''');
  }

  /// 查询所有笔记，按置顶和更新时间排序
  Future<List<Note>> getNotes({String? searchQuery}) async {
    final db = await database;

    List<Map<String, dynamic>> maps;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      maps = await db.query(
        'notes',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: 'is_pinned DESC, updated_at DESC',
      );
    } else {
      maps = await db.query(
        'notes',
        orderBy: 'is_pinned DESC, updated_at DESC',
      );
    }

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// 根据 ID 获取单条笔记
  Future<Note?> getNote(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// 插入笔记
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  /// 更新笔记
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// 切换置顶状态
  Future<void> togglePin(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_pinned': isPinned ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除笔记
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
