@echo off
rem Compila src\animal.lpi para bin\animal.exe e gera o instalador em bin\
rem com o Inno Setup 6. Requer Lazarus (lazbuild) com o pacote
rem openai_simulation e o Inno Setup 6 (ISCC).
setlocal
cd /d "%~dp0"

set "LAZBUILD="
for %%I in (lazbuild.exe) do set "LAZBUILD=%%~$PATH:I"
if not defined LAZBUILD if exist "C:\lazarus\lazbuild.exe" set "LAZBUILD=C:\lazarus\lazbuild.exe"
if not defined LAZBUILD goto sem_lazbuild

set "ISCC="
for %%I in (ISCC.exe) do set "ISCC=%%~$PATH:I"
if not defined ISCC if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%LocalAppData%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LocalAppData%\Programs\Inno Setup 6\ISCC.exe"
if not defined ISCC goto sem_iscc

if not exist bin mkdir bin

echo === Compilando src\animal.lpi
"%LAZBUILD%" src\animal.lpi
if errorlevel 1 goto erro_compilacao
if not exist bin\animal.exe goto sem_exe

echo === Gerando o instalador com o Inno Setup
"%ISCC%" /Q instalador\animais.iss
if errorlevel 1 goto erro_instalador

echo.
echo Pronto. Instalador gravado na pasta bin.
endlocal
exit /b 0

:sem_lazbuild
echo ERRO: lazbuild nao encontrado. Coloque a pasta do Lazarus no PATH.
exit /b 1

:sem_iscc
echo ERRO: ISCC.exe nao encontrado. Instale o Inno Setup 6 ou coloque-o no PATH.
exit /b 1

:erro_compilacao
echo ERRO: a compilacao falhou.
exit /b 1

:sem_exe
echo ERRO: bin\animal.exe nao foi gerado.
exit /b 1

:erro_instalador
echo ERRO: a geracao do instalador falhou.
exit /b 1
