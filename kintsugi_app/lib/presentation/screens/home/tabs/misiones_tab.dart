// Archivo NUEVO — crear en:
// lib/presentation/screens/home/tabs/misiones_tab.dart

import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/data/models/mision_model.dart';
import 'package:kintsugi_app/data/services/mision_service.dart';

class MisionesTab extends StatefulWidget {
  final String arquetipoId;

  const MisionesTab({super.key, required this.arquetipoId});

  @override
  State<MisionesTab> createState() => _MisionesTabState();
}

class _MisionesTabState extends State<MisionesTab> {
  final MisionService _misionService = sl<MisionService>();

  bool _isLoading = true;
  String? _error;
  MisionModel? _misionHoy;
  List<MisionModel> _historial = [];

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
        _tryGetMisionHoy(),
        _misionService.getHistorial(),
      ]);

      if (mounted) {
        setState(() {
          _misionHoy = resultados[0] as MisionModel?;
          _historial = resultados[1] as List<MisionModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error cargando misiones';
          _isLoading = false;
        });
      }
    }
  }

  Future<MisionModel?> _tryGetMisionHoy() async {
    try {
      return await _misionService.getMisionDiaria();
    } catch (_) {
      return null;
    }
  }

  Future<void> _completarMision(String misionId) async {
    try {
      await _misionService.completarMision(misionId);
      await _cargarDatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al completar la misión')),
        );
      }
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
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

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.accentPrimary,
      backgroundColor: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Tu misión de hoy',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Misión del día
            if (_misionHoy != null) _buildMisionDelDia(_misionHoy!),
            if (_misionHoy == null) _buildSinMision(),
            const SizedBox(height: 32),
            // Historial
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Historial de misiones',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (_historial.isEmpty) _buildHistorialVacio(),
            ..._historial.map(_buildMisionHistorial),
          ],
        ),
      ),
    );
  }

  Widget _buildMisionDelDia(MisionModel mision) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mision.completada
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con tipo y estado
          Row(
            children: [
              Icon(
                _iconoPorTipo(mision.tipo),
                color: AppColors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
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
              const Spacer(),
              if (mision.completada)
                const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Completada',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            mision.titulo,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Descripción completa (sin truncar)
          Text(
            mision.descripcion,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          // Botón de completar
          if (!mision.completada) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text(
                        '¿Completaste esta misión?',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      content: const Text(
                        'Confirma que realizaste la misión. Esta acción no se puede deshacer.',
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
                            _completarMision(mision.id);
                          },
                          child: const Text(
                            'Sí, la completé',
                            style: TextStyle(color: AppColors.accentPrimary),
                          ),
                        ),
                      ],
                    ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSinMision() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(Icons.self_improvement_rounded,
              color: AppColors.textSecondary, size: 40),
          SizedBox(height: 12),
          Text(
            'Realiza tu check-in emocional primero',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tu misión se asigna según cómo te sientas hoy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialVacio() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Text(
          'Aún no tienes misiones completadas.\nCompleta tu primera misión hoy.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMisionHistorial(MisionModel mision) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ícono de tipo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconoPorTipo(mision.tipo),
                color: AppColors.accentPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Info de la misión
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mision.titulo,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mision.tipoLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Estado
            Icon(
              mision.completada
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: mision.completada
                  ? AppColors.success
                  : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'reflexion':
        return Icons.psychology_rounded;
      case 'accion':
        return Icons.directions_run_rounded;
      case 'respiracion':
        return Icons.air_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}