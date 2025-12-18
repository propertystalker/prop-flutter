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
    } catch (e) {
      // If no company is found, it might throw an error.
      // Instead of letting it crash, we can return an empty or default company.
      // This is particularly useful for the new user onboarding flow.
      print('Error fetching company: $e');
      return Company.empty(); // Return an empty company object
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
