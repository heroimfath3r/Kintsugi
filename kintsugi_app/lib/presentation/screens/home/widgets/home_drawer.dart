// Archivo NUEVO — crear en:
// lib/presentation/screens/home/widgets/home_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';

class HomeDrawer extends StatelessWidget {
  final String nombre;
  final String imagenFase1;
  final int currentTabIndex;
  final ValueChanged<int> onTabSelected;

  const HomeDrawer({
    super.key,
    required this.nombre,
    required this.imagenFase1,
    required this.currentTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 8),
            _buildNavItem(context, Icons.home_rounded, 'Inicio', 0),
            _buildNavItem(
                context, Icons.check_circle_outline_rounded, 'Misiones', 1),
            _buildNavItem(
                context, Icons.show_chart_rounded, 'Progreso', 2),
            _buildNavItem(
                context, Icons.person_outline_rounded, 'Mi Perfil', 3),
            const Spacer(),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            _buildLogoutItem(context),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kintsugi v1.0.0 — MVP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentPrimary, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                imagenFase1,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF242424),
                  child: const Icon(Icons.person,
                      color: AppColors.textSecondary, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int tabIndex) {
    final isActive = currentTabIndex == tabIndex;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.accentPrimary : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTabSelected(tabIndex);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedTileColor: AppColors.accentPrimary.withValues(alpha: 0.1),
      selected: isActive,
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(const AuthLogoutRequested());
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}