part of '../models.dart';

@Model()
abstract class User {
  @PrimaryKey()
  @AutoIncrement()
  int get id;

  String get email;
  String get password;
  String get name;
  String get phoneNumber;
}
