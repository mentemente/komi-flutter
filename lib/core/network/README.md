# core/network

Esta carpeta contiene todo lo relacionado con la comunicación con servicios externos (internet, APIs, etc).

Aquí vive la infraestructura de red de la aplicación.

## ¿Qué va aquí?

- Cliente HTTP (por ejemplo: Dio o http)
- Configuración de interceptores (headers, tokens, logs, etc)
- Manejo global de requests y responses
- Configuración de timeouts
- Inyección de baseUrl
- Adaptadores de red

## Ejemplos de archivos

- `http_client.dart` → Configuración principal del cliente HTTP
- `api_interceptors.dart` → Interceptores para agregar tokens, logs, etc
- `network_info.dart` → Verificar si hay conexión a internet
- `api_response.dart` → Wrapper común para respuestas del backend

## Reglas

- Esta capa NO debe tener widgets ni lógica de UI
- Esta capa NO conoce features específicos (auth, orders, etc)
- Solo provee herramientas de red reutilizables para toda la app
