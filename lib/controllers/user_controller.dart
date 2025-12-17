import 'package:flutter/foundation.dart';
import 'package:myapp/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class UserController with ChangeNotifier {
  List<User> _users = [];
  final SupabaseClient _supabase = Supabase.instance.client;

  List<User> get users => _users;

  Future<void> getUsers() async {
    final response = await _supabase.from('profiles').select();
    final List<dynamic> data = response as List<dynamic>;
    _users = data.map((e) => User.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await _supabase.from('profiles').insert(user.toMap());
    await getUsers();
  }

  Future<void> removeUser(User user) async {
    await _supabase.from('profiles').delete().match({'id': user.id});
    await getUsers();
  }

  Future<void> updateUser(User user) async {
    await _supabase.from('profiles').update(user.toMap()).match({'id': user.id});
    await getUsers();
  }

  Future<void> sendPasswordReset(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
