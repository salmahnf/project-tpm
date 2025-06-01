import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? currentUser;
  final VoidCallback? onLogout;

  const ProfileScreen({
    Key? key,
    this.currentUser,
    this.onLogout,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile Avatar and Info
            _buildProfileHeader(),
            SizedBox(height: 30),
            // Menu Items
            _buildMenuItem(
              icon: Icons.rate_review,
              title: 'Testimonial',
              subtitle: 'Lihat saran dan kesan',
              onTap: () => _navigateToTestimonial(),
            ),
            SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About Me',
              subtitle: 'Tentang developer tugas ini',
              onTap: () => _navigateToAboutUs(),
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
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          // User Info
          if (widget.currentUser != null) ...[
            Text(
              widget.currentUser!.username,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              '@${widget.currentUser!.username.toLowerCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ] else ...[
            Text(
              'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              '@user',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
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
            spreadRadius: 1,
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
          child: Icon(
            icon,
            color: isLogout ? Colors.red[600] : Colors.blue[600],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isLogout ? Colors.red[700] : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateToTestimonial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestimonialScreen(),
      ),
    );
  }

  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutUsScreen(currentUser: widget.currentUser),
      ),
    );
  }
}

// Testimonial Screen
class TestimonialScreen extends StatefulWidget {
  @override
  _TestimonialScreenState createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  bool _isKritikExpanded = false;
  bool _isSaranExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Testimonial',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Kritik Dropdown
            _buildDropdownCard(
              icon: Icons.rocket_launch,
              title: 'Kritik',
              isExpanded: _isKritikExpanded,
              onTap: () {
                setState(() {
                  _isKritikExpanded = !_isKritikExpanded;
                });
              },
              content:
                  'Materinya sangat menarik dan cara mengajarnya enak dipahami 📱👍. Hanya saja, waktu untuk mengerjakan tugas kadang terasa terlalu singkat ⏳😅.',
            ),
            SizedBox(height: 12),
            // Saran Dropdown
            _buildDropdownCard(
              icon: Icons.lightbulb_outline,
              title: 'Saran',
              isExpanded: _isSaranExpanded,
              onTap: () {
                setState(() {
                  _isSaranExpanded = !_isSaranExpanded;
                });
              },
              content:
                  'Akan lebih baik jika tenggat tugas bisa sedikit diperpanjang agar hasilnya lebih maksimal ✅😊. Terima kasih Pak atas ilmu dan semangat mengajarnya 🙏✨',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: isExpanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                  : BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: isExpanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                  : BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
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
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// About Us Screen
class AboutUsScreen extends StatelessWidget {
  final UserModel? currentUser;

  const AboutUsScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Me',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Profile Photo center & bigger
            Center(
              child: Container(
                width: 180, // Diperbesar dari 120
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                      16), // Tambahkan sudut lebih bulat jika perlu
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/img/saya.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Salma Hanifa',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '123220019',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                  icon: Icon(Icons.code, color: Colors.white),
                  onPressed: () async {
                    final Uri url = Uri.parse('https://github.com/topics/link');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tidak bisa membuka GitHub')),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
