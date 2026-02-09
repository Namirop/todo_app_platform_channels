import 'package:todoapp/domain/entities/user.dart';

abstract class UsersRepository {
  Future<List<UserEntity>> searchUsers(String query);
}
