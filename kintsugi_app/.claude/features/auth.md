# Feature: Autenticación y Onboarding

## HU-01 Registro con email y contraseña
### Criterios técnicos
- Mínimo 8 caracteres, 1 mayúscula, 1 número
- Validación local antes de llamar Firebase
- Errores inline debajo de cada campo
- Botón deshabilitado hasta pasar validación local
- Sin flujo de recuperación de contraseña
- Al registrarse → navegar al test de sintonía

## HU-02 Login con email y contraseña
### Criterios técnicos
- Validación local: ambos campos con contenido
- Error genérico: "Correo o contraseña incorrectos"
- Loader visible en botón mientras espera Firebase
- Si onboarding completo → home
- Si onboarding incompleto → test de sintonía

## HU-03 Login con Google o Apple
### Criterios técnicos
- Botones Google y Apple en pantalla de bienvenida
- Si usuario nuevo → flujo de onboarding
- Si usuario existente → home directo
- Si cancela OAuth → regresa a login sin error

## HU-04 Test de sintonía
### Las 4 preguntas con sus opciones y arquetipos

Pregunta 1: ¿Cómo te sientes últimamente?
- 🌑 Vacío → Thorfinn
- 🔥 Frustrado → Rock Lee
- 🌊 Ansioso → Ippo
- 💧 Apagado → Mob
- ⚡ Desmotivado → Asta

Pregunta 2: Cuando algo sale mal, ¿qué haces?
- ⚓ Me quedo enganchado → Thorfinn
- 💪 Me frustro pero sigo → Rock Lee
- 🫣 Le doy vueltas y me bloqueo → Ippo
- 🤐 Lo guardo solo → Mob
- 📢 Lo ignoro y sigo → Asta

Pregunta 3: ¿Cuál frase te suena familiar?
- 🧊 Me cuesta conectar → Thorfinn
- 👥 Veo a otros lograr lo que yo no → Rock Lee
- 😶 Me preocupa lo que piensan → Ippo
- 🫂 Contengo lo que siento → Mob
- 🏃 Sigo aunque nadie crea en mí → Asta

Pregunta 4: ¿Qué necesitas más ahora?
- 🌅 Un propósito → Thorfinn
- 🥋 Reconocimiento → Rock Lee
- 🛡️ Menos miedo → Ippo
- 💬 Soltar emociones → Mob
- 🚀 Creer en mi sueño → Asta

### Lógica de asignación
- Arquetipo con más respuestas = asignado
- En empate → mostrar ambos y dejar elegir
- Al confirmar → guardar en Firestore Y Hive simultáneo
- Usuario no puede avanzar al home