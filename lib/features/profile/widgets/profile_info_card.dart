import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final String email;
  final String roleName;

  const ProfileInfoCard({
    super.key,
    required this.email,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_rounded,
            label: 'Correo Electrónico',
            text: email,
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF0F0F0),
          ),
          _buildInfoRow(
            icon: Icons.shield_rounded,
            label: 'Nivel de Acceso',
            text: roleName,
          ),
        ],
      ),
    );
  }

  // Widget reutilizable rediseñado
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Ícono dentro de un círculo suave
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta pequeña para dar contexto
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // Dato real
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
