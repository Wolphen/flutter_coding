import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class SessionManager {
  static const _tokenKey = 'jwt_token';
  static const _secretKey = 'ton_secret_key';

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token pour la déconnexion
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      try {
        JWT.verify(token, SecretKey(_secretKey));
        return true; // Token valide
      } catch (e) {
        print("Token invalide ou expiré : $e");
      }
    }
    return false;
  }

  // Obtenir les informations de l'utilisateur connecté
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token != null) {
      try {
        final jwt = JWT.verify(token, SecretKey(_secretKey));
        final nom = jwt.payload['nom'] as String?;
        final email = jwt.payload['mail'] as String?;
        if (nom != null && email != null) {
          return {'nom': nom, 'mail': email};
        }
      } catch (e) {
        print("Erreur lors de la récupération des informations utilisateur : $e");
      }
    }
    return null;
  }
}
