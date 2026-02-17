@echo off
setlocal
set REPO_NAME=GastosApp

:MENU
cls
echo ==========================================
echo    SISTEMA DE DESPLIEGUE - GASTOS APP
echo ==========================================
echo 1) Despliegue LOCAL (Compila y sube a gh-pages)
echo 2) Despliegue CLOUD (Solo sube a master, GitHub compila)
echo 3) Salir
echo ==========================================
set /p opt="Selecciona una opcion: "

if "%opt%"=="1" goto LOCAL
if "%opt%"=="2" goto CLOUD
if "%opt%"=="3" goto EXIT
goto MENU

:LOCAL
echo [+] Limpiando proyecto...
call flutter clean
echo [+] Obteniendo dependencias...
call flutter pub get
echo [+] Compilando Flutter Web...
call flutter build web --release
if errorlevel 1 (
    echo [!] Error en la compilacion.
    pause
    goto MENU
)

echo [+] Corrigiendo base-href en index.html...
powershell -Command "(Get-Content build/web/index.html) -replace '<base href=\"/\"', '<base href=\"/%REPO_NAME%/\"' | Set-Content build/web/index.html"

echo [+] Subiendo codigo fuente a master...
git add .
git commit -m "update: source code before local deploy"
git push origin master

echo [+] Preparando rama gh-pages...
:: Borrar rama local si existe
git branch -D gh-pages >nul 2>&1
:: Crear rama orphan
git checkout --orphan gh-pages
:: Limpiar archivos de la rama
git rm -rf . >nul 2>&1

echo [+] Copiando archivos de build...
xcopy build\web\* . /E /Y /H >nul

echo [+] Subiendo a GitHub Pages...
git add .
git commit -m "deploy: manual web update"
git push origin gh-pages --force

echo [+] Limpiando y volviendo a master...
git checkout master
echo ==========================================
echo [!] DESPLIEGUE LOCAL COMPLETADO CON EXITO
echo ==========================================
pause
goto MENU

:CLOUD
echo [+] Subiendo cambios a GitHub...
git add .
set /p msg="Ingresa mensaje de los cambios: "
git commit -m "%msg%"
git push origin master
echo ==========================================
echo [!] CAMBIOS SUBIDOS.
echo GitHub Actions compilara y desplegara pronto.
echo ==========================================
pause
goto MENU

:EXIT
echo Saliendo...
exit
