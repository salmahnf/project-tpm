import 'package:flutter/material.dart';
import 'package:salmaproject/views/favorite_cocktail_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cocktail_controller.dart';
import '../models/user_model.dart';
import '../models/cocktail_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'convert_screen.dart';
import 'cocktail_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  int _currentIndex = 0;

  // Cocktail related variables
  List<CocktailModel> _cocktails = [];
  List<CategoryModel> _categories = [];
  String _selectedCategory = 'All';
  TextEditingController _searchController = TextEditingController();
  bool _isCocktailLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthController.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _loadInitialData() async {
    await _loadCategories();
    await _loadCocktails();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CocktailController.getCategories();
      setState(() {
        _categories = [CategoryModel(strCategory: 'All'), ...categories];
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadCocktails() async {
    setState(() {
      _isCocktailLoading = true;
    });

    try {
      List<CocktailModel> cocktails;

      if (_selectedCategory == 'All') {
        cocktails = await CocktailController.getRandomCocktails();
      } else {
        cocktails =
            await CocktailController.getCocktailsByCategory(_selectedCategory);
      }

      setState(() {
        _cocktails = cocktails;
        _isCocktailLoading = false;
      });
    } catch (e) {
      print('Error loading cocktails: $e');
      setState(() {
        _isCocktailLoading = false;
      });
    }
  }

  Future<void> _searchCocktails(String query) async {
    setState(() {
      _isCocktailLoading = true;
    });

    try {
      final cocktails = await CocktailController.searchCocktails(query);
      setState(() {
        _cocktails = cocktails;
        _isCocktailLoading = false;
      });
    } catch (e) {
      print('Error searching cocktails: $e');
      setState(() {
        _isCocktailLoading = false;
      });
    }
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

  // Cocktail Home Page Widget
  Widget _buildCocktailHomePage() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Find Cocktails',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cocktails..',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: (value) {
                _searchCocktails(value);
              },
            ),
          ),
          SizedBox(height: 20),

          // Categories
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),

          // Category Filter
          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length > 5 ? 5 : _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category.strCategory;

                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.strCategory;
                        _searchController.clear();
                      });
                      _loadCocktails();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category.strCategory,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.blue[700] : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Cocktails Grid
          Expanded(
            child: _isCocktailLoading
                ? Center(child: CircularProgressIndicator())
                : _cocktails.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_bar, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No cocktails found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _cocktails.length,
                        itemBuilder: (context, index) {
                          final cocktail = _cocktails[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CocktailDetailScreen(cocktail: cocktail),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      cocktail.strDrinkThumb,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.local_bar,
                                              size: 50, color: Colors.grey),
                                        );
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Text(
                                        cocktail.strDrink,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  // Get current page based on selected index
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildCocktailHomePage(); // Changed from _buildHomePage()
      case 1:
        return _buildSearchPage();
      case 2:
        return ConvertScreen();
      case 3:
        return ProfileScreen(
          currentUser: _currentUser,
          onLogout: _logout,
        );
      default:
        return _buildCocktailHomePage();
    }
  }

  // Get app bar title based on current index
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Cocktails';
      case 1:
        return 'Search';
      case 2:
        return 'Convert';
      case 3:
        return 'Profile';
      default:
        return 'Cocktails';
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
      appBar: _currentIndex == 2
          ? null
          : AppBar(
              title: Text(_getAppBarTitle()),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => FavoriteCocktailsScreen()));
                  },
                ),
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
