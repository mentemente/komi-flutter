import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/app/app_component.dart';
import 'package:komi_fe/config/router.dart';
import 'package:komi_fe/core/platform/maps_loader.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  loadGoogleMapsScript();

  final container = ProviderContainer();
  await container.read(authSessionProvider.notifier).hydrate();
  final router = createGoRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: AppComponent(router: router),
    ),
  );
}
