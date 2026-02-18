@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: SMART DEPLOY - Script Universal Flutter
:: Detecta automaticamente proyecto, git y GitHub
:: ==========================================

:: ===== DETECCION AUTOMATICA =====

:: 1. Directorio del proyecto (donde esta el script)
set "PROJECT_PATH=%~dp0"
set "PROJECT_PATH=%PROJECT_PATH:~0,-1%"

:: 2. Nombre del proyecto desde pubspec.yaml
if exist "%PROJECT_PATH%\pubspec.yaml" (
    for /f "tokens=2 delims=: " %%a in ('findstr /b "name:" "%PROJECT_PATH%\pubspec.yaml"') do (
        set "PROJECT_NAME=%%a"
    )
) else (
    echo.
    echo [ERROR] No se encontro pubspec.yaml en:
    echo        %PROJECT_PATH%
    echo.
    pause
    exit /b 1
)

:: 3. Descripcion del proyecto desde pubspec.yaml
if exist "%PROJECT_PATH%\pubspec.yaml" (
    for /f "tokens=1,* delims=:" %%a in ('findstr /b "description:" "%PROJECT_PATH%\pubspec.yaml"') do (
        set "DISPLAY_NAME=%%b"
    )
    :: Limpiar espacios iniciales y limitar longitud
    for /f "tokens=*" %%c in ("!DISPLAY_NAME!") do set "DISPLAY_NAME=%%c"
)

:: 4. Nombre de carpeta
for %%f in ("%PROJECT_PATH%") do set "FOLDER_NAME=%%~nxf"

:: 5. Version del proyecto
if exist "%PROJECT_PATH%\pubspec.yaml" (
    for /f "tokens=2 delims=: " %%a in ('findstr /b "version:" "%PROJECT_PATH%\pubspec.yaml"') do (
        set "PROJECT_VERSION=%%a"
    )
)

:: ===== DETECCION DE GIT =====

set "GIT_DETECTED=NO"
set "GIT_BRANCH="
set "GIT_REMOTE_URL="

cd /d "%PROJECT_PATH%"
git rev-parse --git-dir >nul 2>&1
if !errorlevel!==0 (
    set "GIT_DETECTED=YES"
    
    :: Obtener branch actual
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "GIT_BRANCH=%%b"
    
    :: Obtener remote URL
    git remote get-url origin >nul 2>&1
    if !errorlevel!==0 (
        for /f "tokens=*" %%r in ('git remote get-url origin') do set "GIT_REMOTE_URL=%%r"
        call :PARSE_GITHUB_URL "!GIT_REMOTE_URL!"
    )
)

:: ===== CARGAR CONFIGURACION LOCAL =====

if not defined GITHUB_USER (
    if exist "%PROJECT_PATH%\deploy_config.bat" (
        call "%PROJECT_PATH%\deploy_config.bat"
        set "CONFIG_SOURCE=deploy_config.bat"
    )
)

:: ===== MOSTRAR DETECCION =====

:SHOW_DETECTION
cls
echo ==========================================
echo     SMART DEPLOY - DETECCION AUTOMATICA
echo ==========================================
echo.

:: Seccion PROYECTO
if defined PROJECT_NAME (
    echo [OK] PROYECTO
) else (
    echo [X]  PROYECTO - No detectado
)
echo     Nombre:        !PROJECT_NAME!
if defined DISPLAY_NAME echo     Descripcion:   !DISPLAY_NAME!
if defined PROJECT_VERSION echo     Version:       !PROJECT_VERSION!
echo     Carpeta:       !FOLDER_NAME!
echo     Ruta:          !PROJECT_PATH!
echo.

:: Seccion GIT
if "%GIT_DETECTED%"=="YES" (
    echo [OK] GIT
    echo     Repositorio:   Detectado
    if defined GIT_BRANCH echo     Branch:        !GIT_BRANCH!
    if defined GIT_REMOTE_URL echo     Remote:        !GIT_REMOTE_URL!
) else (
    echo [!]  GIT
    echo     Repositorio:   No detectado
    if exist "%PROJECT_PATH%\deploy_config.bat" (
        echo     Configuracion: Cargada desde deploy_config.bat
    ) else (
        echo     Configuracion: No encontrada
    )
)
echo.

:: Seccion GITHUB
if defined GITHUB_USER (
    if "!GITHUB_USER!"=="%GITHUB_USER%" (
        echo [OK] GITHUB
    ) else (
        echo [OK] GITHUB
    )
) else (
    echo [X]  GITHUB - Requiere configuracion
)
echo     Usuario:       !GITHUB_USER!
echo     Repositorio:   !REPO_NAME!
if defined GITHUB_USER (
    if defined REPO_NAME (
        echo     URL Pages:     https://!GITHUB_USER!.github.io/!REPO_NAME!/
    )
)
echo.

:: ===== VERIFICAR SI FALTA CONFIGURACION =====

if not defined GITHUB_USER (
    echo ==========================================
    echo [!] Se requiere configuracion de GitHub
    echo ==========================================
    echo.
    call :ASK_GITHUB_CONFIG
    echo.
    goto SHOW_DETECTION
)

:: ===== CONFIRMACION =====

echo ==========================================
echo La informacion detectada es correcta?
echo.
echo   [S] Si, continuar al menu principal
echo   [N] No, reconfigurar GitHub
echo   [C] Cancelar y salir
echo ==========================================
set /p confirm="Selecciona una opcion: "

if /i "%confirm%"=="S" goto MENU
if /i "%confirm%"=="N" (
    call :ASK_GITHUB_CONFIG
    goto SHOW_DETECTION
)
if /i "%confirm%"=="C" goto EXIT
goto SHOW_DETECTION

:: ===== MENU PRINCIPAL =====

:MENU
cls
echo ==========================================
echo     SMART DEPLOY - !DISPLAY_NAME!
echo ==========================================
echo  Proyecto:  !PROJECT_NAME!
echo  Version:   !PROJECT_VERSION!
echo  GitHub:    !GITHUB_USER!/!REPO_NAME!
echo ==========================================
echo.
echo  1) Desplegar WEB (GitHub Pages)
echo  2) Compilar Web (local)
echo  3) Compilar Windows
echo  4) Compilar Android APK
echo  5) Ver info del proyecto
echo  6) Reconfigurar GitHub
echo  7) Limpiar proyecto (flutter clean)
echo  8) Salir
echo.
echo ==========================================
set /p opt="Selecciona una opcion: "

if "%opt%"=="1" goto DEPLOY_WEB
if "%opt%"=="2" goto BUILD_WEB
if "%opt%"=="3" goto BUILD_WINDOWS
if "%opt%"=="4" goto BUILD_ANDROID
if "%opt%"=="5" goto SHOW_INFO
if "%opt%"=="6" goto CONFIG_GITHUB
if "%opt%"=="7" goto CLEAN_PROJECT
if "%opt%"=="8" goto EXIT
goto MENU

:: ===== DESPLEGAR WEB (GITHUB PAGES) =====

:DEPLOY_WEB
echo.
echo ==========================================
echo [1/5] Limpiando proyecto...
echo ==========================================
cd /d "%PROJECT_PATH%"
call flutter clean >nul 2>&1

echo.
echo ==========================================
echo [2/5] Obteniendo dependencias...
echo ==========================================
call flutter pub get
if errorlevel 1 (
    echo [!] Error obteniendo dependencias
    pause
    goto MENU
)

echo.
echo ==========================================
echo [3/5] Compilando Flutter Web (Release)...
echo ==========================================
call flutter build web --release --base-href "/%REPO_NAME%/" --no-tree-shake-icons
if errorlevel 1 (
    echo [!] Error en la compilacion
    pause
    goto MENU
)

echo.
echo ==========================================
echo [4/5] Preparando repositorio para deploy...
echo ==========================================

:: Crear directorio de deploy temporal
set "DEPLOY_DIR=%TEMP%\%REPO_NAME%_deploy"
if exist "%DEPLOY_DIR%" rd /s /q "%DEPLOY_DIR%"
mkdir "%DEPLOY_DIR%"
cd /d "%DEPLOY_DIR%"

:: Inicializar repositorio git
git init
git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git

:: Verificar si existe branch gh-pages remoto
git fetch origin gh-pages 2>nul
if errorlevel 1 (
    echo     Creando nuevo branch gh-pages...
    git checkout -b gh-pages
) else (
    echo     Descargando branch gh-pages existente...
    git checkout -b gh-pages origin/gh-pages
)

:: Limpiar archivos antiguos
for /f "tokens=*" %%i in ('dir /b /a-d 2^>nul ^| findstr /v /i ".git"') do del "%%i" /f /q 2>nul
for /f "tokens=*" %%i in ('dir /b /ad 2^>nul ^| findstr /v /i ".git"') do rd "%%i" /s /q 2>nul

:: Copiar nuevo build
echo     Copiando archivos compilados...
xcopy "%PROJECT_PATH%\build\web\*" "%DEPLOY_DIR%" /s /e /y /h >nul

echo.
echo ==========================================
echo [5/5] Subiendo a GitHub Pages...
echo ==========================================
git add .
git commit -m "Deploy: %date% %time%"
git push origin gh-pages --force

if errorlevel 1 (
    echo [!] Error subiendo a GitHub
    pause
    goto MENU
)

echo.
echo ==========================================
echo [OK] DESPLIEGUE COMPLETADO
echo ==========================================
echo.
echo  URL: https://%GITHUB_USER%.github.io/%REPO_NAME%/
echo.
echo ==========================================
pause
goto MENU

:: ===== COMPILAR WEB (LOCAL) =====

:BUILD_WEB
echo.
echo ==========================================
echo Compilando Flutter Web (local)...
echo ==========================================
cd /d "%PROJECT_PATH%"
call flutter build web --release --base-href "/%REPO_NAME%/" --no-tree-shake-icons
if errorlevel 1 (
    echo [!] Error en la compilacion
    pause
    goto MENU
)
echo.
echo [OK] Build terminado en:
echo     %PROJECT_PATH%\build\web
echo.
start "" "%PROJECT_PATH%\build\web"
pause
goto MENU

:: ===== COMPILAR WINDOWS =====

:BUILD_WINDOWS
echo.
echo ==========================================
echo Compilando Windows...
echo ==========================================
cd /d "%PROJECT_PATH%"
call flutter build windows --release
if errorlevel 1 (
    echo [!] Error en la compilacion
    pause
    goto MENU
)
echo.
echo [OK] Build terminado en:
echo     %PROJECT_PATH%\build\windows\x64\runner\Release
echo.
start "" "%PROJECT_PATH%\build\windows\x64\runner\Release"
pause
goto MENU

:: ===== COMPILAR ANDROID APK =====

:BUILD_ANDROID
echo.
echo ==========================================
echo Compilando Android APK...
echo ==========================================
cd /d "%PROJECT_PATH%"
call flutter build apk --release
if errorlevel 1 (
    echo [!] Error en la compilacion
    pause
    goto MENU
)
echo.
echo [OK] APK generado en:
echo     %PROJECT_PATH%\build\app\outputs\flutter-apk
echo.
start "" "%PROJECT_PATH%\build\app\outputs\flutter-apk"
pause
goto MENU

:: ===== MOSTRAR INFO DEL PROYECTO =====

:SHOW_INFO
cls
echo ==========================================
echo     INFORMACION DEL PROYECTO
echo ==========================================
echo.
echo  PROYECTO
echo  ----------------------------------------
echo  Nombre:        !PROJECT_NAME!
if defined DISPLAY_NAME echo  Descripcion:   !DISPLAY_NAME!
if defined PROJECT_VERSION echo  Version:       !PROJECT_VERSION!
echo  Carpeta:       !FOLDER_NAME!
echo  Ruta:          !PROJECT_PATH!
echo.
echo  GIT
echo  ----------------------------------------
if "%GIT_DETECTED%"=="YES" (
    echo  Repositorio:   Detectado
    if defined GIT_BRANCH echo  Branch:        !GIT_BRANCH!
    if defined GIT_REMOTE_URL echo  Remote:        !GIT_REMOTE_URL!
) else (
    echo  Repositorio:   No detectado
)
echo.
echo  GITHUB
echo  ----------------------------------------
echo  Usuario:       !GITHUB_USER!
echo  Repositorio:   !REPO_NAME!
echo  URL Pages:     https://!GITHUB_USER!.github.io/!REPO_NAME!/
echo.
echo ==========================================
pause
goto MENU

:: ===== CONFIGURAR GITHUB =====

:CONFIG_GITHUB
call :ASK_GITHUB_CONFIG
pause
goto SHOW_DETECTION

:: ===== LIMPIAR PROYECTO =====

:CLEAN_PROJECT
echo.
echo ==========================================
echo Limpiando proyecto...
echo ==========================================
cd /d "%PROJECT_PATH%"
call flutter clean
echo [OK] Proyecto limpiado
pause
goto MENU

:: ===== FUNCIONES AUXILIARES =====

:PARSE_GITHUB_URL
:: Parsea URL de GitHub (https o SSH)
set "url=%~1"

:: Limpiar variables
set "GITHUB_USER="
set "REPO_NAME="

:: Formato: https://github.com/USUARIO/REPO.git
echo !url! | findstr "github.com" >nul
if !errorlevel!==0 (
    :: Extraer partes de la URL
    for /f "tokens=2,3 delims=:/" %%x in ("!url!") do (
        if "%%x"=="github.com" (
            :: Formato https://github.com/USUARIO/REPO
            for /f "tokens=3,4 delims=/" %%a in ("!url!") do (
                set "GITHUB_USER=%%a"
                set "REPO_NAME=%%b"
            )
        ) else if "%%y"=="github.com" (
            :: Formato git@github.com:USUARIO/REPO
            for /f "tokens=2,3 delims=:/" %%a in ("!url!") do (
                set "GITHUB_USER=%%a"
                set "REPO_NAME=%%b"
            )
        )
    )
)

:: Quitar .git del nombre del repo
if defined REPO_NAME (
    set "REPO_NAME=!REPO_NAME:.git=!"
)

goto :EOF

:ASK_GITHUB_CONFIG
echo.
echo Ingresa la configuracion de GitHub:
echo.
set "NEW_USER="
set "NEW_REPO="
set /p "NEW_USER=Usuario de GitHub: "
set /p "NEW_REPO=Nombre del repositorio: "

if defined NEW_USER set "GITHUB_USER=!NEW_USER!"
if defined NEW_REPO set "REPO_NAME=!NEW_REPO!"

:: Guardar configuracion
echo set "GITHUB_USER=!GITHUB_USER!" > "%PROJECT_PATH%\deploy_config.bat"
echo set "REPO_NAME=!REPO_NAME!" >> "%PROJECT_PATH%\deploy_config.bat"

echo.
echo [+] Configuracion guardada en deploy_config.bat
goto :EOF

:EXIT
echo.
echo Saliendo...
exit /b 0
