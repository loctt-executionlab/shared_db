// ignore_for_file: prefer_relative_imports
import 'package:stormberry/internals.dart';

import 'models.dart';

extension Repositories on Database {
  FoodAddonRepository get foodAddons => FoodAddonRepository._(this);
  RatingRepository get ratings => RatingRepository._(this);
  UserRepository get users => UserRepository._(this);
  FoodRepository get foods => FoodRepository._(this);
}

final registry = ModelRegistry({});

abstract class FoodAddonRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<FoodAddonInsertRequest>,
        ModelRepositoryUpdate<FoodAddonUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory FoodAddonRepository._(Database db) = _FoodAddonRepository;

  Future<FoodAddon?> queryFoodAddon(int id);
  Future<List<FoodAddon>> queryFoodAddons([QueryParams? params]);
}

class _FoodAddonRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<FoodAddonInsertRequest>,
        RepositoryUpdateMixin<FoodAddonUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements FoodAddonRepository {
  _FoodAddonRepository(Database db) : super(db: db);

  @override
  Future<FoodAddon?> queryFoodAddon(int id) {
    return queryOne(id, FoodAddonQueryable());
  }

  @override
  Future<List<FoodAddon>> queryFoodAddons([QueryParams? params]) {
    return queryMany(FoodAddonQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<FoodAddonInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows =
        await db.query(requests.map((r) => "SELECT nextval('food_addons_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "food_addons" ( "food_id", "id", "name", "description", "price" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.name)}, ${registry.encode(r.description)}, ${registry.encode(r.price)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<FoodAddonUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "food_addons"\n'
      'SET "food_id" = COALESCE(UPDATED."food_id"::int8, "food_addons"."food_id"), "name" = COALESCE(UPDATED."name"::text, "food_addons"."name"), "description" = COALESCE(UPDATED."description"::text, "food_addons"."description"), "price" = COALESCE(UPDATED."price"::float8, "food_addons"."price")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(r.id)}, ${registry.encode(r.name)}, ${registry.encode(r.description)}, ${registry.encode(r.price)} )').join(', ')} )\n'
      'AS UPDATED("food_id", "id", "name", "description", "price")\n'
      'WHERE "food_addons"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "food_addons"\n'
      'WHERE "food_addons"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

abstract class RatingRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<RatingInsertRequest>,
        ModelRepositoryUpdate<RatingUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory RatingRepository._(Database db) = _RatingRepository;

  Future<Rating?> queryRating(int id);
  Future<List<Rating>> queryRatings([QueryParams? params]);
}

class _RatingRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<RatingInsertRequest>,
        RepositoryUpdateMixin<RatingUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements RatingRepository {
  _RatingRepository(Database db) : super(db: db);

  @override
  Future<Rating?> queryRating(int id) {
    return queryOne(id, RatingQueryable());
  }

  @override
  Future<List<Rating>> queryRatings([QueryParams? params]) {
    return queryMany(RatingQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<RatingInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows = await db.query(requests.map((r) => "SELECT nextval('ratings_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "ratings" ( "food_id", "id", "user_id", "user_name", "content", "rating" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.userId)}, ${registry.encode(r.userName)}, ${registry.encode(r.content)}, ${registry.encode(r.rating)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<RatingUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "ratings"\n'
      'SET "food_id" = COALESCE(UPDATED."food_id"::int8, "ratings"."food_id"), "user_id" = COALESCE(UPDATED."user_id"::text, "ratings"."user_id"), "user_name" = COALESCE(UPDATED."user_name"::text, "ratings"."user_name"), "content" = COALESCE(UPDATED."content"::text, "ratings"."content"), "rating" = COALESCE(UPDATED."rating"::float8, "ratings"."rating")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(r.id)}, ${registry.encode(r.userId)}, ${registry.encode(r.userName)}, ${registry.encode(r.content)}, ${registry.encode(r.rating)} )').join(', ')} )\n'
      'AS UPDATED("food_id", "id", "user_id", "user_name", "content", "rating")\n'
      'WHERE "ratings"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "ratings"\n'
      'WHERE "ratings"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

abstract class UserRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<UserInsertRequest>,
        ModelRepositoryUpdate<UserUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory UserRepository._(Database db) = _UserRepository;

  Future<User?> queryUser(int id);
  Future<List<User>> queryUsers([QueryParams? params]);
}

class _UserRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<UserInsertRequest>,
        RepositoryUpdateMixin<UserUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements UserRepository {
  _UserRepository(Database db) : super(db: db);

  @override
  Future<User?> queryUser(int id) {
    return queryOne(id, UserQueryable());
  }

  @override
  Future<List<User>> queryUsers([QueryParams? params]) {
    return queryMany(UserQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<UserInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows = await db.query(requests.map((r) => "SELECT nextval('users_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "users" ( "id", "email", "password", "name", "phone_number" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.email)}, ${registry.encode(r.password)}, ${registry.encode(r.name)}, ${registry.encode(r.phoneNumber)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<UserUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "users"\n'
      'SET "email" = COALESCE(UPDATED."email"::text, "users"."email"), "password" = COALESCE(UPDATED."password"::text, "users"."password"), "name" = COALESCE(UPDATED."name"::text, "users"."name"), "phone_number" = COALESCE(UPDATED."phone_number"::text, "users"."phone_number")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.id)}, ${registry.encode(r.email)}, ${registry.encode(r.password)}, ${registry.encode(r.name)}, ${registry.encode(r.phoneNumber)} )').join(', ')} )\n'
      'AS UPDATED("id", "email", "password", "name", "phone_number")\n'
      'WHERE "users"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "users"\n'
      'WHERE "users"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

abstract class FoodRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<FoodInsertRequest>,
        ModelRepositoryUpdate<FoodUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory FoodRepository._(Database db) = _FoodRepository;

  Future<Food?> queryFood(int id);
  Future<List<Food>> queryFoods([QueryParams? params]);
}

class _FoodRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<FoodInsertRequest>,
        RepositoryUpdateMixin<FoodUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements FoodRepository {
  _FoodRepository(Database db) : super(db: db);

  @override
  Future<Food?> queryFood(int id) {
    return queryOne(id, FoodQueryable());
  }

  @override
  Future<List<Food>> queryFoods([QueryParams? params]) {
    return queryMany(FoodQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<FoodInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows = await db.query(requests.map((r) => "SELECT nextval('foods_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "foods" ( "id", "name", "image_url", "description_short", "description_extended", "price" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.name)}, ${registry.encode(r.imageUrl)}, ${registry.encode(r.descriptionShort)}, ${registry.encode(r.descriptionExtended)}, ${registry.encode(r.price)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<FoodUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "foods"\n'
      'SET "name" = COALESCE(UPDATED."name"::text, "foods"."name"), "image_url" = COALESCE(UPDATED."image_url"::text, "foods"."image_url"), "description_short" = COALESCE(UPDATED."description_short"::text, "foods"."description_short"), "description_extended" = COALESCE(UPDATED."description_extended"::text, "foods"."description_extended"), "price" = COALESCE(UPDATED."price"::float8, "foods"."price")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.id)}, ${registry.encode(r.name)}, ${registry.encode(r.imageUrl)}, ${registry.encode(r.descriptionShort)}, ${registry.encode(r.descriptionExtended)}, ${registry.encode(r.price)} )').join(', ')} )\n'
      'AS UPDATED("id", "name", "image_url", "description_short", "description_extended", "price")\n'
      'WHERE "foods"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "foods"\n'
      'WHERE "foods"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

class FoodAddonInsertRequest {
  FoodAddonInsertRequest({this.foodId, required this.name, required this.description, required this.price});
  int? foodId;
  String name;
  String description;
  double price;
}

class RatingInsertRequest {
  RatingInsertRequest(
      {this.foodId, required this.userId, required this.userName, required this.content, required this.rating});
  int? foodId;
  String userId;
  String userName;
  String content;
  double rating;
}

class UserInsertRequest {
  UserInsertRequest({required this.email, required this.password, required this.name, required this.phoneNumber});
  String email;
  String password;
  String name;
  String phoneNumber;
}

class FoodInsertRequest {
  FoodInsertRequest(
      {required this.name,
      required this.imageUrl,
      required this.descriptionShort,
      required this.descriptionExtended,
      required this.price});
  String name;
  String imageUrl;
  String descriptionShort;
  String descriptionExtended;
  double price;
}

class FoodAddonUpdateRequest {
  FoodAddonUpdateRequest({this.foodId, required this.id, this.name, this.description, this.price});
  int? foodId;
  int id;
  String? name;
  String? description;
  double? price;
}

class RatingUpdateRequest {
  RatingUpdateRequest({this.foodId, required this.id, this.userId, this.userName, this.content, this.rating});
  int? foodId;
  int id;
  String? userId;
  String? userName;
  String? content;
  double? rating;
}

class UserUpdateRequest {
  UserUpdateRequest({required this.id, this.email, this.password, this.name, this.phoneNumber});
  int id;
  String? email;
  String? password;
  String? name;
  String? phoneNumber;
}

class FoodUpdateRequest {
  FoodUpdateRequest(
      {required this.id, this.name, this.imageUrl, this.descriptionShort, this.descriptionExtended, this.price});
  int id;
  String? name;
  String? imageUrl;
  String? descriptionShort;
  String? descriptionExtended;
  double? price;
}

class FoodAddonQueryable extends KeyedViewQueryable<FoodAddon, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'food_addons_view';

  @override
  String get tableAlias => 'food_addons';

  @override
  FoodAddon decode(TypedMap map) => FoodAddonView(
      id: map.get('id', registry.decode),
      name: map.get('name', registry.decode),
      description: map.get('description', registry.decode),
      price: map.get('price', registry.decode));
}

class FoodAddonView implements FoodAddon {
  FoodAddonView({required this.id, required this.name, required this.description, required this.price});

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
}

class RatingQueryable extends KeyedViewQueryable<Rating, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'ratings_view';

  @override
  String get tableAlias => 'ratings';

  @override
  Rating decode(TypedMap map) => RatingView(
      id: map.get('id', registry.decode),
      userId: map.get('user_id', registry.decode),
      userName: map.get('user_name', registry.decode),
      content: map.get('content', registry.decode),
      rating: map.get('rating', registry.decode));
}

class RatingView implements Rating {
  RatingView(
      {required this.id, required this.userId, required this.userName, required this.content, required this.rating});

  @override
  final int id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String content;
  @override
  final double rating;
}

class UserQueryable extends KeyedViewQueryable<User, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'users_view';

  @override
  String get tableAlias => 'users';

  @override
  User decode(TypedMap map) => UserView(
      id: map.get('id', registry.decode),
      email: map.get('email', registry.decode),
      password: map.get('password', registry.decode),
      name: map.get('name', registry.decode),
      phoneNumber: map.get('phone_number', registry.decode));
}

class UserView implements User {
  UserView(
      {required this.id, required this.email, required this.password, required this.name, required this.phoneNumber});

  @override
  final int id;
  @override
  final String email;
  @override
  final String password;
  @override
  final String name;
  @override
  final String phoneNumber;
}

class FoodQueryable extends KeyedViewQueryable<Food, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'foods_view';

  @override
  String get tableAlias => 'foods';

  @override
  Food decode(TypedMap map) => FoodView(
      id: map.get('id', registry.decode),
      name: map.get('name', registry.decode),
      imageUrl: map.get('image_url', registry.decode),
      descriptionShort: map.get('description_short', registry.decode),
      descriptionExtended: map.get('description_extended', registry.decode),
      price: map.get('price', registry.decode),
      ratings: map.getListOpt('ratings', RatingQueryable().decoder) ?? const [],
      addons: map.getListOpt('addons', FoodAddonQueryable().decoder) ?? const []);
}

class FoodView implements Food {
  FoodView(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.descriptionShort,
      required this.descriptionExtended,
      required this.price,
      required this.ratings,
      required this.addons});

  @override
  final int id;
  @override
  final String name;
  @override
  final String imageUrl;
  @override
  final String descriptionShort;
  @override
  final String descriptionExtended;
  @override
  final double price;
  @override
  final List<Rating> ratings;
  @override
  final List<FoodAddon> addons;
}
