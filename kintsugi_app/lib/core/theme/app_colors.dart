import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Fondos
  static const Color backgroundPrimary = Color(0xFF0D0D0D);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);
  static const Color backgroundCard = Color(0xFF242424);

  // Acento
  static const Color accentPrimary = Color(0xFFC9A84C);
  static const Color accentSecondary = Color(0xFF8B6914);

  // Texto
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF616161);

  // Estados del sistema
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFFFB300);

  // Bordes
  static const Color borderDefault = Color(0xFF2A2A2A);
  static const Color borderActive = Color(0xFFC9A84C);
  static const Color borderSubtle = Color(0xFF3A3A3A);

  // Estados emocionales
  static const Color emotionFrustracion = Color(0xFFEF5350);
  static const Color emotionVacio = Color(0xFF5C6BC0);
  static const Color emotionMotivacion = Color(0xFFFFB300);
  static const Color emotionCalma = Color(0xFF26A69A);
  static const Color emotionAnsiedad = Color(0xFFAB47BC);

  // Colores por arquetipo
  static const Color arquetipoThorfinn = Color(0xFF5C7A9E);
  static const Color arquetipoRockLee = Color(0xFF4CAF50);
  static const Color arquetipoIppo = Color(0xFF1565C0);
  static const Color arquetipoMob = Color(0xFF7B1FA2);
  static const Color arquetipoAsta = Color(0xFF1B5E20);

  // Transparencias útiles
  static const Color accentOverlay = Color(0x26C9A84C);
  static const Color darkOverlay = Color(0xF20D0D0D);
  static const Color cardOverlay = Color(0xCC1A1A1A);

  // Método helper para obtener color por estado emocional
  static Color forEstadoEmocional(String estado) {
    switch (estado) {
      case 'frustracion':
        return emotionFrustracion;
      case 'vacio':
        return emotionVacio;
      case 'motivacion':
        return emotionMotivacion;
      case 'calma':
        return emotionCalma;
      case 'ansiedad':
        return emotionAnsiedad;
      default:
        return accentPrimary;
    }
  }

  // Método helper para obtener color por arquetipo
  static Color forArquetipo(String arquetipoId) {
    switch (arquetipoId) {
      case 'thorfinn':
        return arquetipoThorfinn;
      case 'rocklee':
        return arquetipoRockLee;
      case 'ippo':
        return arquetipoIppo;
      case 'mob':
        return arquetipoMob;
      case 'asta':
        return arquetipoAsta;
      default:
        return accentPrimary;
    }
  }
}