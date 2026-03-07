import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthActionController extends StateNotifier<AsyncValue<void>> {
  AuthActionController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<T> run<T>(Future<T> Function(AuthRepository repo) action) async {
    state = const AsyncValue.loading();
    try {
      final result = await action(_repository);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final authActionControllerProvider =
    StateNotifierProvider<AuthActionController, AsyncValue<void>>((ref) {
  return AuthActionController(ref.watch(authRepositoryProvider));
});
