import 'package:ecom_app/Model/userModel';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> _fetchProfileRow(String userId) async {
    try {
      return await _client
          .from('profiles')
          .select('full_name,email,phone_number,role')
          .eq('id', userId)
          .maybeSingle();
    } on PostgrestException {
      // Backward compatibility for old schema variants.
      return await _client
          .from('profiles')
          .select('name,email,phoneNumber')
          .eq('id', userId)
          .maybeSingle();
    }
  }

  Future<void> _upsertProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'customer',
      });
    } on PostgrestException {
      // Backward compatibility for old schema variants.
      await _client.from('profiles').upsert({
        'id': userId,
        'name': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  UserModel _toUserModel({
    required String uid,
    required String fallbackEmail,
    required Map<String, dynamic>? row,
    required Map<String, dynamic>? userMetadata,
  }) {
    final fullName = (row?['full_name'] ??
            row?['name'] ??
            userMetadata?['full_name'] ??
            userMetadata?['name'] ??
            '') as String;

    final email = (row?['email'] ?? fallbackEmail) as String;

    final phone = (row?['phone_number'] ??
            row?['phoneNumber'] ??
            userMetadata?['phone_number'] ??
            userMetadata?['phoneNumber'] ??
            '') as String;

    return UserModel(
      uid: uid,
      name: fullName,
      email: email,
      phoneNumber: phone,
    );
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'role': 'customer',
      },
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Signup completed but user is null. Verify email and retry login.');
    }

    await _upsertProfile(
      userId: user.id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );

    return _toUserModel(
      uid: user.id,
      fallbackEmail: email,
      row: {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
      },
      userMetadata: user.userMetadata,
    );
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Invalid credentials');
    }

    final profile = await _fetchProfileRow(user.id);

    if (profile == null) {
      final name = (user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              '') as String;
      final phone = (user.userMetadata?['phone_number'] ??
              user.userMetadata?['phoneNumber'] ??
              '') as String;

      await _upsertProfile(
        userId: user.id,
        fullName: name,
        email: email,
        phoneNumber: phone,
      );

      return _toUserModel(
        uid: user.id,
        fallbackEmail: email,
        row: null,
        userMetadata: user.userMetadata,
      );
    }

    return _toUserModel(
      uid: user.id,
      fallbackEmail: email,
      row: profile,
      userMetadata: user.userMetadata,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> currentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final profile = await _fetchProfileRow(user.id);

    if (profile == null) {
      return _toUserModel(
        uid: user.id,
        fallbackEmail: user.email ?? '',
        row: null,
        userMetadata: user.userMetadata,
      );
    }

    return _toUserModel(
      uid: user.id,
      fallbackEmail: user.email ?? '',
      row: profile,
      userMetadata: user.userMetadata,
    );
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('No active user session');
    }

    await _upsertProfile(
      userId: user.id,
      fullName: name,
      email: email,
      phoneNumber: phoneNumber,
    );

    return _toUserModel(
      uid: user.id,
      fallbackEmail: email,
      row: {
        'full_name': name,
        'email': email,
        'phone_number': phoneNumber,
      },
      userMetadata: user.userMetadata,
    );
  }
}
