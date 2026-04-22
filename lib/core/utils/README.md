# core/utils

Esta carpeta contiene utilidades y helpers genéricos que pueden ser usados en cualquier parte de la app.

Son funciones o clases pequeñas que no pertenecen a un feature específico.

## ¿Qué va aquí?

- Helpers de fechas (formatos, conversiones, etc)
- Helpers de strings
- Helpers de números
- Validadores comunes (email, password, etc)
- Funciones de conversión o formateo

## Ejemplos de archivos

- `date_utils.dart` → Formateo de fechas
- `string_utils.dart` → Manipulación de strings
- `validators.dart` → Validaciones comunes
- `formatters.dart` → Formateadores de datos

## Reglas

- No deben depender de Flutter widgets
- No deben depender de features específicos
- Deben ser funciones/clases reutilizables y genéricas
