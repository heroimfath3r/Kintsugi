// lib/presentation/screens/home/tabs/progreso_tab.dart

import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/data/models/progreso_model.dart';
import 'package:kintsugi_app/data/services/progreso_service.dart';

const Map<String, String> _emojisPorEstado = {
  'vacio': '🌑',
  'frustracion': '🔥',
  'motivacion': '⚡',
  'ansiedad': '🌊',
  'calma': '☁️',
};

class ProgresoTab extends StatefulWidget {
  final String arquetipoId;
  final String Function(int fase) imagenFase;

  const ProgresoTab({
    super.key,
    required this.arquetipoId,
    required this.imagenFase,
  });

  @override
  State<ProgresoTab> createState() => _ProgresoTabState();
}

class _ProgresoTabState extends State<ProgresoTab> {
  final ProgresoService _progresoService = sl<ProgresoService>();

  bool _isLoading = true;
  String? _error;
  ProgresoModel? _progreso;
  ProgresoWeeklyModel? _resumenSemanal;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resultados = await Future.wait([
        _progresoService.getProgreso(),
        _tryGetResumenSemanal(),
      ]);

      if (mounted) {
        setState(() {
          _progreso = resultados[0] as ProgresoModel;
          _resumenSemanal = resultados[1] as ProgresoWeeklyModel?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error cargando progreso';
          _isLoading = false;
        });
      }
    }
  }

  Future<ProgresoWeeklyModel?> _tryGetResumenSemanal() async {
    try {
      return await _progresoService.getResumenSemanal();
    } catch (_) {
      return null;
    }
  }

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
              Text(_error!, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargarDatos,
                child: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
      );
    }

    final progreso = _progreso!;

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.accentPrimary,
      backgroundColor: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          children: [
            _buildAvatarCard(progreso),
            const SizedBox(height: 16),
            _buildXpCard(progreso),
            const SizedBox(height: 16),
            _buildEstadisticas(progreso),
            const SizedBox(height: 16),
            if (_resumenSemanal != null)
              _buildResumenSemanal(_resumenSemanal!),
          ],
        ),
      ),
    );
  }

  // ── Avatar con fase ─────────────────────────────────────────────────

  Widget _buildAvatarCard(ProgresoModel progreso) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Tu avatar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Avatar circular
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.accentPrimary, width: 3),
            ),
            child: ClipOval(
              child: Image.network(
                widget.imagenFase(progreso.fase),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const CircularProgressIndicator(color: AppColors.accentPrimary),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: AppColors.textSecondary, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Badge de fase
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              progreso.faseLabel,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimary,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra de XP ──────────────────────────────────────────────────────

  Widget _buildXpCard(ProgresoModel progreso) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Experiencia',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${progreso.xp} / ${progreso.xpSiguienteFase} XP',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso.progresoPorcentaje,
              minHeight: 10,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progreso.fase < 3
                ? '${progreso.xpSiguienteFase - progreso.xp} XP para la siguiente fase'
                : '¡Has alcanzado la fase máxima!',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Estadísticas rápidas ─────────────────────────────────────────────

  Widget _buildEstadisticas(ProgresoModel progreso) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              '🔥', '${progreso.racha}', 'Racha\nactual'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
              '✅', '${progreso.misionesCompletadas}', 'Misiones\ncompletadas'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
              '⭐', '${progreso.xp}', 'XP\ntotal'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String valor, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Resumen semanal ──────────────────────────────────────────────────

  Widget _buildResumenSemanal(ProgresoWeeklyModel resumen) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu semana',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Fila de 7 días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dia = index < resumen.dias.length
                  ? resumen.dias[index]
                  : null;
              return _buildDiaCircle(index, dia);
            }),
          ),
          const SizedBox(height: 20),
          // Stats del resumen
          Row(
            children: [
              Expanded(
                child: _buildResumenStat(
                  'Días activos',
                  '${resumen.diasActivos}/7',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: const Color(0xFF2A2A2A),
              ),
              Expanded(
                child: _buildResumenStat(
                  'Misiones hechas',
                  '${resumen.misionesCompletadas}',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: const Color(0xFF2A2A2A),
              ),
              Expanded(
                child: _buildResumenStat(
                  'Estado frecuente',
                  _emojisPorEstado[resumen.estadoMasFrecuente] ?? '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiaCircle(int index, CheckinDiaModel? dia) {
    const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final label = diasSemana[index];
    final tieneCheckin = dia?.estadoEmocional != null;
    final emoji = tieneCheckin
        ? (_emojisPorEstado[dia!.estadoEmocional] ?? '❓')
        : null;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tieneCheckin
                ? AppColors.accentPrimary.withValues(alpha: 0.15)
                : const Color(0xFF242424),
            border: Border.all(
              color: tieneCheckin
                  ? AppColors.accentPrimary.withValues(alpha: 0.5)
                  : const Color(0xFF3A3A3A),
            ),
          ),
          child: Center(
            child: Text(
              emoji ?? '·',
              style: TextStyle(fontSize: tieneCheckin ? 18 : 14),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        // Indicador de misión completada
        const SizedBox(height: 2),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dia?.misionCompletada == true
                ? AppColors.success
                : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenStat(String label, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}