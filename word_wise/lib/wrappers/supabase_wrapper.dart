import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_wise/dto/user_dto.dart';

enum FavoritesTableColumns { id, userId, wordName, all }

extension FavoritesTableColumnsExt on FavoritesTableColumns {
  String get name => [
        'id',
        'user_id',
        'word_name',
        '*',
      ][index];
}

enum HistoryTableColumns { id, createdAt, userId, wordName, all }

extension HistoryTableColumnsExt on HistoryTableColumns {
  String get name => [
        'id',
        'created_at',
        'user_id',
        'word_name',
        '*',
      ][index];
}

enum WordsTableColumns { id, wordName, language, all }

extension WordsTableColumnsExt on WordsTableColumns {
  String get name => [
        'id',
        'word_name',
        'language',
        '*',
      ][index];
}

class SupabaseWrapper {
  final SupabaseClient supabaseClient;

  static String get favoritesTableName => 'favorites';
  static String get historyTableName => 'history';
  static String get wordsTableName => 'words';

  SupabaseWrapper({required this.supabaseClient});

  Future<void> insert({required String table, required Map<String, dynamic> values}) async {
    await supabaseClient.from(table).insert(values);
  }

  Future<void> remove({required String table, required Map<String, Object> match}) async {
    await supabaseClient.from(table).delete().match(match);
  }

  Future<List<Map<String, dynamic>>> get({
    required String table,
    required String columns,
    String? columnEQA,
    String? valueEQA,
    String? columnEQB,
    String? valueEQB,
    String? orderId,
    bool? ascending,
  }) async {
    final filterEQA = columnEQA != null && valueEQA != null;
    final filterEQB = columnEQB != null && valueEQB != null;
    if (filterEQA) return await supabaseClient.from(table).select(columns).eq(columnEQA, valueEQA);
    if (filterEQA && filterEQB) return await supabaseClient.from(table).select(columns).eq(columnEQA, valueEQA).eq(columnEQB, valueEQB);
    return await supabaseClient.from(table).select(columns);
  }

  Future<List<Map<String, dynamic>>> getSorted({
    required String table,
    required String columns,
    String? columnEQA,
    String? valueEQA,
    String? columnEQB,
    String? valueEQB,
    required String orderId,
    required bool ascending,
  }) async {
    final filterEQA = columnEQA != null && valueEQA != null;
    final filterEQB = columnEQB != null && valueEQB != null;
    if (filterEQA) {
      return await supabaseClient.from(table).select(columns).eq(columnEQA, valueEQA).order(orderId, ascending: ascending);
    }
    if (filterEQA && filterEQB) {
      return await supabaseClient.from(table).select(columns).eq(columnEQA, valueEQA).eq(columnEQB, valueEQB).order(orderId, ascending: ascending);
    }
    return await supabaseClient.from(table).select(columns).order(orderId, ascending: ascending);
  }

  Future<List<Map<String, dynamic>>> getPaginated({
    required String table,
    required String columns,
    required int paginationStart,
    required int paginationEnd,
  }) async {
    return await supabaseClient.from(table).select(columns).range(paginationStart, paginationEnd);
  }

  Future<UserDto?> signInWithPassword({required String email, required String password}) async {
    final AuthResponse res = await supabaseClient.auth.signInWithPassword(email: email, password: password);

    final User? user = res.user;
    return user != null ? UserDto(email: user.email ?? '', userId: user.id) : null;
  }

  Future<UserDto?> getSignedUser() async {
    final User? user = supabaseClient.auth.currentUser;
    return user != null ? UserDto(email: user.email ?? '', userId: user.id) : null;
  }

  Future<UserDto?> signOut() async {
    await supabaseClient.auth.signOut();
    return null;
  }
}
