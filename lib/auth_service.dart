import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  User? get currentUser => Supabase.instance.client.auth.currentUser;
  final SupabaseClient _supabase = Supabase.instance.client;
  SupabaseClient get supabase => _supabase;

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // User signed in successfully
      } else {
        throw Exception("Unknown error occurred during sign-in.");
      }
    } catch (e) {
      throw Exception(
          e.toString()); // Handle the exception and display the error
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // User signed up successfully
      } else {
        throw Exception("Unknown error occurred during sign-up.");
      }
    } catch (e) {
      throw Exception(
          e.toString()); // Handle the exception and display the error
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }
}
