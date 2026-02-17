import 'package:flutter/material.dart';

/// Página principal de la aplicación (ruta raíz /)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Page')));
  }
}
