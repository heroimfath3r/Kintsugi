import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/application/home/home_bloc.dart';
import 'package:kintsugi_app/application/home/home_event.dart';
import 'package:kintsugi_app/application/home/home_state.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';
import 'package:kintsugi_app/data/models/mision_model.dart';
import 'package:kintsugi_app/data/services/auth_service.dart';
import 'package:kintsugi_app/data/services/checkin_service.dart';
import 'package:kintsugi_app/data/services/mision_service.dart';

const Map<String, String> _nombres = {
  'thorfinn': 'THORFINN',
  'rocklee': 'ROCK LEE',
  'rock_lee': 'ROCK LEE',
  'ippo': 'IPPO',
  'mob': 'MOB',
  'asta': 'ASTA',
};

class _OpcionEmocional {
  final String emoji;
  final String label;
  final String valor;

  const _OpcionEmocional(this.emoji, this.label, this.valor);
}

const _emociones = [
  _OpcionEmocional('🌑', 'Vacío', 'vacio'),
  _OpcionEmocional('🔥', 'Frustrado', 'frustracion'),
  _OpcionEmocional('⚡', 'Motivado', 'motivacion'),
  _OpcionEmocional('🌊', 'Ansioso', 'ansiedad'),
  _OpcionEmocional('☁️', 'Calma', 'calma'),
];

class HomeScreen extends StatelessWidget {
  final String arquetipoId;

  const HomeScreen({super.key, required this.arquetipoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        authService: sl<AuthService>(),
        checkinService: sl<CheckinService>(),
        misionService: sl<MisionService>(),
      )..add(const HomeLoadData()),
      child: _HomeView(arquetipoId: arquetipoId),
    );
  }
}

class _HomeView extends StatefulWidget {
  final String arquetipoId;

  const _HomeView({required this.arquetipoId});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _tabIndex = 0;

  String get _nombre =>
      _nombres[widget.arquetipoId] ?? widget.arquetipoId.toUpperCase();

  String get _imagenFase1 =>
      'assets/avatars/${widget.arquetipoId}_fase1.png';

  String _formatearFecha() {
    final now = DateTime.now();
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dias[now.weekday - 1]}, ${now.day} ${meses[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    // ══════════════════════════════════════════════════════════════════
    // FIX: PopScope bloquea el botón atrás de Android.
    // El Home es la pantalla raíz — no hay a dónde volver.
    // ══════════════════════════════════════════════════════════════════
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _tabIndex == 0
                        ? _buildHomeContent()
                        : _buildPlaceholderTab(),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _imagenFase1,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFF1A1A1A)),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 0.60, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xB30D0D0D),
                    Color(0xF50D0D0D),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const Expanded(
              child: Text(
                'KINTSUGI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentPrimary,
                  letterSpacing: 3,
                ),
              ),
            ),
            // ══════════════════════════════════════════════════════════════
            // FIX: Botón de logout funcional para la demo
            // ══════════════════════════════════════════════════════════════
            GestureDetector(
              onLongPress: () {
                // Long press para cerrar sesión (útil para demo)
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
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF242424),
                  border: Border.all(color: AppColors.accentPrimary, width: 1.5),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentPrimary),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const HomeLoadData()),
                    child: const Text('REINTENTAR'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          return _buildLoadedContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, HomeLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final greetingOffset =
            (screenHeight * 0.38 - statusBarHeight - 56).clamp(8.0, double.infinity);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: greetingOffset),
              _buildSaludo(),
              const SizedBox(height: 20),
              _buildCardRacha(state.user.racha),
              const SizedBox(height: 12),
              state.yaHizoCheckin
                  ? _buildCheckinCompletado(
                      state.checkinHoy!.emoji, state.checkinHoy!.label)
                  : _buildCardCheckin(context),
              const SizedBox(height: 12),
              if (state.misionHoy != null)
                _buildCardMision(context, state.misionHoy!, state.misionCompletada),
              if (state.misionHoy == null && state.yaHizoCheckin)
                _buildMisionCargando(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaludo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido de nuevo,',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_nombre te espera hoy',
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRacha(int racha) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Racha activa',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$racha ${racha == 1 ? 'día' : 'días'} consecutivos',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCheckin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33C9A84C),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.accentPrimary),
                  ),
                  child: const Text(
                    'HOY',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatearFecha(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo estás hoy?',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _emociones
                  .map((e) => _buildOpcionEmocional(context, e))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionEmocional(BuildContext context, _OpcionEmocional opcion) {
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(
              HomeCheckinRequested(estadoEmocional: opcion.valor),
            );
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF242424),
              border: Border.all(color: const Color(0xFF3A3A3A)),
            ),
            child: Center(
              child: Text(opcion.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            opcion.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinCompletado(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check-in de hoy',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Te sientes: $label',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMision(
      BuildContext context, MisionModel mision, bool completada) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: completada
                ? AppColors.success.withValues(alpha: 0.3)
                : const Color(0xFF2A2A2A),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'MISIÓN DE HOY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x335C6BC0),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFF5C6BC0)),
                  ),
                  child: Text(
                    mision.tipoLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9FA8DA),
                    ),
                  ),
                ),
                if (completada) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              mision.titulo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mision.descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (!completada) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(
                          HomeMisionCompleted(misionId: mision.id),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.backgroundPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'MARCAR COMPLETADA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMisionCargando() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: const Center(
          child: Text(
            'Cargando tu misión...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF20D0D0D),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Inicio'),
              _buildNavItem(1, Icons.check_circle_outline_rounded, 'Misiones'),
              _buildNavItem(2, Icons.show_chart_rounded, 'Progreso'),
              _buildNavItem(3, Icons.person_outline_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _tabIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tabIndex = index),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.accentPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isActive
                    ? AppColors.accentPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab() {
    const labels = ['Misiones', 'Progreso', 'Perfil'];
    final label = _tabIndex > 0 ? labels[_tabIndex - 1] : '';
    return Center(
      child: Text(
        '$label — próximamente',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}