part of '../models.dart';

@Model()
abstract class Restaurant {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get name;
  String get adress;
  String get deliveryFee;
  String get deliveryTime;
  String get bannerImageUrl;
  String get logoImageUrl;
  List<Tag> get tags;
  List<Rating> get ratings;
}
