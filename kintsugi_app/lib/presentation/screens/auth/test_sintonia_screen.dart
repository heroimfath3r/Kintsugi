import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/presentation/screens/auth/resultado_arquetipo_screen.dart';

// ── Data model ─────────────────────────────────────────────────────────────────

class _Opcion {
  final String emoji;
  final String texto;
  final String arquetipo;

  const _Opcion({
    required this.emoji,
    required this.texto,
    required this.arquetipo,
  });
}

class _Pregunta {
  final String texto;
  final List<_Opcion> opciones;

  const _Pregunta({required this.texto, required this.opciones});
}

const List<_Pregunta> _preguntas = [
  _Pregunta(
    texto: '¿Cómo te sientes últimamente?',
    opciones: [
      _Opcion(emoji: '🌑', texto: 'Vacío', arquetipo: 'thorfinn'),
      _Opcion(emoji: '🔥', texto: 'Frustrado', arquetipo: 'rocklee'),
      _Opcion(emoji: '🌊', texto: 'Ansioso', arquetipo: 'ippo'),
      _Opcion(emoji: '💧', texto: 'Apagado', arquetipo: 'mob'),
      _Opcion(emoji: '⚡', texto: 'Desmotivado', arquetipo: 'asta'),
    ],
  ),
  _Pregunta(
    texto: 'Cuando algo sale mal, ¿qué haces?',
    opciones: [
      _Opcion(emoji: '⚓', texto: 'Me quedo enganchado', arquetipo: 'thorfinn'),
      _Opcion(emoji: '💪', texto: 'Me frustro pero sigo', arquetipo: 'rocklee'),
      _Opcion(emoji: '🫣', texto: 'Le doy vueltas y me bloqueo', arquetipo: 'ippo'),
      _Opcion(emoji: '🤐', texto: 'Lo guardo solo', arquetipo: 'mob'),
      _Opcion(emoji: '📢', texto: 'Lo ignoro y sigo', arquetipo: 'asta'),
    ],
  ),
  _Pregunta(
    texto: '¿Cuál frase te suena familiar?',
    opciones: [
      _Opcion(emoji: '🧊', texto: 'Me cuesta conectar', arquetipo: 'thorfinn'),
      _Opcion(emoji: '👥', texto: 'Veo a otros lograr lo que yo no', arquetipo: 'rocklee'),
      _Opcion(emoji: '😶', texto: 'Me preocupa lo que piensan', arquetipo: 'ippo'),
      _Opcion(emoji: '🫂', texto: 'Contengo lo que siento', arquetipo: 'mob'),
      _Opcion(emoji: '🏃', texto: 'Sigo aunque nadie crea en mí', arquetipo: 'asta'),
    ],
  ),
  _Pregunta(
    texto: '¿Qué necesitas más ahora?',
    opciones: [
      _Opcion(emoji: '🌅', texto: 'Un propósito', arquetipo: 'thorfinn'),
      _Opcion(emoji: '🥋', texto: 'Reconocimiento', arquetipo: 'rocklee'),
      _Opcion(emoji: '🛡️', texto: 'Menos miedo', arquetipo: 'ippo'),
      _Opcion(emoji: '💬', texto: 'Soltar emociones', arquetipo: 'mob'),
      _Opcion(emoji: '🚀', texto: 'Creer en mi sueño', arquetipo: 'asta'),
    ],
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────

class TestSintoniaScreen extends StatefulWidget {
  const TestSintoniaScreen({super.key});

  @override
  State<TestSintoniaScreen> createState() => _TestSintoniaScreenState();
}

class _TestSintoniaScreenState extends State<TestSintoniaScreen> {
  int _preguntaIndex = 0;
  int? _seleccionada;

  final Map<String, int> _puntos = {
    'thorfinn': 0,
    'rocklee': 0,
    'ippo': 0,
    'mob': 0,
    'asta': 0,
  };

  _Pregunta get _preguntaActual => _preguntas[_preguntaIndex];
  bool get _esUltima => _preguntaIndex == _preguntas.length - 1;

  void _seleccionar(int index) {
    setState(() => _seleccionada = index);
  }

  void _siguiente() {
    if (_seleccionada == null) return;

    final arquetipo = _preguntaActual.opciones[_seleccionada!].arquetipo;
    _puntos[arquetipo] = (_puntos[arquetipo] ?? 0) + 1;

    if (_esUltima) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultadoArquetipoScreen(puntos: Map.from(_puntos)),
        ),
      );
      return;
    }

    setState(() {
      _preguntaIndex++;
      _seleccionada = null;
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // FIX: Botón atrás inteligente
  // Si estamos en pregunta > 0, volver a la pregunta anterior.
  // Si estamos en pregunta 0, no hacer nada (el _AuthGate nos puso aquí,
  // no hay ruta anterior a la cual volver).
  // ══════════════════════════════════════════════════════════════════════
  void _retroceder() {
    if (_preguntaIndex > 0) {
      setState(() {
        _preguntaIndex--;
        _seleccionada = null;
      });
    }
    // Si estamos en la primera pregunta, no hacemos nada.
    // El usuario ya está autenticado y DEBE completar el test.
  }

  @override
  Widget build(BuildContext context) {
    final numero = (_preguntaIndex + 1).toString().padLeft(2, '0');

    return PopScope(
      // Bloquear botón atrás del sistema: el test es obligatorio
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _retroceder();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildProgreso(),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCard(numero),
                ),
              ),
              _buildBotonSiguiente(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _preguntaIndex > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 22),
                    onPressed: _retroceder,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  )
                // En la primera pregunta, no mostramos flecha de atrás
                : const SizedBox(width: 32, height: 32),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Test de Sintonía',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pregunta ${_preguntaIndex + 1} de ${_preguntas.length}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Barra de progreso ────────────────────────────────────────────────────────

  Widget _buildProgreso() {
    final progreso = (_preguntaIndex + 1) / _preguntas.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          height: 6,
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: const Color(0xFF242424),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
          ),
        ),
      ),
    );
  }

  // ── Card de pregunta ─────────────────────────────────────────────────────────

  Widget _buildCard(String numero) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numero,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Color(0x33C9A84C),
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _preguntaActual.texto,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_preguntaActual.opciones.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom:
                      i < _preguntaActual.opciones.length - 1 ? 10 : 0),
              child: _OpcionCard(
                opcion: _preguntaActual.opciones[i],
                seleccionada: _seleccionada == i,
                onTap: () => _seleccionar(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Botón siguiente ──────────────────────────────────────────────────────────

  Widget _buildBotonSiguiente() {
    final habilitado = _seleccionada != null;
    final label = _esUltima ? 'VER MI RESULTADO' : 'SIGUIENTE';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: habilitado ? _siguiente : null,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.disabled)
                  ? AppColors.accentPrimary.withValues(alpha: 0.5)
                  : AppColors.accentPrimary;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.disabled)
                  ? AppColors.backgroundPrimary.withValues(alpha: 0.5)
                  : AppColors.backgroundPrimary;
            }),
            overlayColor:
                WidgetStateProperty.all(AppColors.accentOverlay),
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ── Opción card ────────────────────────────────────────────────────────────────

class _OpcionCard extends StatelessWidget {
  final _Opcion opcion;
  final bool seleccionada;
  final VoidCallback onTap;

  const _OpcionCard({
    required this.opcion,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 64,
        decoration: BoxDecoration(
          color: seleccionada
              ? const Color(0x26C9A84C)
              : const Color(0xFF242424),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionada
                ? AppColors.accentPrimary
                : const Color(0xFF3A3A3A),
            width: seleccionada ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(opcion.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                opcion.texto,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: seleccionada
                      ? AppColors.accentPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: seleccionada
                  ? const Icon(Icons.check_circle_rounded,
                      key: ValueKey('check'),
                      color: AppColors.accentPrimary,
                      size: 20)
                  : const Icon(Icons.chevron_right_rounded,
                      key: ValueKey('chevron'),
                      color: Color(0xFF3A3A3A),
                      size: 20),
            ),
          ],
        ),
      ),
    );
  }
}