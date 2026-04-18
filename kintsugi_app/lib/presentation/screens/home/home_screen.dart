import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';

// ── Datos estáticos por arquetipo ──────────────────────────────────────────────

const Map<String, String> _nombres = {
  'thorfinn': 'THORFINN',
  'rocklee': 'ROCK LEE',
  'ippo': 'IPPO',
  'mob': 'MOB',
  'asta': 'ASTA',
};

// ── Opciones emocionales ───────────────────────────────────────────────────────

class _OpcionEmocional {
  final String emoji;
  final String label;

  const _OpcionEmocional(this.emoji, this.label);
}

const _emociones = [
  _OpcionEmocional('🌑', 'Vacío'),
  _OpcionEmocional('🔥', 'Frustrado'),
  _OpcionEmocional('⚡', 'Motivado'),
  _OpcionEmocional('🌊', 'Ansioso'),
  _OpcionEmocional('☁️', 'Calma'),
];

// ── HomeScreen ─────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final String arquetipoId;

  const HomeScreen({super.key, required this.arquetipoId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  // ── Fondo ──────────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _imagenFase1,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFF1A1A1A)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 0.60, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xB30D0D0D), // #0D0D0D al 70%
                    Color(0xF50D0D0D), // #0D0D0D al 96%
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────

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
            Container(
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
          ],
        ),
      ),
    );
  }

  // ── Contenido Home ─────────────────────────────────────────────────────────

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final statusBarHeight = MediaQuery.of(context).padding.top;
        // El saludo debe quedar al 38% desde el top de la pantalla total
        // Descontamos: status bar + top bar (56px)
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
              _buildCardRacha(),
              const SizedBox(height: 12),
              _buildCardCheckin(),
              const SizedBox(height: 12),
              _buildCardMision(),
              const SizedBox(height: 80), // espacio para la bottom nav
            ],
          ),
        );
      },
    );
  }

  // ── Saludo ─────────────────────────────────────────────────────────────────

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

  // ── Card Racha ─────────────────────────────────────────────────────────────

  Widget _buildCardRacha() {
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
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Racha activa',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '7 días consecutivos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '🏆 Mejor: 12',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.accentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card Check-in ──────────────────────────────────────────────────────────

  Widget _buildCardCheckin() {
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
            // Top row: pill HOY + fecha
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
            // Opciones emocionales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _emociones
                  .map((e) => _buildOpcionEmocional(e))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionEmocional(_OpcionEmocional opcion) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _CheckinPlaceholder(),
          ),
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
              child: Text(
                opcion.emoji,
                style: const TextStyle(fontSize: 22),
              ),
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

  // ── Card Misión ────────────────────────────────────────────────────────────

  Widget _buildCardMision() {
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
            // Top row
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
                  child: const Text(
                    'Reflexión',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9FA8DA),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Texto narrativo
            Text(
              '$_nombre te dice:',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            // Cita
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.accentPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '"El primer paso no fue el más grande. Fue el primero."',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 14),
            // Título misión
            const Text(
              'Escribe tu primer paso de hoy',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            // Ver misión completa
            GestureDetector(
              onTap: () {},
              child: const Text(
                'VER MISIÓN COMPLETA →',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF20D0D0D), // #0D0D0D al 95%
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, '🏠', 'Inicio'),
              _buildNavItem(1, Icons.check_circle_outline_rounded, '✅', 'Misiones'),
              _buildNavItem(2, Icons.show_chart_rounded, '📈', 'Progreso'),
              _buildNavItem(3, Icons.person_outline_rounded, '👤', 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String emoji, String label) {
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
              color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
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

  // ── Placeholder tabs ───────────────────────────────────────────────────────

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

// ── Check-in placeholder ───────────────────────────────────────────────────────

class _CheckinPlaceholder extends StatelessWidget {
  const _CheckinPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'CHECK-IN',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Check-in — próximamente',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
