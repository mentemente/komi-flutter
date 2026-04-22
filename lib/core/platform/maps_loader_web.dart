import 'package:web/web.dart' as web;
import 'package:komi_fe/core/config/app_config.dart';

void loadGoogleMapsScript() {
  final script = web.HTMLScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js'
        '?key=${AppConfig.googleMapsApiKey}'
        '&libraries=places&loading=async'
    ..defer = true;
  web.document.head!.append(script);
}
