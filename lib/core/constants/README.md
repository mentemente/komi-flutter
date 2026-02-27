# core/constants

Esta carpeta contiene constantes globales usadas en toda la aplicación.

Sirve para evitar strings mágicos y valores repetidos por todo el proyecto.

## ¿Qué va aquí?

- Keys de almacenamiento local
- Nombres de rutas
- Duraciones de timeouts
- Valores fijos reutilizables
- Endpoints base
- Nombres de assets
- Textos fijos globales
- Colores de la app (paleta)

## Ejemplos de archivos

- `app_colors.dart` → Paleta de colores (primary, background, etc.)
- `app_constants.dart` → Constantes generales de la app
- `storage_keys.dart` → Keys para SharedPreferences / SecureStorage
- `api_constants.dart` → Endpoints y rutas base
- `route_names.dart` → Nombres de rutas de navegación

## Reglas

- No debe haber lógica aquí, solo valores constantes
- Evitar hardcodear strings en otras partes del proyecto
- Todo valor global repetido debería vivir aquí
