import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cocktail_model.dart';

class CocktailService {
  static const String baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';

  // Get all categories
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list.php?c=list'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> drinks = data['drinks'] ?? [];
        
        return drinks.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Search cocktails by name
  static Future<List<CocktailModel>> searchCocktails(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? drinks = data['drinks'];
        
        if (drinks != null) {
          return drinks.map((json) => CocktailModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to search cocktails');
      }
    } catch (e) {
      print('Error searching cocktails: $e');
      return [];
    }
  }

  // Get cocktails by category
  static Future<List<CocktailModel>> getCocktailsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? drinks = data['drinks'];
        
        if (drinks != null) {
          return drinks.map((json) => CocktailModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load cocktails by category');
      }
    } catch (e) {
      print('Error fetching cocktails by category: $e');
      return [];
    }
  }

  // Get random cocktails
  static Future<List<CocktailModel>> getRandomCocktails({int count = 10}) async {
    try {
      List<CocktailModel> cocktails = [];
      
      for (int i = 0; i < count; i++) {
        final response = await http.get(Uri.parse('$baseUrl/random.php'));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic>? drinks = data['drinks'];
          
          if (drinks != null && drinks.isNotEmpty) {
            cocktails.add(CocktailModel.fromJson(drinks[0]));
          }
        }
      }
      
      return cocktails;
    } catch (e) {
      print('Error fetching random cocktails: $e');
      return [];
    }
  }

  // Get cocktail details by ID
  static Future<CocktailModel?> getCocktailById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? drinks = data['drinks'];
        
        if (drinks != null && drinks.isNotEmpty) {
          return CocktailModel.fromJson(drinks[0]);
        }
        return null;
      } else {
        throw Exception('Failed to load cocktail details');
      }
    } catch (e) {
      print('Error fetching cocktail details: $e');
      return null;
    }
  }
}
