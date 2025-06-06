import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/testimonial_model.dart';
import '../services/session_service.dart';

class TestimonialScreen extends StatefulWidget {
  @override
  _TestimonialScreenState createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  bool _isKritikExpanded = true;
  bool _isSaranExpanded = true;
  List<TestimonialModel> _kritik = [];
  List<TestimonialModel> _saran = [];
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserTestimonials();
  }

  Future<void> _loadUserTestimonials() async {
    final user = await SessionService.getCurrentUser();
    if (user == null) return;

    final box = Hive.box<TestimonialModel>('testimonials');
    final all = box.values.where((t) => t.username == user.username).toList();

    setState(() {
      _username = user.username;
      _kritik = all.where((t) => t.type == 'Kritik').toList();
      _saran = all.where((t) => t.type == 'Saran').toList();
    });
  }

  void _showInputDialog({TestimonialModel? existing}) {
    final controller = TextEditingController(text: existing?.content ?? '');
    String selectedType = existing?.type ?? 'Kritik';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Tambah Testimoni' : 'Edit Testimoni'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedType,
              items: ['Kritik', 'Saran']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) => setState(() => selectedType = value!),
            ),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Isi testimoni...'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final box = Hive.box<TestimonialModel>('testimonials');
              final content = controller.text.trim();

              if (content.isEmpty || _username == null) return;

              if (existing != null) {
                existing
                  ..content = content
                  ..type = selectedType;
                await existing.save();
              } else {
                final newItem = TestimonialModel(
                  type: selectedType,
                  content: content,
                  username: _username!,
                );
                await box.add(newItem);
              }

              Navigator.pop(context);
              _loadUserTestimonials();
            },
            child: Text(existing == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TestimonialModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Testimoni'),
        content: Text('Yakin ingin menghapus testimoni ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () async {
              await item.delete();
              Navigator.pop(context);
              _loadUserTestimonials();
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<TestimonialModel> contentList,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: isExpanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(8), topRight: Radius.circular(8))
                  : BorderRadius.circular(8),
            ),
            child: ListTile(
              onTap: onTap,
              leading: Icon(Icons.circle, color: Colors.orange, size: 10),
              title: Text(title, style: TextStyle(color: Colors.white)),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: contentList.isEmpty
                  ? Text('Belum ada ${title.toLowerCase()}.',
                      style: TextStyle(color: Colors.grey[600]))
                  : Column(
                      children: contentList.map((t) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showInputDialog(existing: t),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(t),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text('Testimonial', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDropdownCard(
              title: 'Kritik',
              isExpanded: _isKritikExpanded,
              onTap: () =>
                  setState(() => _isKritikExpanded = !_isKritikExpanded),
              contentList: _kritik,
            ),
            _buildDropdownCard(
              title: 'Saran',
              isExpanded: _isSaranExpanded,
              onTap: () => setState(() => _isSaranExpanded = !_isSaranExpanded),
              contentList: _saran,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
