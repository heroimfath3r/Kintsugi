import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';
import 'package:kintsugi_app/application/auth/auth_state.dart';
import 'package:kintsugi_app/presentation/screens/auth/forgot_password_screen.dart';

enum AuthMode { register, login }

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;

  const AuthScreen({super.key, this.initialMode = AuthMode.register});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim());

  bool _isValidPassword(String v) =>
      v.length >= 8 &&
      v.contains(RegExp(r'[A-Z]')) &&
      v.contains(RegExp(r'[0-9]'));

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final pw = _passwordController.text;
    if (email.isEmpty || !_isValidEmail(email)) return false;
    if (pw.isEmpty || pw.length < 8) return false; // Fix #51: mínimo 8 caracteres en login
    if (_mode == AuthMode.register) {
      if (!_isValidPassword(pw)) return false;
      if (_confirmPasswordController.text != pw) return false;
    }
    return true;
  }

  void _validateAndSubmit() {
    final email = _emailController.text.trim();
    final pw = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    setState(() {
      _emailError = email.isEmpty
          ? 'El correo es requerido'
          : !_isValidEmail(email)
              ? 'Correo inválido'
              : null;

      _passwordError = pw.isEmpty
          ? 'La contraseña es requerida'
          : pw.length < 8
              ? 'La contraseña debe tener al menos 8 caracteres' // Fix #51
              : (_mode == AuthMode.register && !_isValidPassword(pw))
                  ? 'No cumple los requisitos'
                  : null;

      if (_mode == AuthMode.register) {
        _confirmPasswordError = confirm.isEmpty
            ? 'Confirma tu contraseña'
            : confirm != pw
                ? 'Las contraseñas no coinciden'
                : null;
      }
    });

    if (!_isFormValid) return;

    // Disparar evento al BLoC
    if (_mode == AuthMode.register) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(email: email, password: pw),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthLoginRequested(email: email, password: pw),
          );
    }
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            const Positioned.fill(
              child: ColoredBox(color: Color(0xD90D0D0D)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildToggle(),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: _mode == AuthMode.register
                          ? _buildRegisterFields()
                          : _buildLoginFields(),
                    ),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    const SizedBox(height: 24),
                    _buildLegalText(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'KINTSUGI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.accentPrimary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu camino comienza aquí',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Toggle ────────────────────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(child: _toggleOption('Crear cuenta', AuthMode.register)),
          Expanded(child: _toggleOption('Iniciar sesión', AuthMode.login)),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, AuthMode mode) {
    final isActive = _mode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? AppColors.backgroundPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Fields ────────────────────────────────────────────────────────────

  Widget _buildRegisterFields() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _emailField(),
        const SizedBox(height: 14),
        _passwordField(),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '• Mín 8 caracteres   • Una mayúscula   • Un número',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _confirmPasswordField(),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _emailField(),
        const SizedBox(height: 14),
        _passwordField(),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen(),
              ));
            },
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.accentPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: _inputTextStyle,
      decoration: InputDecoration(
        hintText: 'correo@ejemplo.com',
        prefixIcon: const Icon(Icons.mail_outline,
            color: AppColors.textSecondary, size: 20),
        errorText: _emailError,
        errorStyle: _errorStyle,
      ),
      onChanged: (_) => setState(() => _emailError = null),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      style: _inputTextStyle,
      decoration: InputDecoration(
        hintText: 'Mínimo 8 caracteres',
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.textSecondary, size: 20),
        errorText: _passwordError,
        errorStyle: _errorStyle,
        suffixIcon: _eyeButton(
          visible: _passwordVisible,
          onTap: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      onChanged: (_) => setState(() => _passwordError = null),
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_confirmPasswordVisible,
      style: _inputTextStyle,
      decoration: InputDecoration(
        hintText: 'Repite tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.textSecondary, size: 20),
        errorText: _confirmPasswordError,
        errorStyle: _errorStyle,
        suffixIcon: _eyeButton(
          visible: _confirmPasswordVisible,
          onTap: () => setState(
              () => _confirmPasswordVisible = !_confirmPasswordVisible),
        ),
      ),
      onChanged: (_) => setState(() => _confirmPasswordError = null),
    );
  }

  Widget _eyeButton({required bool visible, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  static const _inputTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const _errorStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: AppColors.error,
  );

  // ── Submit button ─────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final label =
            _mode == AuthMode.register ? 'CREAR CUENTA' : 'INICIAR SESIÓN';

        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.backgroundPrimary,
              disabledBackgroundColor:
                  AppColors.accentPrimary.withValues(alpha: 0.5),
              disabledForegroundColor:
                  AppColors.backgroundPrimary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.backgroundPrimary),
                    ),
                  )
                : Text(label),
          ),
        );
      },
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderDefault)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'o continúa con',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.borderDefault)),
      ],
    );
  }

  // ── Social buttons ────────────────────────────────────────────────────

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: const _GoogleIcon(),
            onPressed: () {
              // TODO: Google Sign In
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: const Icon(Icons.apple,
                size: 20, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Apple Sign In
            },
          ),
        ),
      ],
    );
  }

  // ── Legal text ────────────────────────────────────────────────────────

  Widget _buildLegalText() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'Al registrarte, aceptas nuestros '),
          TextSpan(
            text: 'Términos de servicio',
            style: const TextStyle(
              color: AppColors.accentPrimary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accentPrimary,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: ' y '),
          TextSpan(
            text: 'Política de privacidad',
            style: const TextStyle(
              color: AppColors.accentPrimary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accentPrimary,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ── Social button ───────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF242424),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFF3A3A3A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google G icon ───────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final strokeW = size.width * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - strokeW / 2),
      _deg(-70), _deg(155), false, paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - strokeW / 2),
      _deg(-225), _deg(90), false, paint,
    );
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - strokeW / 2),
      _deg(-135), _deg(65), false, paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - strokeW / 2),
      _deg(85), _deg(50), false, paint,
    );

    paint
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r - strokeW / 2, c.dy),
      paint,
    );
  }

  double _deg(double degrees) => degrees * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}