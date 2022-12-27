part of '../models.dart';

@Model(views: [
  View('Base', [Field.view('restaurants', as: 'Reduced')]),
  View('Info', [
    Field.hidden('restaurants'),
  ]),
])
abstract class Tag {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get name;
  List<Restaurant> get restaurants;
}
