// lib/presentation/screens/home/tabs/perfil_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';
import 'package:kintsugi_app/data/services/auth_service.dart';
import 'package:kintsugi_app/data/models/user_model.dart';

class PerfilTab extends StatefulWidget {
  final String arquetipoId;
  final String nombre;
  final String anime;
  final String filosofia;
  // HU-14: función dinámica en vez de string fijo de fase 1
  final String Function(int fase) imagenFase;

  const PerfilTab({
    super.key,
    required this.arquetipoId,
    required this.nombre,
    required this.anime,
    required this.filosofia,
    required this.imagenFase,
  });

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  final AuthService _authService = sl<AuthService>();

  bool _isLoading = true;
  String? _error;
  UserModel? _user;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error cargando perfil';
          _isLoading = false;
        });
      }
    }
  }

  // ── Editar nombre ─────────────────────────────────────────────────────

  void _editarNombre() {
    final controller = TextEditingController(text: _displayName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        title: const Text(
          'Tu nombre',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.accentPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: '¿Cómo te llamas?',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final nuevoNombre = controller.text.trim();
              if (nuevoNombre.isEmpty) return;
              Navigator.of(ctx).pop();

              try {
                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(nuevoNombre);
                await FirebaseAuth.instance.currentUser?.reload();
                if (mounted) {
                  setState(() => _displayName = nuevoNombre);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre actualizado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al actualizar el nombre')),
                  );
                }
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cambiar contraseña ────────────────────────────────────────────────

  void _cambiarContrasena() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: AppColors.accentPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Correo enviado',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviamos un enlace para cambiar tu contraseña a\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.backgroundPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ENTENDIDO',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al enviar correo de recuperación')),
        );
      }
    }
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Tendrás que iniciar sesión de nuevo para acceder a tu cuenta.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(_error!,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargarPerfil,
                child: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user!;

    return RefreshIndicator(
      onRefresh: _cargarPerfil,
      color: AppColors.accentPrimary,
      backgroundColor: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          children: [
            _buildPerfilHeader(user),
            const SizedBox(height: 16),
            _buildInfoCard(user),
            const SizedBox(height: 16),
            _buildEstadisticasCard(user),
            const SizedBox(height: 16),
            _buildAccionesCard(),
          ],
        ),
      ),
    );
  }

  // ── Header del perfil ─────────────────────────────────────────────────

  Widget _buildPerfilHeader(UserModel user) {
    // HU-14: usa la fase real del usuario, no siempre fase 1
    final imagenActual = widget.imagenFase(user.fase);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar con fase dinámica
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentPrimary, width: 3),
            ),
            child: ClipOval(
              child: Image.network(
                imagenActual,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null
                        ? child
                        : const CircularProgressIndicator(
                            color: AppColors.accentPrimary),
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary,
                    size: 48),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Badge de fase actual — HU-14
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.5)),
            ),
            child: Text(
              'Fase ${user.fase}',
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nombre del arquetipo
          Text(
            widget.nombre,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.accentPrimary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          // Anime
          Text(
            widget.anime,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Filosofía
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.accentPrimary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              widget.filosofia,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info de la cuenta ─────────────────────────────────────────────────

  Widget _buildInfoCard(UserModel user) {
    final email = FirebaseAuth.instance.currentUser?.email ?? user.email;
    final creadoEn = user.creadoEn;
    String fechaRegistro = 'No disponible';
    if (creadoEn != null) {
      const meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      fechaRegistro =
          '${creadoEn.day} ${meses[creadoEn.month - 1]} ${creadoEn.year}';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de cuenta',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRowEditable(
            icon: Icons.person_outline,
            label: 'Nombre',
            value: _displayName.isEmpty ? 'Sin nombre' : _displayName,
            onTap: _editarNombre,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.mail_outline, 'Correo', email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined,
              'Miembro desde', fechaRegistro),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.shield_outlined, 'Arquetipo', user.nombreArquetipo),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowEditable({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    )),
                const SizedBox(height: 1),
                Text(value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value == 'Sin nombre'
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    )),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined,
              color: AppColors.accentPrimary, size: 16),
        ],
      ),
    );
  }

  // ── Estadísticas ──────────────────────────────────────────────────────

  Widget _buildEstadisticasCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStat('🔥', '${user.racha}', 'Racha')),
              Expanded(child: _buildStat('⭐', '${user.xp}', 'XP')),
              Expanded(
                  child: _buildStat(
                      '✅', '${user.misionesCompletadas}', 'Misiones')),
              Expanded(child: _buildStat('🏆', 'Fase ${user.fase}', 'Nivel')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String valor, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────────

  Widget _buildAccionesCard() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildAccionTile(
          icon: Icons.lock_reset_rounded,
          label: 'Cambiar contraseña',
          subtitle: 'Te enviaremos un correo para resetearla',
          onTap: _cambiarContrasena,
        ),
        const SizedBox(height: 10),
        _buildAccionTile(
          icon: Icons.logout,
          label: 'Cerrar sesión',
          subtitle: 'Volver a la pantalla de inicio',
          onTap: _cerrarSesion,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAccionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}