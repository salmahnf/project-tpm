import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cocktail_model.dart';
import '../services/cocktail_service.dart';
import 'cocktail_detail_screen.dart';
import '../services/session_service.dart';
import '../models/user_model.dart';

class FavoriteCocktailsScreen extends StatefulWidget {
  const FavoriteCocktailsScreen({Key? key}) : super(key: key);

  @override
  _FavoriteCocktailsScreenState createState() =>
      _FavoriteCocktailsScreenState();
}

class _FavoriteCocktailsScreenState extends State<FavoriteCocktailsScreen>
    with TickerProviderStateMixin {
  final _storage = GetStorage();
  late Future<List<CocktailModel>> _favoritesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Color palette coklat cream
  static const Color primaryBrown = Color(0xFF8B4513);
  static const Color lightBrown = Color(0xFFD2B48C);
  static const Color cream = Color(0xFFF5F5DC);
  static const Color darkCream = Color(0xFFE6DDD4);
  static const Color coffeeColor = Color(0xFF6F4E37);
  static const Color lightCoffee = Color(0xFFA0826D);

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavoritesForCurrentUser();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<CocktailModel>> _loadFavoritesForCurrentUser() async {
    final user = await SessionService.getCurrentUser();
    if (user == null) return [];

    final key = 'favorites_${user.username}';
    final ids = _storage.read<List>(key)?.cast<String>() ?? [];

    List<CocktailModel> cocktails = [];
    for (String id in ids) {
      final cocktail = await CocktailService.getCocktailById(id);
      if (cocktail != null) {
        cocktails.add(cocktail);
      }
    }

    return cocktails;
  }

  Future<void> _clearFavorites() async {
    final shouldClear = await _showClearConfirmationDialog();
    if (!shouldClear) return;

    final user = await SessionService.getCurrentUser();
    if (user == null) return;

    final key = 'favorites_${user.username}';
    _storage.remove(key);
    setState(() {
      _favoritesFuture = Future.value([]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Favorites cleared successfully',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
        backgroundColor: primaryBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<bool> _showClearConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'Clear Favorites?',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to remove all favorite cocktails? This action cannot be undone.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: coffeeColor,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: coffeeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cream.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: lightBrown.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: primaryBrown),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_sweep_rounded,
                      color: Colors.red.shade600),
                  onPressed: _clearFavorites,
                  tooltip: 'Clear all favorites',
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Favorite Cocktails',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFAF7F2),
                      Color(0xFFFAF7F2).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FutureBuilder<List<CocktailModel>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final favorites = snapshot.data ?? [];

                  if (favorites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildFavoritesList(favorites);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cream,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: lightBrown.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading your favorites...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: coffeeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cream,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: lightBrown.withOpacity(0.2),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: lightBrown,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Start exploring cocktails and add them to your favorites to see them here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: coffeeColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBrown, coffeeColor],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBrown.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Explore Cocktails',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<CocktailModel> favorites) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cream, darkCream],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lightBrown.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded,
                    color: Colors.red.shade400, size: 20),
                SizedBox(width: 8),
                Text(
                  '${favorites.length} Favorite${favorites.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: primaryBrown,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cocktail = favorites[index];
              return _buildCocktailCard(cocktail, index);
            },
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCocktailCard(CocktailModel cocktail, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, cream.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: lightBrown.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: lightBrown.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CocktailDetailScreen(cocktail: cocktail),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Cocktail Image
                Hero(
                  tag: 'cocktail_${cocktail.idDrink}_$index',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: lightBrown.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        cocktail.strDrinkThumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: lightBrown.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.local_bar_rounded,
                            color: primaryBrown,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Cocktail Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cocktail.strDrink,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (cocktail.strCategory?.isNotEmpty == true)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: lightBrown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cocktail.strCategory!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: coffeeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Favorite Icon and Arrow
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: lightBrown,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
