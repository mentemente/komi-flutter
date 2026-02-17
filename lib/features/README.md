# Features — Guía del módulo

Este proyecto está organizado por **features** (módulos de negocio). Cada feature agrupa todo lo relacionado con una funcionalidad: pantallas, lógica, servicios y widgets propios.

## Índice

- [Estructura del directorio](#estructura-del-directorio)
- [Features actuales](#features-actuales)
- [Anatomía de un feature](#anatomía-de-un-feature)
- [Archivos por responsabilidad](#archivos-por-responsabilidad)
- [Reglas y convenciones](#reglas-y-convenciones)
- [Crear un nuevo feature](#crear-un-nuevo-feature)
- [Objetivo de la arquitectura](#objetivo-de-la-arquitectura)

---

## Estructura del directorio

Todo lo que pertenece a una funcionalidad vive bajo `lib/features/<feature>/`. Opcionalmente puedes dividir un feature en submódulos (por ejemplo `auth/login`, `auth/register`).

```
lib/features/
├── auth/
│   ├── login/
│   │   ├── login_page.dart
│   │   ├── login_controller.dart
│   │   ├── login_state.dart
│   │   ├── login_service.dart
│   │   └── widgets/
│   │       ├── login_form.dart
│   │       ├── phone_input.dart
│   │       └── password_input.dart
│   └── register/
│       ├── register_page.dart
│       ├── register_controller.dart
│       └── register_service.dart
├── home/
│   └── home_page.dart
└── 404/
    └── not_found_page.dart
```

**Beneficios:**

- Código **fácil de encontrar**: todo de login está en `auth/login/`.
- **Escalable**: añades features sin mezclar responsabilidades.
- **Mantenible**: cambios en una funcionalidad se hacen en un solo lugar.

---

## Features actuales

| Feature   | Ruta(s)      | Descripción              |
|----------|---------------|---------------------------|
| `auth/login`   | `/login`      | Inicio de sesión          |
| `auth/register`| `/registro`   | Registro de usuario       |
| `home`         | `/`           | Pantalla principal        |
| `404`          | (not found)   | Página de error 404       |

Las rutas se definen en `lib/config/routes.dart` y los handlers en `lib/config/route_handlers.dart`. Los nombres de rutas están en `lib/core/constants/route_names.dart`.

---

## Anatomía de un feature

Cada submódulo (ej. `login`, `register`) suele tener:

| Elemento        | Rol |
|-----------------|-----|
| **Page**        | Pantalla: layout (Scaffold, AppBar) y composición de widgets. |
| **Controller**  | Lógica: validaciones, llamadas al service, estado de la UI. |
| **State**       | (Opcional) Modelo del estado: loading, error, datos. |
| **Service**     | Comunicación con backend/API; sin UI. |
| **widgets/**    | Widgets reutilizables solo dentro de ese submódulo. |

Flujo típico: **Page** → usa **Controller** → Controller usa **Service** y actualiza **State** → Page reacciona al estado.

---

## Archivos por responsabilidad

### `*_page.dart`

- **Qué es:** La pantalla principal del submódulo.
- **Contiene:** Scaffold, AppBar, estructura y uso de widgets internos; se conecta al controller.
- **No debe:** Incluir lógica pesada ni llamadas directas a APIs.
- **Ejemplos:** `login_page.dart`, `register_page.dart`, `home_page.dart`.

### `*_controller.dart`

- **Qué es:** La lógica de la pantalla.
- **Contiene:** Validaciones, llamadas al service, manejo de loading/error/éxito.
- **No debe:** Conocer detalles de widgets ni construir UI.
- **Ejemplos:** `login_controller.dart`, `register_controller.dart`.

### `*_state.dart` (opcional)

- **Qué es:** El estado de la pantalla (loading, error, datos).
- **Contiene:** Clases o enums que definen qué mostrar (loader, mensaje de error, contenido).
- **Uso:** El controller actualiza el state; la page reacciona y pinta la UI correspondiente.

### `*_service.dart`

- **Qué es:** Acceso a datos (API, Firebase, etc.).
- **Contiene:** Llamadas HTTP, persistencia, lógica de red.
- **No debe:** Contener widgets ni lógica de UI.
- **Ejemplos:** `login_service.dart`, `register_service.dart`.

### `widgets/`

- **Qué es:** Widgets reutilizables **solo dentro de ese submódulo**.
- **Contiene:** Formularios, inputs, botones o cards específicos del feature.
- **Si el widget es global:** va en `lib/core/widgets/`, no aquí.
- **Ejemplos:** `login_form.dart`, `phone_input.dart`, `password_input.dart`.

---

## Reglas y convenciones

- **Aislamiento:** Todo lo de un feature vive en su carpeta. No mezclar `auth` con `home`, `orders`, etc.
- **Widgets:** Específicos del feature → `features/<feature>/.../widgets/`. Globales → `core/widgets/`.
- **Nombres:** Archivos y carpetas en **snake_case** (ej. `login_page.dart`, `not_found_page.dart`).
- **Responsabilidad:** Un archivo, una responsabilidad clara; si crece mucho, dividir en más archivos o submódulos.
- **Rutas:** Usar constantes de `lib/core/constants/route_names.dart` y registrar en `config/routes.dart` y `config/route_handlers.dart`.

---

## Crear un nuevo feature

1. **Crear la carpeta** bajo `lib/features/`:

   ```text
   lib/features/
   └── mi_feature/
   ```

2. **Si tiene varias pantallas**, usar submódulos:

   ```text
   lib/features/
   └── mi_feature/
       ├── pantalla_a/
       └── pantalla_b/
   ```

3. **Por cada pantalla (submódulo)** añadir al menos:
   - `*_page.dart`
   - `*_controller.dart` (si hay lógica)
   - `*_service.dart` (si hay API o datos externos)
   - Carpeta `widgets/` si hay componentes reutilizables solo en esa pantalla

4. **Registrar la ruta:**
   - Añadir la constante en `lib/core/constants/route_names.dart`.
   - Definir el handler en `lib/config/route_handlers.dart`.
   - Registrar en `lib/config/routes.dart` con `router.define(RouteNames.miRuta, handler: miHandler)`.

**Checklist rápido:** carpeta → page → controller/service si aplica → widgets si aplica → constante de ruta → handler → `router.define`.

---

## Objetivo de la arquitectura

- **Claridad:** Cualquiera entiende dónde está cada cosa.
- **Simplicidad:** Evitar capas y abstracciones innecesarias por ahora.
- **Escalabilidad:** Poder crecer sin desorden; cada feature es un módulo acotado.

Si el proyecto crece mucho, esta estructura se puede evolucionar hacia capas más formales (dominio, datos, presentación). La prioridad actual es **claridad, simplicidad y velocidad de desarrollo**.
