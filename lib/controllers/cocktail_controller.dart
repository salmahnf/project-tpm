import '../models/cocktail_model.dart';
import '../services/cocktail_service.dart';

class CocktailController {
  static Future<List<CategoryModel>> getCategories() async {
    return await CocktailService.getCategories();
  }

  static Future<List<CocktailModel>> searchCocktails(String query) async {
    if (query.trim().isEmpty) {
      return await CocktailService.getRandomCocktails(count: 20);
    }
    return await CocktailService.searchCocktails(query);
  }

  static Future<List<CocktailModel>> getCocktailsByCategory(String category) async {
    return await CocktailService.getCocktailsByCategory(category);
  }

  static Future<List<CocktailModel>> getRandomCocktails() async {
    return await CocktailService.getRandomCocktails(count: 20);
  }

  static Future<CocktailModel?> getCocktailById(String id) async {
    return await CocktailService.getCocktailById(id);
  }
}