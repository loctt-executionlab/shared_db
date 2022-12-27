part of '../models.dart';

@Model()
abstract class Tag {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get name;
  List<Restaurant> get restaurants;
}
