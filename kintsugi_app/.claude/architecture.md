# Arquitectura — Clean Architecture

## Estructura de lib/
lib/
├── core/
│   ├── theme/        # AppTheme, AppColors, AppTextStyles
│   ├── constants/    # AppConstants, AppStrings
│   ├── errors/       # Failures, Exceptions
│   └── utils/        # helpers, extensions
├── data/
│   ├── datasources/
│   │   ├── local/    # Hive datasources
│   │   └── remote/   # Firebase datasources
│   ├── models/       # DTOs con fromJson/toJson
│   └── repositories/ # implementaciones concretas
├── domain/
│   ├── entities/     # objetos de negocio puros
│   ├── repositories/ # interfaces abstractas
│   └── usecases/     # casos de uso
└── presentation/
    ├── blocs/        # BLoCs y Cubits
    ├── screens/      # pantallas completas
    │   ├── auth/
    │   ├── home/
    │   ├── checkin/
    │   ├── mission/
    │   ├── progress/
    │   └── profile/
    └── widgets/      # widgets reutilizables

## Reglas obligatorias
- NUNCA llamar Firebase directamente desde widgets
- BLoCs SOLO hablan con UseCases
- UseCases SOLO hablan con Repository interfaces
- Repositories concretos en data/ implementan interfaces de domain/
- Escribir SIEMPRE en Hive primero, luego Firestore
- Todo BLoC maneja 3 estados: loading, success, error
- Validación local ANTES de cualquier llamada de red

## Flujo de datos
Widget → BLoC → UseCase → Repository (interface)
                               ↓
                    RepositoryImpl (data/)
                       ↓          ↓
                 Hive local    Firebase remote

## Inyección de dependencias
- Usar get_it para registrar todas las dependencias
- Archivo: lib/core/di/injection_container.dart
- Registrar: datasources → repositories → usecases → blocs