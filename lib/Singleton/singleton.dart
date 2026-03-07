import 'package:ecom_app/Model/userModel';

class UserSingleton {
  static final UserSingleton _instance = UserSingleton._internal();
  factory UserSingleton() => _instance;

  UserSingleton._internal();

  UserModel? userModel;

  void clear() {
    userModel = null;
  }
}
