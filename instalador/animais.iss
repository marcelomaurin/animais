; Instalador do Animais (Inno Setup 6).
; Gere com gerar_instalador.bat, na raiz do projeto, ou abra este arquivo
; no Inno Setup e compile. Requer bin\animal.exe ja compilado.
; O instalador e gravado em bin\.

#define NomeApp "Animais"
#define VersaoApp "1.0.0"
#define EmpresaApp "Maurinsoft"
#define ExeApp "animal.exe"

[Setup]
AppId={{10C1FD8D-BE69-475C-B7BF-1DE30353B05A}
AppName={#NomeApp}
AppVersion={#VersaoApp}
AppPublisher={#EmpresaApp}
DefaultDirName={autopf}\{#NomeApp}
DefaultGroupName={#NomeApp}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
OutputDir=..\bin
OutputBaseFilename=Animais-{#VersaoApp}-instalador
SetupIconFile=..\src\animal.ico
UninstallDisplayIcon={app}\{#ExeApp}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\bin\{#ExeApp}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\docs\GUIA_USUARIO.md"; DestDir: "{app}\docs"; Flags: ignoreversion
Source: "..\docs\REGRAS_JOGO_DA_VIDA_MODIFICADO.md"; DestDir: "{app}\docs"; Flags: ignoreversion

[Icons]
Name: "{group}\{#NomeApp}"; Filename: "{app}\{#ExeApp}"
Name: "{group}\{cm:UninstallProgram,{#NomeApp}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#NomeApp}"; Filename: "{app}\{#ExeApp}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ExeApp}"; Description: "{cm:LaunchProgram,{#NomeApp}}"; Flags: nowait postinstall skipifsilent
