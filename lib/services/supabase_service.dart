import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;
}
