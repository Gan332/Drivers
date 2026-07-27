import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note; // null 表示新建，非 null 表示编辑

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Color _selectedColor;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(widget.note!.color);
    } else {
      _selectedColor = const Color(0xFFFEF7E0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final now = DateTime.now();
    final provider = context.read<NoteProvider>();

    if (isEditing) {
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? '无标题' : title,
        content: content,
        updatedAt: now,
      );
      provider.updateNote(updated);
    } else {
      final note = Note(
        title: title.isEmpty ? '无标题' : title,
        content: content,
        createdAt: now,
        updatedAt: now,
        color: _selectedColor.value,
      );
      provider.addNote(note);
    }

    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择笔记颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showQuickColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择颜色', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: NoteProvider.noteColors.map((color) {
                final isSelected = _selectedColor.value == color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = Color(color));
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(color),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.orange, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedColor.withValues(alpha: 0.3),
      appBar: AppBar(
        backgroundColor: _selectedColor.withValues(alpha: 0.5),
        surfaceTintColor: _selectedColor.withValues(alpha: 0.3),
        title: Text(isEditing ? '编辑笔记' : '新建笔记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '更换颜色',
            onPressed: _showQuickColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          // 标题输入
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
              decoration: const InputDecoration(
                hintText: '标题',
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),

          // 时间戳
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEditing
                  ? '最后编辑：${DateFormat('yyyy/MM/dd HH:mm').format(widget.note!.updatedAt)}'
                  : DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ),

          const Divider(height: 24),

          // 内容输入
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16, height: 1.7),
                decoration: const InputDecoration(
                  hintText: '开始记录...',
                  hintStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
