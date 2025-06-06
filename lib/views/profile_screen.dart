import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../models/testimonial_model.dart';
import '../services/session_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? currentUser;
  final VoidCallback? onLogout;

  const ProfileScreen({Key? key, this.currentUser, this.onLogout})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
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
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildProfileHeader(),
            SizedBox(height: 30),
            _buildTestimonialCard('Kritik 😘', _kritik, _kritikExpanded, () {
              setState(() => _kritikExpanded = !_kritikExpanded);
            }),
            _buildTestimonialCard('Saran 😁', _saran, _saranExpanded, () {
              setState(() => _saranExpanded = !_saranExpanded);
            }),
            SizedBox(height: 20),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About Me',
              subtitle: 'Tentang developer tugas ini',
              onTap: _navigateToAboutUs,
            ),
            SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Keluar dari aplikasi',
              onTap: () async {
                await SessionService.clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 40)),
          SizedBox(height: 16),
          Text(
            widget.currentUser?.username ?? 'User',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          SizedBox(height: 4),
          Text(
            '@${widget.currentUser?.username.toLowerCase() ?? 'user'}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isLogout ? Colors.red[100] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: isLogout ? Colors.red[600] : Colors.blue[600], size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isLogout ? Colors.red[700] : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AboutUsScreen(currentUser: widget.currentUser),
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  final UserModel? currentUser;
  const AboutUsScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('About Me', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                  radius: 90, backgroundImage: AssetImage('assets/img/saya.jpg')),
              SizedBox(height: 24),
              Text('Salma Hanifa',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('123220019',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              SizedBox(height: 24),
              IconButton(
                icon: Icon(Icons.code, color: Colors.black),
                onPressed: () async {
                  final url = Uri.parse('https://github.com/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.platformDefault);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
