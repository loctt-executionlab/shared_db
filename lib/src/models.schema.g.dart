// ignore_for_file: prefer_relative_imports
import 'package:stormberry/internals.dart';

import 'models.dart';

extension Repositories on Database {
  FoodAddonRepository get foodAddons => FoodAddonRepository._(this);
  RatingRepository get ratings => RatingRepository._(this);
  UserRepository get users => UserRepository._(this);
  FoodRepository get foods => FoodRepository._(this);
  RestaurantRepository get restaurants => RestaurantRepository._(this);
  TagRepository get tags => TagRepository._(this);
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
      'INSERT INTO "ratings" ( "food_id", "restaurant_id", "id", "user_id", "user_name", "content", "rating" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(r.restaurantId)}, ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.userId)}, ${registry.encode(r.userName)}, ${registry.encode(r.content)}, ${registry.encode(r.rating)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<RatingUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "ratings"\n'
      'SET "food_id" = COALESCE(UPDATED."food_id"::int8, "ratings"."food_id"), "restaurant_id" = COALESCE(UPDATED."restaurant_id"::int8, "ratings"."restaurant_id"), "user_id" = COALESCE(UPDATED."user_id"::text, "ratings"."user_id"), "user_name" = COALESCE(UPDATED."user_name"::text, "ratings"."user_name"), "content" = COALESCE(UPDATED."content"::text, "ratings"."content"), "rating" = COALESCE(UPDATED."rating"::float8, "ratings"."rating")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.foodId)}, ${registry.encode(r.restaurantId)}, ${registry.encode(r.id)}, ${registry.encode(r.userId)}, ${registry.encode(r.userName)}, ${registry.encode(r.content)}, ${registry.encode(r.rating)} )').join(', ')} )\n'
      'AS UPDATED("food_id", "restaurant_id", "id", "user_id", "user_name", "content", "rating")\n'
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

abstract class RestaurantRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<RestaurantInsertRequest>,
        ModelRepositoryUpdate<RestaurantUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory RestaurantRepository._(Database db) = _RestaurantRepository;

  Future<BaseRestaurantView?> queryBaseView(int id);
  Future<List<BaseRestaurantView>> queryBaseViews([QueryParams? params]);
  Future<ReducedRestaurantView?> queryReducedView(int id);
  Future<List<ReducedRestaurantView>> queryReducedViews([QueryParams? params]);
}

class _RestaurantRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<RestaurantInsertRequest>,
        RepositoryUpdateMixin<RestaurantUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements RestaurantRepository {
  _RestaurantRepository(Database db) : super(db: db);

  @override
  Future<BaseRestaurantView?> queryBaseView(int id) {
    return queryOne(id, BaseRestaurantViewQueryable());
  }

  @override
  Future<List<BaseRestaurantView>> queryBaseViews([QueryParams? params]) {
    return queryMany(BaseRestaurantViewQueryable(), params);
  }

  @override
  Future<ReducedRestaurantView?> queryReducedView(int id) {
    return queryOne(id, ReducedRestaurantViewQueryable());
  }

  @override
  Future<List<ReducedRestaurantView>> queryReducedViews([QueryParams? params]) {
    return queryMany(ReducedRestaurantViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<RestaurantInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows =
        await db.query(requests.map((r) => "SELECT nextval('restaurants_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "restaurants" ( "id", "name", "adress", "delivery_fee", "delivery_time", "banner_image_url", "logo_image_url" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.name)}, ${registry.encode(r.adress)}, ${registry.encode(r.deliveryFee)}, ${registry.encode(r.deliveryTime)}, ${registry.encode(r.bannerImageUrl)}, ${registry.encode(r.logoImageUrl)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<RestaurantUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "restaurants"\n'
      'SET "name" = COALESCE(UPDATED."name"::text, "restaurants"."name"), "adress" = COALESCE(UPDATED."adress"::text, "restaurants"."adress"), "delivery_fee" = COALESCE(UPDATED."delivery_fee"::text, "restaurants"."delivery_fee"), "delivery_time" = COALESCE(UPDATED."delivery_time"::text, "restaurants"."delivery_time"), "banner_image_url" = COALESCE(UPDATED."banner_image_url"::text, "restaurants"."banner_image_url"), "logo_image_url" = COALESCE(UPDATED."logo_image_url"::text, "restaurants"."logo_image_url")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.id)}, ${registry.encode(r.name)}, ${registry.encode(r.adress)}, ${registry.encode(r.deliveryFee)}, ${registry.encode(r.deliveryTime)}, ${registry.encode(r.bannerImageUrl)}, ${registry.encode(r.logoImageUrl)} )').join(', ')} )\n'
      'AS UPDATED("id", "name", "adress", "delivery_fee", "delivery_time", "banner_image_url", "logo_image_url")\n'
      'WHERE "restaurants"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "restaurants"\n'
      'WHERE "restaurants"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

abstract class TagRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<TagInsertRequest>,
        ModelRepositoryUpdate<TagUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory TagRepository._(Database db) = _TagRepository;

  Future<BaseTagView?> queryBaseView(int id);
  Future<List<BaseTagView>> queryBaseViews([QueryParams? params]);
  Future<InfoTagView?> queryInfoView(int id);
  Future<List<InfoTagView>> queryInfoViews([QueryParams? params]);
}

class _TagRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<TagInsertRequest>,
        RepositoryUpdateMixin<TagUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements TagRepository {
  _TagRepository(Database db) : super(db: db);

  @override
  Future<BaseTagView?> queryBaseView(int id) {
    return queryOne(id, BaseTagViewQueryable());
  }

  @override
  Future<List<BaseTagView>> queryBaseViews([QueryParams? params]) {
    return queryMany(BaseTagViewQueryable(), params);
  }

  @override
  Future<InfoTagView?> queryInfoView(int id) {
    return queryOne(id, InfoTagViewQueryable());
  }

  @override
  Future<List<InfoTagView>> queryInfoViews([QueryParams? params]) {
    return queryMany(InfoTagViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<TagInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows = await db.query(requests.map((r) => "SELECT nextval('tags_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "tags" ( "id", "name" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.name)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<TagUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "tags"\n'
      'SET "name" = COALESCE(UPDATED."name"::text, "tags"."name")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.id)}, ${registry.encode(r.name)} )').join(', ')} )\n'
      'AS UPDATED("id", "name")\n'
      'WHERE "tags"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "tags"\n'
      'WHERE "tags"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
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
      {this.foodId,
      this.restaurantId,
      required this.userId,
      required this.userName,
      required this.content,
      required this.rating});
  int? foodId;
  int? restaurantId;
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

class RestaurantInsertRequest {
  RestaurantInsertRequest(
      {required this.name,
      required this.adress,
      required this.deliveryFee,
      required this.deliveryTime,
      required this.bannerImageUrl,
      required this.logoImageUrl});
  String name;
  String adress;
  String deliveryFee;
  String deliveryTime;
  String bannerImageUrl;
  String logoImageUrl;
}

class TagInsertRequest {
  TagInsertRequest({required this.name});
  String name;
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
  RatingUpdateRequest(
      {this.foodId, this.restaurantId, required this.id, this.userId, this.userName, this.content, this.rating});
  int? foodId;
  int? restaurantId;
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

class RestaurantUpdateRequest {
  RestaurantUpdateRequest(
      {required this.id,
      this.name,
      this.adress,
      this.deliveryFee,
      this.deliveryTime,
      this.bannerImageUrl,
      this.logoImageUrl});
  int id;
  String? name;
  String? adress;
  String? deliveryFee;
  String? deliveryTime;
  String? bannerImageUrl;
  String? logoImageUrl;
}

class TagUpdateRequest {
  TagUpdateRequest({required this.id, this.name});
  int id;
  String? name;
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

class BaseRestaurantViewQueryable extends KeyedViewQueryable<BaseRestaurantView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'base_restaurants_view';

  @override
  String get tableAlias => 'restaurants';

  @override
  BaseRestaurantView decode(TypedMap map) => BaseRestaurantView(
      id: map.get('id', registry.decode),
      name: map.get('name', registry.decode),
      adress: map.get('adress', registry.decode),
      deliveryFee: map.get('delivery_fee', registry.decode),
      deliveryTime: map.get('delivery_time', registry.decode),
      bannerImageUrl: map.get('banner_image_url', registry.decode),
      logoImageUrl: map.get('logo_image_url', registry.decode),
      tags: map.getListOpt('tags', InfoTagViewQueryable().decoder) ?? const [],
      ratings: map.getListOpt('ratings', RatingQueryable().decoder) ?? const []);
}

class BaseRestaurantView {
  BaseRestaurantView(
      {required this.id,
      required this.name,
      required this.adress,
      required this.deliveryFee,
      required this.deliveryTime,
      required this.bannerImageUrl,
      required this.logoImageUrl,
      required this.tags,
      required this.ratings});

  final int id;
  final String name;
  final String adress;
  final String deliveryFee;
  final String deliveryTime;
  final String bannerImageUrl;
  final String logoImageUrl;
  final List<InfoTagView> tags;
  final List<Rating> ratings;
}

class ReducedRestaurantViewQueryable extends KeyedViewQueryable<ReducedRestaurantView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'reduced_restaurants_view';

  @override
  String get tableAlias => 'restaurants';

  @override
  ReducedRestaurantView decode(TypedMap map) => ReducedRestaurantView(
      id: map.get('id', registry.decode),
      name: map.get('name', registry.decode),
      adress: map.get('adress', registry.decode),
      deliveryFee: map.get('delivery_fee', registry.decode),
      deliveryTime: map.get('delivery_time', registry.decode),
      bannerImageUrl: map.get('banner_image_url', registry.decode),
      logoImageUrl: map.get('logo_image_url', registry.decode),
      ratings: map.getListOpt('ratings', RatingQueryable().decoder) ?? const []);
}

class ReducedRestaurantView {
  ReducedRestaurantView(
      {required this.id,
      required this.name,
      required this.adress,
      required this.deliveryFee,
      required this.deliveryTime,
      required this.bannerImageUrl,
      required this.logoImageUrl,
      required this.ratings});

  final int id;
  final String name;
  final String adress;
  final String deliveryFee;
  final String deliveryTime;
  final String bannerImageUrl;
  final String logoImageUrl;
  final List<Rating> ratings;
}

class BaseTagViewQueryable extends KeyedViewQueryable<BaseTagView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'base_tags_view';

  @override
  String get tableAlias => 'tags';

  @override
  BaseTagView decode(TypedMap map) => BaseTagView(
      restaurants: map.getListOpt('restaurants', ReducedRestaurantViewQueryable().decoder) ?? const [],
      id: map.get('id', registry.decode),
      name: map.get('name', registry.decode));
}

class BaseTagView {
  BaseTagView({required this.restaurants, required this.id, required this.name});

  final List<ReducedRestaurantView> restaurants;
  final int id;
  final String name;
}

class InfoTagViewQueryable extends KeyedViewQueryable<InfoTagView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'info_tags_view';

  @override
  String get tableAlias => 'tags';

  @override
  InfoTagView decode(TypedMap map) =>
      InfoTagView(id: map.get('id', registry.decode), name: map.get('name', registry.decode));
}

class InfoTagView {
  InfoTagView({required this.id, required this.name});

  final int id;
  final String name;
}
