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
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  int _currentIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // Cocktail related variables
  List<CocktailModel> _cocktails = [];
  List<CategoryModel> _categories = [];
  String _selectedCategory = 'All';
  TextEditingController _searchController = TextEditingController();
  bool _isCocktailLoading = false;

  // Shake variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();
  CocktailModel? _suggestedCocktail;

  // Color Theme - Brown Cream
  static const Color _primaryBrown = Color(0xFF8B4513);
  static const Color _lightBrown = Color(0xFFD2B48C);
  static const Color _cream = Color(0xFFF5F5DC);
  static const Color _darkBrown = Color(0xFF654321);
  static const Color _softCream = Color(0xFFFFFAF0);
  static const Color _accentGold = Color(0xFFDAAA00);

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadCurrentUser();
    _loadInitialData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _animationController!.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopShakeListener();
    _animationController?.dispose();
    super.dispose();
  }

  void _startShakeListener() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((event) async {
      double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration > 15 &&
          DateTime.now().difference(_lastShakeTime).inMilliseconds > 1500) {
        _lastShakeTime = DateTime.now();

        _stopShakeListener();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: _softCream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
                ),
                SizedBox(width: 20),
                Text(
                  "Finding your cocktail...",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _darkBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );

        try {
          final randomCocktail = await CocktailController.getRandomCocktails();

          if (randomCocktail.isNotEmpty) {
            final cocktail = randomCocktail.first;
            setState(() => _suggestedCocktail = cocktail);

            Navigator.of(context).pop();

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CocktailDetailScreen(cocktail: cocktail),
              ),
            );
          } else {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to get cocktail recommendation'),
                backgroundColor: _primaryBrown,
              ),
            );
          }
        } catch (e) {
          Navigator.of(context).pop();
          print('Error fetching random cocktail: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error occurred while fetching cocktail'),
              backgroundColor: _primaryBrown,
            ),
          );
        }

        _startShakeListener();
      }
    });
  }

  void _stopShakeListener() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
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

  Widget _buildShakePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_softCream, _cream],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _lightBrown.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.vibration,
                size: 80,
                color: _primaryBrown,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Shake Your Phone',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _darkBrown,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Give your phone a gentle shake to discover a delightful cocktail recommendation!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: _primaryBrown,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 40),
            if (_suggestedCocktail != null)
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _lightBrown.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '🍹 Last Recommendation',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: _primaryBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _suggestedCocktail!.strDrink,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _darkBrown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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
          backgroundColor: _softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.bold,
              color: _darkBrown,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: _primaryBrown,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _primaryBrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
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
                    backgroundColor: _primaryBrown,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCocktailHomePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_softCream, _cream],
        ),
      ),
      child: _fadeAnimation != null
          ? FadeTransition(
              opacity: _fadeAnimation!,
              child: _buildHomeContent(),
            )
          : _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _lightBrown.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _darkBrown,
                  ),
                ),
                Text(
                  'Perfect Cocktails',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: _primaryBrown,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find your favorite drinks and explore new flavors',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: _primaryBrown.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _lightBrown.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: _darkBrown,
              ),
              decoration: InputDecoration(
                hintText: 'Search cocktails...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: _lightBrown,
                ),
                prefixIcon: Icon(Icons.search, color: _primaryBrown),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: (value) {
                _searchCocktails(value);
              },
            ),
          ),
          SizedBox(height: 24),

          // Categories
          Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _darkBrown,
            ),
          ),
          SizedBox(height: 16),

          // Category Filter
          Container(
            height: 45,
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
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [_primaryBrown, _darkBrown],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? _primaryBrown : _lightBrown,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _primaryBrown.withOpacity(0.3)
                                : _lightBrown.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category.strCategory,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isSelected ? Colors.white : _primaryBrown,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),

          // Cocktails Grid
          Expanded(
            child: _isCocktailLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
                    ),
                  )
                : _cocktails.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _lightBrown.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_bar,
                                size: 48,
                                color: _primaryBrown,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No cocktails found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: _primaryBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                            child: Hero(
                              tag: 'cocktail-${cocktail.idDrink}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _lightBrown.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        cocktail.strDrinkThumb,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: _cream,
                                            child: Icon(
                                              Icons.local_bar,
                                              size: 50,
                                              color: _primaryBrown,
                                            ),
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
                                              _darkBrown.withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cocktail.strDrink,
                                              style: TextStyle(
                                                fontFamily: 'PlayfairDisplay',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _accentGold
                                                    .withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'View Recipe',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildCocktailHomePage();
      case 1:
        return _buildShakePage();
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

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Cocktails';
      case 1:
        return 'Shake';
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
        backgroundColor: _softCream,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _softCream,
      appBar: _currentIndex == 2
          ? null
          : AppBar(
              title: Text(
                _getAppBarTitle(),
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              backgroundColor: _primaryBrown,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_primaryBrown, _darkBrown],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite_rounded),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => FavoriteCocktailsScreen()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout_rounded),
                  onPressed: _logout,
                ),
              ],
            ),
      body: _getCurrentPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _lightBrown.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) {
                _startShakeListener();
              } else {
                _stopShakeListener();
              }
            });
          },
          selectedItemColor: _primaryBrown,
          unselectedItemColor: _lightBrown,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.vibration_rounded),
              label: 'Shake',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: 'Convert',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
