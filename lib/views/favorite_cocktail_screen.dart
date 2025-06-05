import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cocktail_model.dart';
import '../services/cocktail_service.dart';
import 'cocktail_detail_screen.dart';

class FavoriteCocktailsScreen extends StatefulWidget {
  const FavoriteCocktailsScreen({Key? key}) : super(key: key);

  @override
  _FavoriteCocktailsScreenState createState() =>
      _FavoriteCocktailsScreenState();
}

class _FavoriteCocktailsScreenState extends State<FavoriteCocktailsScreen> {
  final _storage = GetStorage();
  late Future<List<CocktailModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavoriteCocktails();
  }

  Future<List<CocktailModel>> _loadFavoriteCocktails() async {
    final ids = _storage.read<List>('favorites')?.cast<String>() ?? [];
    List<CocktailModel> cocktails = [];

    for (String id in ids) {
      final cocktail = await CocktailService.getCocktailById(id);
      if (cocktail != null) {
        cocktails.add(cocktail);
      }
    }

    return cocktails;
  }

  void _clearFavorites() {
    _storage.remove('favorites');
    setState(() {
      _favoritesFuture = Future.value([]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Favorites cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cocktails'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _clearFavorites,
          ),
        ],
      ),
      body: FutureBuilder<List<CocktailModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(child: Text('No favorite cocktails yet.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final cocktail = favorites[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cocktail.strDrinkThumb,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.local_bar),
                  ),
                ),
                title: Text(cocktail.strDrink),
                subtitle: Text(cocktail.strCategory ?? ''),
                trailing: Icon(Icons.favorite, color: Colors.red),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CocktailDetailScreen(cocktail: cocktail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
