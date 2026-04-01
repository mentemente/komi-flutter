import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/features/auth/models/auth_store.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthResponse?>(
      AuthSessionNotifier.new,
    );

final authSessionRouterRefresh = AuthSessionRouterRefresh();

class AuthSessionRouterRefresh extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}

class AuthSessionNotifier extends Notifier<AuthResponse?> {
  static const _kToken = 'komi_auth_token';
  static const _kUserPayload = 'komi_auth_user_payload';

  @override
  AuthResponse? build() => null;

  /// Carga token y usuario desde almacenamiento local y sincroniza [HttpClient].
  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final payload = prefs.getString(_kUserPayload);
    if (token == null || token.isEmpty || payload == null || payload.isEmpty) {
      state = null;
      ServiceLocator.httpClient.setToken(null);
      authSessionRouterRefresh.notifyChanged();
      return;
    }
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final session = AuthResponse(
        token: token,
        phone: map['phone'] as String,
        type: UserType.fromString(map['type'] as String),
        name: map['name'] as String,
        stores: (map['stores'] as List<dynamic>)
            .map((e) => AuthStore.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      state = session;
      ServiceLocator.httpClient.setToken(token);
      authSessionRouterRefresh.notifyChanged();
    } catch (_) {
      await clear();
    }
  }

  Future<void> signIn(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, response.token);
    await prefs.setString(
      _kUserPayload,
      jsonEncode({
        'phone': response.phone,
        'type': response.type.name,
        'name': response.name,
        'stores': response.stores.map((e) => e.toJson()).toList(),
      }),
    );
    state = response;
    ServiceLocator.httpClient.setToken(response.token);
    authSessionRouterRefresh.notifyChanged();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserPayload);
    state = null;
    ServiceLocator.httpClient.setToken(null);
    authSessionRouterRefresh.notifyChanged();
  }
}
