part of '../models.dart';

@Model()
abstract class Food {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get name;

  String get imageUrl;

  String get descriptionShort;

  String get descriptionExtended;

  double get price;

  List<Rating> get ratings;

  List<FoodAddon> get addons;
}
