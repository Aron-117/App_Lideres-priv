import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/app_routes.dart';

import 'package:provider/provider.dart'; // Para que entienda qué es Consumer
import '../../core/providers/auth_provider.dart'; // Para que entienda qué es AuthProvider

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold con el color de fondo principal de tu diseño
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo Provisional
              const Center(
                child: FlutterLogo(size: 100), // Cambia esto cuando tengas el SVG
              ),
              const SizedBox(height: 40),

              // Título
              Text(
                'Sign In',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(color: AppColors.surfaceWhite),
              ),
              const SizedBox(height: 30),

              // Inputs (Usando widget reutilizable)
              const CustomTextField(label: 'User'),
              const SizedBox(height: 16),
              const CustomTextField(label: 'Password', isPassword: true),
              const SizedBox(height: 24),

              // Botón de Login (Maquetado rápido)
              //vercion 2
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mostramos la alerta roja si hay error
                      if (auth.errorMessage != null) ...[
                        Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.surfaceWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          // Nota: Aquí deberías capturar el texto real de tus CustomTextFields
                          // usando un TextEditingController. Por ahora simularemos los valores.
                          final email = "usuario@correo.com";
                          final pass = "123456";

                          final success = await auth.signIn(email, pass);
                          // ¡NO USAMOS NAVIGATOR AQUÍ!
                          // Si el signIn es exitoso, el AuthWrapper de main.dart
                          // detectará el cambio y nos moverá al Home automáticamente.
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Forgot Password
              TextButton(
                onPressed: () {
                  // Navegación a recuperar contraseña
                },
                child: Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.surfaceWhite,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
