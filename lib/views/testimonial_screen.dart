import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/testimonial_model.dart';
import '../services/session_service.dart';

class TestimonialScreen extends StatefulWidget {
  @override
  _TestimonialScreenState createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  List<TestimonialModel> _kritik = [];
  List<TestimonialModel> _saran = [];
  String? _username;
  bool _kritikExpanded = true;
  bool _saranExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    final user = await SessionService.getCurrentUser();
    if (user == null) return;
    final box = Hive.box<TestimonialModel>('testimonials');
    final values =
        box.values.where((t) => t.username == user.username).toList();

    setState(() {
      _username = user.username;
      _kritik = values.where((t) => t.type == 'Kritik').toList();
      _saran = values.where((t) => t.type == 'Saran').toList();
    });
  }

  void _showInputDialog({TestimonialModel? item}) {
    final controller = TextEditingController(text: item?.content ?? '');
    String selectedType = item?.type ?? 'Kritik';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Testimoni' : 'Edit Testimoni'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedType,
              onChanged: (value) => setState(() => selectedType = value!),
              items: ['Kritik', 'Saran']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
            ),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Isi testimoni'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty || _username == null) return;
              final box = Hive.box<TestimonialModel>('testimonials');

              if (item != null) {
                item.content = controller.text.trim();
                item.type = selectedType;
                await item.save();
              } else {
                await box.add(TestimonialModel(
                  type: selectedType,
                  content: controller.text.trim(),
                  username: _username!,
                ));
              }

              Navigator.pop(context);
              _loadTestimonials();
            },
            child: Text(item == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteDialog(TestimonialModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Testimoni'),
        content: Text('Yakin ingin menghapus testimoni ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () async {
              await item.delete();
              Navigator.pop(context);
              _loadTestimonials();
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String title, List<TestimonialModel> list,
      bool expanded, VoidCallback onToggle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.black,
            title: Text(title,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: onToggle,
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: list.isEmpty
                  ? Text('Belum ada $title.',
                      style: TextStyle(color: Colors.grey))
                  : Column(
                      children: list.map((t) {
                        return ListTile(
                          title: Text(t.content),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showInputDialog(item: t),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDialog(t),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testimonial'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTestimonialCard('Kritik 😘', _kritik, _kritikExpanded, () {
              setState(() => _kritikExpanded = !_kritikExpanded);
            }),
            _buildTestimonialCard('Saran 😁', _saran, _saranExpanded, () {
              setState(() => _saranExpanded = !_saranExpanded);
            }),
          ],
        ),
      ),
    );
  }
}