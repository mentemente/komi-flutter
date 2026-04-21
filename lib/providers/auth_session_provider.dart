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

  /// Load token and user from local storage and sync with [HttpClient].
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
        stores: _storesFromPayloadMap(map),
      );
      state = session;
      ServiceLocator.httpClient.setToken(token);
      authSessionRouterRefresh.notifyChanged();
    } catch (_) {
      await clear();
    }
  }

  /// Merge the store returned in `data` after `POST /v1/store` into local storage (`komi_auth_user_payload`).
  Future<void> addStoreFromApiData(Map<String, dynamic> storeData) async {
    final id = storeData['id'] as String?;
    final storeName = storeData['name'] as String?;
    if (id == null || id.isEmpty || storeName == null || storeName.isEmpty) {
      return;
    }
    final newStore = AuthStore(id: id, name: storeName);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final payload = prefs.getString(_kUserPayload);
    if (token == null || token.isEmpty || payload == null || payload.isEmpty) {
      return;
    }

    final map = jsonDecode(payload) as Map<String, dynamic>;
    final existing = _storesFromPayloadMap(map);
    final updated = [...existing.where((s) => s.id != id), newStore];

    final encoded = jsonEncode({
      'phone': map['phone'],
      'type': map['type'],
      'name': map['name'],
      'stores': updated.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_kUserPayload, encoded);

    state = AuthResponse(
      token: token,
      phone: map['phone'] as String,
      type: UserType.fromString(map['type'] as String),
      name: map['name'] as String,
      stores: updated,
    );
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

List<AuthStore> _storesFromPayloadMap(Map<String, dynamic> map) {
  final raw = map['stores'];
  if (raw is! List<dynamic>) return [];
  return raw.map((e) => AuthStore.fromJson(e as Map<String, dynamic>)).toList();
}
