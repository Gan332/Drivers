import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../services/database_helper.dart';

class NoteProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Note> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// 加载所有笔记
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _dbHelper.getNotes(searchQuery: _searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  /// 设置搜索关键词
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadNotes();
  }

  /// 获取单条笔记
  Future<Note?> getNote(int id) async {
    return await _dbHelper.getNote(id);
  }

  /// 添加笔记
  Future<int> addNote(Note note) async {
    final id = await _dbHelper.insertNote(note);
    await loadNotes();
    return id;
  }

  /// 更新笔记
  Future<void> updateNote(Note note) async {
    await _dbHelper.updateNote(note);
    await loadNotes();
  }

  /// 切换置顶
  Future<void> togglePin(int id, bool currentPinned) async {
    await _dbHelper.togglePin(id, !currentPinned);
    await loadNotes();
  }

  /// 删除笔记
  Future<void> deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    await loadNotes();
  }

  /// 创建新笔记的默认颜色列表
  static const List<int> noteColors = [
    0xFFFEF7E0, // 暖黄
    0xFFE8F5E9, // 淡绿
    0xFFE3F2FD, // 淡蓝
    0xFFFCE4EC, // 淡粉
    0xFFF3E5F5, // 淡紫
    0xFFE0F7FA, // 青
    0xFFFFF8E1, // 淡橙
    0xFFEFEBE9, // 淡棕
    0xFFE0E0E0, // 灰色
    0xFFFFFFFF, // 白色
  ];
}
