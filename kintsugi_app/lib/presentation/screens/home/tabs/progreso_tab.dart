// lib/presentation/screens/home/tabs/progreso_tab.dart

import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/data/models/progreso_model.dart';
import 'package:kintsugi_app/data/services/progreso_service.dart';

// DEUDA TÉCNICA (documentada, no bloquea entrega):
// Estos dos Maps deberían venir de la API/modelo (CheckinModel ya tiene
// emoji y label). Se dejan aquí por ahora para no tocar más superficie.
const Map<String, String> _emojisPorEstado = {
  'vacio': '🌑',
  'frustracion': '🔥',
  'motivacion': '⚡',
  'ansiedad': '🌊',
  'calma': '☁️',
};

const Map<String, String> _nombresPorEstado = {
  'vacio': 'Vacío',
  'frustracion': 'Frustración',
  'motivacion': 'Motivación',
  'ansiedad': 'Ansiedad',
  'calma': 'Calma',
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
  // DEUDA TÉCNICA: acceso directo al servicio desde la vista (bypass del BLoC).
  // Pendiente migrar a un ProgresoBloc. No bloquea la entrega.
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
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _cargarDatos, child: const Text('REINTENTAR')),
            ],
          ),
        ),
      );
    }

    final progreso = _progreso!;

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.backgroundSecondary,
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
            // HU-14: colección visual de hitos desbloqueados
            _buildHitosDesbloqueados(progreso),
            const SizedBox(height: 16),
            if (_resumenSemanal != null) ...[
              _buildResumenSemanal(_resumenSemanal!),
              const SizedBox(height: 16),
              // HU-13: Línea de tiempo
              _buildLineaDeTiempo(_resumenSemanal!),
            ],
          ],
        ),
      ),
    );
  }

  // ── Avatar con fase ─────────────────────────────────────────────────

  Widget _buildAvatarCard(ProgresoModel progreso) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Tu avatar', style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: AppColors.textSecondary, letterSpacing: 1,
          )),
          const SizedBox(height: 12),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentPrimary, width: 3),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.5)),
            ),
            child: Text(progreso.faseLabel, style: const TextStyle(
              fontFamily: 'Cinzel', fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.accentPrimary, letterSpacing: 2,
            )),
          ),
        ],
      ),
    );
  }

  // ── Barra de XP ──────────────────────────────────────────────────────

  Widget _buildXpCard(ProgresoModel progreso) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Experiencia', style: TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary,
              )),
              Text('${progreso.xp} / ${progreso.xpSiguienteFase} XP',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w500, color: AppColors.accentPrimary,
                )),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso.progresoPorcentaje,
              minHeight: 10,
              backgroundColor: AppColors.borderDefault,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progreso.fase < 3
                ? '${progreso.xpSiguienteFase - progreso.xp} XP para la siguiente fase'
                : '¡Has alcanzado la fase máxima!',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Estadísticas rápidas ─────────────────────────────────────────────

  Widget _buildEstadisticas(ProgresoModel progreso) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('🔥', '${progreso.racha}', 'Racha\nactual')),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('✅', '${progreso.misionesCompletadas}', 'Misiones\ncompletadas')),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('⭐', '${progreso.xp}', 'XP\ntotal')),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String valor, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 22,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 11,
            color: AppColors.textSecondary, height: 1.3,
          )),
        ],
      ),
    );
  }

  // ── HU-14: colección visual de hitos ─────────────────────────────────

  Widget _buildHitosDesbloqueados(ProgresoModel progreso) {
    // Si el backend no devolvió hitos, no mostramos la sección.
    if (progreso.hitos.isEmpty) return const SizedBox.shrink();

    final desbloqueados = progreso.totalHitosDesbloqueados;
    final total = progreso.hitos.length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDefault),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Hitos', style: TextStyle(
                  fontFamily: 'Cinzel', fontSize: 16,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                )),
                const Spacer(),
                Text('$desbloqueados / $total', style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary,
                )),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: progreso.hitos
                  .map((hito) => _buildHitoChip(hito))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHitoChip(HitoModel hito) {
    final desbloqueado = hito.desbloqueado;

    final colorBorde = desbloqueado
        ? AppColors.accentPrimary.withValues(alpha: 0.5)
        : AppColors.borderSubtle;
    final colorFondo = desbloqueado
        ? AppColors.accentPrimary.withValues(alpha: 0.12)
        : AppColors.backgroundCard;

    return Opacity(
      opacity: desbloqueado ? 1.0 : 0.45,
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorBorde),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: _buildHitoVisual(hito),
            ),
            const SizedBox(height: 8),
            Text(
              hito.nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              desbloqueado ? Icons.check_circle : Icons.lock_outline,
              size: 14,
              color: desbloqueado ? AppColors.success : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHitoVisual(HitoModel hito) {
    // Sin URL → emoji directo (fallback).
    if (hito.imagenUrl.isEmpty) {
      return Center(child: Text(hito.emoji, style: const TextStyle(fontSize: 32)));
    }

    // Con URL → intenta cargar; si falla o carga, cae al emoji.
    return ClipOval(
      child: Image.network(
        hito.imagenUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null
                ? child
                : Center(child: Text(hito.emoji, style: const TextStyle(fontSize: 32))),
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text(hito.emoji, style: const TextStyle(fontSize: 32))),
      ),
    );
  }

  // ── Resumen semanal ──────────────────────────────────────────────────

  Widget _buildResumenSemanal(ProgresoWeeklyModel resumen) {
    final estadoEmoji = _emojisPorEstado[resumen.estadoMasFrecuente] ?? '—';
    final estadoNombre = _nombresPorEstado[resumen.estadoMasFrecuente] ?? resumen.estadoMasFrecuente;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu semana', style: TextStyle(
            fontFamily: 'Cinzel', fontSize: 16,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dia = index < resumen.dias.length ? resumen.dias[index] : null;
              return _buildDiaCircle(index, dia);
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildResumenStat('Días activos', '${resumen.diasActivos}/7')),
              Container(width: 1, height: 32, color: AppColors.borderDefault),
              Expanded(child: _buildResumenStat('Misiones', '${resumen.misionesCompletadas}')),
              Container(width: 1, height: 32, color: AppColors.borderDefault),
              Expanded(child: _buildResumenStat(
                'Estado frecuente',
                resumen.estadoMasFrecuente.isNotEmpty ? '$estadoEmoji $estadoNombre' : '—',
              )),
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
    final emoji = tieneCheckin ? (_emojisPorEstado[dia!.estadoEmocional] ?? '❓') : null;

    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tieneCheckin
                ? AppColors.accentPrimary.withValues(alpha: 0.15)
                : AppColors.backgroundCard,
            border: Border.all(
              color: tieneCheckin
                  ? AppColors.accentPrimary.withValues(alpha: 0.5)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(emoji ?? '·', style: TextStyle(fontSize: tieneCheckin ? 18 : 14)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 11,
          fontWeight: FontWeight.w400, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 2),
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dia?.misionCompletada == true ? AppColors.success : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenStat(String label, String valor) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 14,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary,
        )),
      ],
    );
  }

  // ── HU-13: Línea de tiempo ───────────────────────────────────────────

  Widget _buildLineaDeTiempo(ProgresoWeeklyModel resumen) {
    final diasConDatos = resumen.dias
        .where((d) => d.estadoEmocional != null)
        .toList()
        .reversed
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Historial', style: TextStyle(
                fontFamily: 'Cinzel', fontSize: 16,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary,
              )),
              const Spacer(),
              Text(
                '${diasConDatos.length} día${diasConDatos.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (diasConDatos.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: Text(
                  'Aún no hay registros esta semana.\nCompleta tu primer check-in para ver tu historial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    color: AppColors.textSecondary, height: 1.5,
                  ),
                ),
              ),
            )
          else
            ...diasConDatos.asMap().entries.map((entry) {
              final i = entry.key;
              final dia = entry.value;
              final esUltimo = i == diasConDatos.length - 1;
              return _buildEntradaTimeline(dia, esUltimo);
            }),
        ],
      ),
    );
  }

  Widget _buildEntradaTimeline(CheckinDiaModel dia, bool esUltimo) {
    final emoji = _emojisPorEstado[dia.estadoEmocional] ?? '❓';
    final nombreEstado = _nombresPorEstado[dia.estadoEmocional] ?? dia.estadoEmocional ?? '';

    String fechaFormateada = dia.fecha;
    try {
      final partes = dia.fecha.split('-');
      if (partes.length == 3) {
        const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                       'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
        final mes = int.parse(partes[1]) - 1;
        fechaFormateada = '${partes[2]} ${meses[mes]}';
      }
    } catch (_) {}

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.5)),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
                ),
                if (!esUltimo)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.borderDefault,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fechaFormateada, style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: AppColors.textSecondary,
                          )),
                          const SizedBox(height: 4),
                          Text(nombreEstado, style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 14,
                            fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                          )),
                        ],
                      ),
                    ),
                    if (dia.misionCompletada)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: const Text('✅ Misión', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.success, fontWeight: FontWeight.w500,
                        )),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.borderDefault,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Sin misión', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.textSecondary,
                        )),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}