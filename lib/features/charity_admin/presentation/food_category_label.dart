import 'package:alkhair_app/core/constants/enums.dart';

/// FoodCategory -> Arabic label, shared across the recent-donations table
/// (Screen 6), the category report (Screens 9/10/12), and the PDF export —
/// previously duplicated as a private `_categoryLabel` in
/// `recent_donations_table.dart`.
String foodCategoryLabel(FoodCategory c) => switch (c) {
      FoodCategory.mainMeals => 'وجبات رئيسية',
      FoodCategory.bakedGoods => 'مخبوزات',
      FoodCategory.fruitsAndVegetables => 'فواكه وخضروات',
      FoodCategory.canned => 'معلبات',
      FoodCategory.other => 'أخرى',
    };
