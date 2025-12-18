import 'package:flutter/material.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/services/company_service.dart';
import 'package:myapp/services/person_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService with ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late final PersonService _personService;
  late final CompanyService _companyService;

  SupabaseService() {
    _personService = PersonService(_supabaseClient);
    _companyService = CompanyService(_supabaseClient);
  }

  SupabaseClient get client => _supabaseClient;

  // Auth methods
  Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) {
    return _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signInWithPassword(String email, String password) {
    return _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Person methods
  Future<void> createPerson(Person person) => _personService.createPerson(person);
  Future<Person> getPerson(String id) => _personService.getPerson(id);
  Future<void> updatePerson(Person person) => _personService.updatePerson(person);
  Future<void> deletePerson(String id) => _personService.deletePerson(id);

  // Company methods
  Future<Company> createCompany(Company company) =>
      _companyService.createCompany(company);
  Future<Company> getCompany(String id) => _companyService.getCompany(id);
  Future<void> updateCompany(Company company) =>
      _companyService.updateCompany(company);
  Future<void> deleteCompany(String id) => _companyService.deleteCompany(id);
}
