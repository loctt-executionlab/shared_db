part of '../models.dart';

@Model()
abstract class FoodAddon {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get name;
  String get description;
  double get price;
}
