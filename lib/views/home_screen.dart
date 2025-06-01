import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthController.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthController.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Constants.logoutSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Home Page Widget
  Widget _buildHomePage() {
    return Padding(
      padding: EdgeInsets.all(Constants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(Constants.defaultRadius),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.home,
                  size: 64,
                  color: Colors.blue,
                ),
                SizedBox(height: 16),
                if (_currentUser != null) ...[
                  Text(
                    'Selamat datang, ${_currentUser!.username}!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search Page Widget
  Widget _buildSearchPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Halaman Search',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  // Convert Page Widget
  Widget _buildConvertPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Halaman Convert',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  // Profile Page Widget
  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Halaman Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          if (_currentUser != null) ...[
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Username: ${_currentUser!.username}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ${_currentUser!.email}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Get current page based on selected index
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSearchPage();
      case 2:
        return _buildConvertPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  // Get app bar title based on current index
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Convert';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Convert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
