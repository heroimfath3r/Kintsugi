import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';

// ── Datos por arquetipo ────────────────────────────────────────────────────────

class _ArquetipoData {
  final String id;
  final String nombre;
  final String origen;
  final String lucha;
  final String filosofia;
  final String imagenFase1;
  final String imagenFase2;
  final String imagenFase3;

  const _ArquetipoData({
    required this.id,
    required this.nombre,
    required this.origen,
    required this.lucha,
    required this.filosofia,
    required this.imagenFase1,
    required this.imagenFase2,
    required this.imagenFase3,
  });
}

const Map<String, _ArquetipoData> _arquetipos = {
  'thorfinn': _ArquetipoData(
    id: 'thorfinn',
    nombre: 'THORFINN',
    origen: 'Vinland Saga',
    lucha:
        'Cargas con un vacío que el resentimiento no ha podido llenar. Buscas un propósito que reemplace lo que perdiste.',
    filosofia:
        'No tienes enemigos. La verdadera fuerza no es destruir sino construir.',
    imagenFase1: 'assets/avatars/thorfinn_fase1.png',
    imagenFase2: 'assets/avatars/thorfinn_fase2.png',
    imagenFase3: 'assets/avatars/thorfinn_fase3.png',
  ),
  'rocklee': _ArquetipoData(
    id: 'rocklee',
    nombre: 'ROCK LEE',
    origen: 'Naruto',
    lucha:
        'Te dijeron que no podías desde el principio. El sistema nunca estuvo de tu lado y aún así sigues intentándolo.',
    filosofia:
        'El talento no es el único camino. El trabajo constante tiene su propia magia.',
    imagenFase1: 'assets/avatars/rocklee_fase1.png',
    imagenFase2: 'assets/avatars/rocklee_fase2.png',
    imagenFase3: 'assets/avatars/rocklee_fase3.png',
  ),
  'ippo': _ArquetipoData(
    id: 'ippo',
    nombre: 'IPPO',
    origen: 'Hajime no Ippo',
    lucha:
        'El miedo te paraliza antes de empezar. Te preocupa lo que piensan y eso te detiene más que cualquier obstáculo real.',
    filosofia:
        'La valentía no es no tener miedo. Es dar el siguiente paso aunque estés temblando.',
    imagenFase1: 'assets/avatars/ippo_fase1.png',
    imagenFase2: 'assets/avatars/ippo_fase2.png',
    imagenFase3: 'assets/avatars/ippo_fase3.png',
  ),
  'mob': _ArquetipoData(
    id: 'mob',
    nombre: 'MOB',
    origen: 'Mob Psycho 100',
    lucha:
        'Apagas lo que sientes para no afectar a otros. Pero al protegerlos te pierdes a ti mismo.',
    filosofia:
        'Tus emociones no son el enemigo. Sentir no es perder el control.',
    imagenFase1: 'assets/avatars/mob_fase1.png',
    imagenFase2: 'assets/avatars/mob_fase2.png',
    imagenFase3: 'assets/avatars/mob_fase3.png',
  ),
  'asta': _ArquetipoData(
    id: 'asta',
    nombre: 'ASTA',
    origen: 'Black Clover',
    lucha:
        'Tu sueño parece imposible para todos menos para ti. Y esa soledad cansa aunque no lo admitas.',
    filosofia:
        'Nadie puede decirte que es imposible. Eso lo decides tú con tus acciones.',
    imagenFase1: 'assets/avatars/asta_fase1.png',
    imagenFase2: 'assets/avatars/asta_fase2.png',
    imagenFase3: 'assets/avatars/asta_fase3.png',
  ),
};

// ── Screen ─────────────────────────────────────────────────────────────────────

class ResultadoArquetipoScreen extends StatefulWidget {
  final Map<String, int> puntos;

  const ResultadoArquetipoScreen({super.key, required this.puntos});

  @override
  State<ResultadoArquetipoScreen> createState() =>
      _ResultadoArquetipoScreenState();
}

class _ResultadoArquetipoScreenState extends State<ResultadoArquetipoScreen> {
  late String _arquetipoSeleccionado;
  late List<String> _empate;

  @override
  void initState() {
    super.initState();
    _resolverArquetipo();
  }

  void _resolverArquetipo() {
    final puntos = widget.puntos;
    final maxPuntos = puntos.values.reduce((a, b) => a > b ? a : b);
    final ganadores =
        puntos.entries.where((e) => e.value == maxPuntos).map((e) => e.key).toList();

    if (ganadores.length == 1) {
      _arquetipoSeleccionado = ganadores.first;
      _empate = [];
    } else {
      // Empate: mostrar el primero por defecto, el usuario puede cambiar
      _arquetipoSeleccionado = ganadores.first;
      _empate = ganadores;
    }
  }

  _ArquetipoData get _data => _arquetipos[_arquetipoSeleccionado]!;

  bool get _hayEmpate => _empate.length > 1;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Imagen de fondo full screen
          Positioned.fill(
            child: Image.asset(
              _data.imagenFase1,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const ColoredBox(
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Gradiente: visible top 20% → #0D0D0D desde middle → sólido bottom 55%
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.20, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xCC0D0D0D),
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
          ),
          // Contenido
          SafeArea(
            child: Column(
              children: [
                _buildBackButton(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildPill(),
                        const SizedBox(height: 20),
                        _buildNombre(),
                        const SizedBox(height: 28),
                        _buildCard(),
                        const SizedBox(height: 28),
                        _buildBotonPrincipal(context),
                        const SizedBox(height: 16),
                        _buildVerOtros(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Back button ────────────────────────────────────────────────────────────

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ),
    );
  }

  // ── Pill "Tu arquetipo" ────────────────────────────────────────────────────

  Widget _buildPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x33C9A84C), // #C9A84C al 20%
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.accentPrimary),
        ),
        child: const Text(
          'TU ARQUETIPO',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentPrimary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ── Nombre + origen ────────────────────────────────────────────────────────

  Widget _buildNombre() {
    return Column(
      children: [
        Text(
          _data.nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _data.origen,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.accentPrimary,
          ),
        ),
      ],
    );
  }

  // ── Card descripción ───────────────────────────────────────────────────────

  Widget _buildCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xE61A1A1A), // #1A1A1A al 90%
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccion(
              label: 'TU LUCHA',
              texto: _data.lucha,
              isItalic: false,
              textColor: AppColors.textPrimary,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFF2A2A2A), height: 1),
            ),
            _buildSeccion(
              label: 'TU FILOSOFÍA',
              texto: '"${_data.filosofia}"',
              isItalic: true,
              textColor: AppColors.accentPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String label,
    required String texto,
    required bool isItalic,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          texto,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Botón principal ────────────────────────────────────────────────────────

  Widget _buildBotonPrincipal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // TODO: guardar arquetipo en Firestore + Hive, navegar al Home
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const _Homeplaceholder()),
              (_) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: AppColors.backgroundPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          child: const Text('COMENZAR MI CAMINO'),
        ),
      ),
    );
  }

  // ── Ver otros arquetipos ───────────────────────────────────────────────────

  Widget _buildVerOtros(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarSelectorArquetipos(context),
      child: const Text(
        'Este no soy yo, ver otros arquetipos',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _mostrarSelectorArquetipos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SelectorArquetiposSheet(
        arquetipoActual: _arquetipoSeleccionado,
        empate: _hayEmpate ? _empate : _arquetipos.keys.toList(),
        onSeleccionado: (id) {
          setState(() => _arquetipoSeleccionado = id);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Bottom sheet selector ──────────────────────────────────────────────────────

class _SelectorArquetiposSheet extends StatelessWidget {
  final String arquetipoActual;
  final List<String> empate;
  final ValueChanged<String> onSeleccionado;

  const _SelectorArquetiposSheet({
    required this.arquetipoActual,
    required this.empate,
    required this.onSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final lista = empate.isNotEmpty ? empate : _arquetipos.keys.toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Elige tu arquetipo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...lista.map((id) {
            final data = _arquetipos[id]!;
            final isActual = id == arquetipoActual;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSeleccionado(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 60,
                  decoration: BoxDecoration(
                    color: isActual
                        ? const Color(0x26C9A84C)
                        : const Color(0xFF242424),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActual
                          ? AppColors.accentPrimary
                          : const Color(0xFF3A3A3A),
                      width: isActual ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.nombre,
                              style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActual
                                    ? AppColors.accentPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              data.origen,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActual)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accentPrimary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Home placeholder ───────────────────────────────────────────────────────────

class _Homeplaceholder extends StatelessWidget {
  const _Homeplaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Text(
          'Home — próximamente',
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
