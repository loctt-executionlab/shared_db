part of '../models.dart';

@Model()
abstract class Rating {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get userId;
  String get userName;
  String get content;
  double get rating;
}
