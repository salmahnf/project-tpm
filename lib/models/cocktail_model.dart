class CocktailModel {
  final String idDrink;
  final String strDrink;
  final String strDrinkThumb;
  final String? strCategory;
  final String? strAlcoholic;
  final String? strInstructions;
  final String? strGlass;
  final String? strIngredient1;
  final String? strIngredient2;
  final String? strIngredient3;
  final String? strIngredient4;
  final String? strIngredient5;
  final String? strIngredient6;
  final String? strIngredient7;
  final String? strIngredient8;
  final String? strIngredient9;
  final String? strIngredient10;
  final String? strMeasure1;
  final String? strMeasure2;
  final String? strMeasure3;
  final String? strMeasure4;
  final String? strMeasure5;
  final String? strMeasure6;
  final String? strMeasure7;
  final String? strMeasure8;
  final String? strMeasure9;
  final String? strMeasure10;

  CocktailModel({
    required this.idDrink,
    required this.strDrink,
    required this.strDrinkThumb,
    this.strCategory,
    this.strAlcoholic,
    this.strInstructions,
    this.strGlass,
    this.strIngredient1,
    this.strIngredient2,
    this.strIngredient3,
    this.strIngredient4,
    this.strIngredient5,
    this.strIngredient6,
    this.strIngredient7,
    this.strIngredient8,
    this.strIngredient9,
    this.strIngredient10,
    this.strMeasure1,
    this.strMeasure2,
    this.strMeasure3,
    this.strMeasure4,
    this.strMeasure5,
    this.strMeasure6,
    this.strMeasure7,
    this.strMeasure8,
    this.strMeasure9,
    this.strMeasure10,
  });

  factory CocktailModel.fromJson(Map<String, dynamic> json) {
    return CocktailModel(
      idDrink: json['idDrink'] ?? '',
      strDrink: json['strDrink'] ?? '',
      strDrinkThumb: json['strDrinkThumb'] ?? '',
      strCategory: json['strCategory'],
      strAlcoholic: json['strAlcoholic'],
      strInstructions: json['strInstructions'],
      strGlass: json['strGlass'],
      strIngredient1: json['strIngredient1'],
      strIngredient2: json['strIngredient2'],
      strIngredient3: json['strIngredient3'],
      strIngredient4: json['strIngredient4'],
      strIngredient5: json['strIngredient5'],
      strIngredient6: json['strIngredient6'],
      strIngredient7: json['strIngredient7'],
      strIngredient8: json['strIngredient8'],
      strIngredient9: json['strIngredient9'],
      strIngredient10: json['strIngredient10'],
      strMeasure1: json['strMeasure1'],
      strMeasure2: json['strMeasure2'],
      strMeasure3: json['strMeasure3'],
      strMeasure4: json['strMeasure4'],
      strMeasure5: json['strMeasure5'],
      strMeasure6: json['strMeasure6'],
      strMeasure7: json['strMeasure7'],
      strMeasure8: json['strMeasure8'],
      strMeasure9: json['strMeasure9'],
      strMeasure10: json['strMeasure10'],
    );
  }

  // Helper method to get ingredients list
  List<String> getIngredients() {
    List<String> ingredients = [];
    
    List<String?> ingredientList = [
      strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
      strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
    ];
    
    List<String?> measureList = [
      strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
      strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
    ];
    
    for (int i = 0; i < ingredientList.length; i++) {
      if (ingredientList[i] != null && ingredientList[i]!.trim().isNotEmpty) {
        String measure = measureList[i]?.trim() ?? '';
        String ingredient = ingredientList[i]!.trim();
        
        if (measure.isNotEmpty) {
          ingredients.add('$measure $ingredient');
        } else {
          ingredients.add(ingredient);
        }
      }
    }
    
    return ingredients;
  }
}

class CategoryModel {
  final String strCategory;

  CategoryModel({required this.strCategory});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      strCategory: json['strCategory'] ?? '',
    );
  }
}