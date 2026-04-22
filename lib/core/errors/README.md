# core/errors

Esta carpeta contiene todo lo relacionado con el manejo de errores de la aplicación.

La idea es tener un sistema de errores consistente y reutilizable en toda la app.

## ¿Qué va aquí?

- Excepciones personalizadas (Custom Exceptions)
- Clases de fallos (Failures)
- Mapeo de errores de red a errores de dominio
- Mensajes de error genéricos
- Tipos de errores comunes (ServerError, CacheError, ValidationError, etc)

## Ejemplos de archivos

- `exceptions.dart` → Excepciones personalizadas
- `failures.dart` → Clases de fallos para manejar errores en domain/presentation
- `error_mapper.dart` → Convierte errores técnicos en errores entendibles
- `network_error.dart` → Errores relacionados a conexión

## Reglas

- Los errores deben ser reutilizables en toda la app
- No debe haber dependencias con widgets ni UI
- La UI solo debería mostrar errores, no crearlos aquí
