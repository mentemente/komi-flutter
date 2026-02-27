# core/widgets

Esta carpeta contiene widgets reutilizables y genéricos que se usan en múltiples partes de la aplicación.

Son los "componentes compartidos" de la app.

## ¿Qué va aquí?

- Botones personalizados
- Inputs reutilizables
- Loaders
- Diálogos genéricos
- AppBars comunes
- Cards reutilizables
- Empty states
- Error states

## Ejemplos de archivos

- `primary_button.dart` → Botón principal de la app
- `app_loader.dart` → Loader estándar
- `app_dialog.dart` → Diálogo genérico
- `app_text_field.dart` → Input reutilizable
- `error_view.dart` → Vista genérica de error

## Reglas

- No deben depender de un feature específico
- Deben ser reutilizables en cualquier pantalla
- Deben seguir el theme definido en core/theme
