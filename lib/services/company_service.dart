import 'dart:developer' as developer;
import 'package:myapp/models/company.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyService {
  final SupabaseClient _supabaseClient;

  CompanyService(this._supabaseClient);

  Future<Company> createCompany(Company company) async {
    final response = await _supabaseClient
        .from('companies')
        .insert(company.toMap())
        .select()
        .single();
    return Company.fromMap(response);
  }

  Future<Company> getCompany(String userId) async {
    try {
      final response = await _supabaseClient
          .from('companies')
          .select()
          .eq('user_id', userId)
          .single();

      return Company.fromMap(response);
    } catch (e, s) {
      developer.log('Error fetching company', name: 'myapp.company_service', error: e, stackTrace: s);
      return Company.empty();
    }
  }

  Future<void> updateCompany(Company company) async {
    await _supabaseClient
        .from('companies')
        .update(company.toMap())
        .eq('user_id', company.id);
  }

  Future<void> deleteCompany(String userId) async {
    await _supabaseClient
        .from('companies')
        .delete()
        .eq('user_id', userId);
  }
}
