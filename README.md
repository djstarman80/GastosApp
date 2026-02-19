# GastosApp - Gestión de Gastos Personales

Aplicación móvil multiplataforma para gestión de gastos personales desarrollada en Flutter.

## Descripción

GastosApp permite gestionar gastos personales con soporte para múltiples usuarios y tarjetas. Ideal para controlar gastos mensuales, categorizar transacciones y generar resúmenes.

**Características principales:**
- Gestión de usuarios y tarjetas
- Registro de gastos con categorías
- Filtros por mes, usuario y tarjeta
- Resumen mensual de gastos
- Backup y restore de datos
- Soporte multiplataforma: Android, Windows, Web
- Base de datos local SQLite
- Diseño Material Design 3

## Requisitos

- Flutter SDK >=3.11.0
- Dart SDK >=3.11.0
- Android Studio o VS Code
- Android SDK API 34 (Android 14+)

## Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/djstarman80/GastosApp.git
cd GastosApp
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Verificar configuración
```bash
flutter doctor
```

### 4. Ejecutar la aplicación
```bash
flutter run
```

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── core/
│   ├── constants/               # Constantes de la app
│   ├── theme/                   # Tema y estilos
│   └── utils/                   # Utilidades (formateadores)
├── data/
│   ├── database/                # Base de datos SQLite
│   ├── models/                  # Modelos de datos
│   ├── repositories/            # Repositorios
│   └── services/                # Servicios (backup)
├── domain/                      # Lógica de negocio
└── presentation/
    ├── providers/               # Estado (Riverpod)
    ├── router/                  # Rutas (GoRouter)
    ├── screens/                 # Pantallas
    └── widgets/                 # Widgets reutilizables
```

## Funcionalidades

### 1. Gestión de Usuarios
- Crear, editar y eliminar usuarios
- Asignar gastos a usuarios específicos

### 2. Gestión de Tarjetas
- Registrar múltiples tarjetas
- Filtrar gastos por tarjeta

### 3. Registro de Gastos
- Agregar gastos con fecha, monto y categoría
- Editar y eliminar gastos
- Filtros por mes, usuario y tarjeta

### 4. Resúmenes
- Vista mensual de gastos
- Totales por usuario y tarjeta
- Navegación entre meses

### 5. Backup y Restore
- Exportar datos a archivo
- Importar datos desde backup

## Compilación

### Android APK
```bash
flutter build apk --release
```
Resultado: `build/app/outputs/flutter-apk/app-release.apk`

### Windows
```bash
flutter build windows --release
```
Resultado: `build/windows/x64/runner/Release/`

### Web
```bash
flutter build web --release
```
Resultado: `build/web/`

## Demo Web

Disponible en: https://djstarman80.github.io/GastosApp/

## Tecnologías

| Categoría | Tecnología |
|-----------|------------|
| Framework | Flutter 3.11+ |
| Estado | Riverpod |
| Navegación | GoRouter |
| Base de datos | SQLite (sqflite) |
| Almacenamiento | Shared Preferences |
| Inyección | GetIt |

## Base de Datos

### Tablas SQLite:

**usuarios**:
- `id`, `nombre`

**tarjetas**:
- `id`, `nombre`, `usuario_id`

**gastos**:
- `id`, `usuario_id`, `tarjeta_id`, `monto`, `fecha`, `descripcion`, `categoria`

## Licencia

MIT License

## Contacto

Marcelo Pereyra - Desarrollador
