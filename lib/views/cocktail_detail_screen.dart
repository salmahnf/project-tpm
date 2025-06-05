import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cocktail_model.dart';
import 'package:get_storage/get_storage.dart';
import '../services/session_service.dart';
import '../models/user_model.dart';


class CocktailDetailScreen extends StatefulWidget {
  final CocktailModel cocktail;

  const CocktailDetailScreen({Key? key, required this.cocktail})
      : super(key: key);

  @override
  _CocktailDetailScreenState createState() => _CocktailDetailScreenState();
}

class _CocktailDetailScreenState extends State<CocktailDetailScreen> {
  final _storage = GetStorage();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() {
    final favorites = _storage.read<List>('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.cocktail.idDrink);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.cocktail.getIngredients();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
child: IconButton(
  icon: Icon(
    _isFavorite ? Icons.favorite : Icons.favorite_border,
    color: _isFavorite ? Colors.red : Colors.black,
  ),
  onPressed: () async {
    final user = await SessionService.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to save favorites')),
      );
      return;
    }

    final key = 'favorites_${user.username}';
    final box = GetStorage();
    List<String> favorites = box.read<List>(key)?.cast<String>() ?? [];

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      favorites.add(widget.cocktail.idDrink);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites')),
      );
    } else {
      favorites.remove(widget.cocktail.idDrink);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites')),
      );
    }

    // Save updated list back to GetStorage
    box.write(key, favorites.toSet().toList());
  },
),

              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.cocktail.strDrinkThumb,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.local_bar,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cocktail Name
                  Text(
                    widget.cocktail.strDrink,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),

                  SizedBox(height: 12),

                  // Tags Row
                  Wrap(
                    spacing: 2,
                    runSpacing: 8,
                    children: [
                      if (widget.cocktail.strCategory != null) ...[
                        _buildTag(
                          widget.cocktail.strCategory!,
                          Colors.blue,
                          Icons.category,
                        ),
                        SizedBox(width: 8),
                      ],
                      if (widget.cocktail.strAlcoholic != null) ...[
                        _buildTag(
                          widget.cocktail.strAlcoholic!,
                          widget.cocktail.strAlcoholic == 'Alcoholic'
                              ? Colors.orange
                              : Colors.green,
                          widget.cocktail.strAlcoholic == 'Alcoholic'
                              ? Icons.local_bar
                              : Icons.no_drinks,
                        ),
                        SizedBox(width: 8),
                      ],
                      if (widget.cocktail.strGlass != null) ...[
                        _buildTag(
                          widget.cocktail.strGlass!,
                          Colors.purple,
                          Icons.wine_bar,
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 24),

                  // Ingredients Section
                  if (ingredients.isNotEmpty) ...[
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: ingredients.asMap().entries.map((entry) {
                          int index = entry.key;
                          String ingredient = entry.value;

                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: index < ingredients.length - 1
                                  ? Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Instructions Section
                  if (widget.cocktail.strInstructions != null &&
                      widget.cocktail.strInstructions!.trim().isNotEmpty) ...[
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'How to make',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            widget.cocktail.strInstructions!,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Action Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showShareDialog();
                      },
                      icon: Icon(Icons.share),
                      label: Text('Share Recipe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color.withOpacity(0.8),
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Recipe'),
          content: Text('Share this cocktail recipe with your friends!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recipe shared successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }
}
