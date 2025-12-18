import 'package:myapp/models/company.dart';
import 'package:myapp/models/person.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonService {
  final SupabaseClient _supabaseClient;

  PersonService(this._supabaseClient);

  Future<void> createPerson(Person person) async {
    // First, we create or update the profile in the 'profiles' table.
    // We use upsert to handle both new and existing users gracefully.
    await _supabaseClient.from('profiles').upsert(person.toMap());

    // Next, we check if the person has a company and if that company has a name.
    // If so, we create or update the company in the 'companies' table.
    if (person.company.name.isNotEmpty) {
      await _supabaseClient.from('companies').upsert(person.company.toMap());
    }
  }

  Future<Person> getPerson(String id) async {
    // Step 1: Fetch the user's profile from the 'profiles' table.
    final profileResponse = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    // Step 2: Fetch the user's company from the 'companies' table.
    // We use a try-catch block to handle cases where a company may not exist.
    Company company;
    try {
      final companyResponse = await _supabaseClient
          .from('companies')
          .select()
          .eq('user_id', id)
          .single();
      company = Company.fromMap(companyResponse);
    } catch (e) {
      // If no company is found, we create an empty Company object.
      // This is a normal scenario for a new user.
      company = Company.empty();
    }

    // Step 3: Combine the profile and company data into a single Person object.
    final person = Person.fromMap(profileResponse);
    person.company = company; // Manually assign the fetched or empty company.

    return person;
  }

  Future<void> updatePerson(Person person) async {
    await _supabaseClient
        .from('profiles')
        .update(person.toMap())
        .eq('id', person.id);

    if (person.company.name.isNotEmpty) {
      await _supabaseClient.from('companies').upsert(person.company.toMap());
    }
  }

  Future<void> deletePerson(String id) async {
    await _supabaseClient
        .from('profiles')
        .delete()
        .eq('id', id);
    // Also delete the associated company if it exists
    await _supabaseClient
        .from('companies')
        .delete()
        .eq('user_id', id);
  }
}
