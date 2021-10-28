#define MyAppName "Kitto3 and Kide3 IDE"

#define KittoVersion "3.0"
#define MyAppVersion "3.0.0"
#define MyAppExeName "Kide3.exe"
#define MyCopyRight "Copyright (c) 2012-2021 Ethea S.r.l."
#define MyCompany "Ethea S.r.l."

#define KITTO "..\.."

[Setup]
AppId={{052FA381-75D0-4B82-B6AD-FB9EF1967663}
DefaultDirName={sd}\Dev\Kitto_{#KittoVersion}
OutputBaseFilename=Kitto3Setup

AppName={#MyAppName}
AppVersion={#KittoVersion}
AppVerName={#MyAppName} {#MyAppVersion}
WizardImageFile=WizEtheaImage.bmp
WizardSmallImageFile=WizEtheaSmallImage.bmp
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=true
Compression=lzma
SolidCompression=true
;ShowLanguageDialog=yes
AppCopyright={#MyCopyRight}
AppPublisher={#MyCompany}
SetupIconFile=.\kitto_64.ico
VersionInfoCompany={#MyCompany}
VersionInfoDescription={#MyAppName}
VersionInfoCopyright={#MyCopyRight}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#KittoVersion}
VersionInfoProductTextVersion={#KittoVersion}
VersionInfoVersion={#MyAppVersion}
ChangesAssociations=Yes
DisableWelcomePage=False
ShowLanguageDialog=Auto
DirExistsWarning=yes
DisableDirPage=False
PrivilegesRequired=admin

[Languages]
Name: eng; MessagesFile: compiler:Default.isl; LicenseFile: .\License_ENG.rtf
Name: ita; MessagesFile: compiler:Languages\Italian.isl; LicenseFile: .\License_ITA.rtf


[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
;KIDE SECTION
Source: {#KITTO}\Kide\Bin\Kide3.exe; DestDir: {app}\kitto\Kide\Bin; Flags: ignoreversion; Components: Kide3
Source: {#KITTO}\Kide\Bin\Config.yaml; DestDir: {app}\kitto\Kide\Bin; Flags: ignoreversion; Components: Kide3
Source: {#KITTO}\Kide\Bin\*.png; DestDir: {app}\kitto\Kide\Bin; Flags: ignoreversion; Components: Kide3
Source: {#KITTO}\Kide\Bin\*.wav; DestDir: {app}\kitto\Kide\Bin; Flags: ignoreversion; Components: Kide3
Source: {#KITTO}\Kide\Bin\*.jpg; DestDir: {app}\kitto\Kide\Bin; Flags: ignoreversion; Components: Kide3
Source: {#KITTO}\Kide\Bin\ProjectTemplates\*; DestDir: {app}\kitto\Kide\Bin\ProjectTemplates; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Bin\MetadataTemplates\*; DestDir: {app}\kitto\Kide\Bin\MetadataTemplates; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Docs\*; DestDir: {app}\kitto\Kide\Docs; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Ext\*; DestDir: {app}\kitto\Kide\Ext; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Help\*; DestDir: {app}\kitto\Kide\Help; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Projects\*.ico; DestDir: {app}\kitto\Kide\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Projects\*.dpr; DestDir: {app}\kitto\Kide\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Projects\*.dproj; DestDir: {app}\kitto\Kide\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Projects\*.res; DestDir: {app}\kitto\Kide\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Source\*.pas; DestDir: {app}\kitto\Kide\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Source\*.dfm; DestDir: {app}\kitto\Kide\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Source\*.inc; DestDir: {app}\kitto\Kide\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3
Source: {#KITTO}\Kide\Source\*.rc; DestDir: {app}\kitto\Kide\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kide3

;KITTO SECTION
Source: {#KITTO}\Source\*; DestDir: {app}\kitto\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kitto3
;Source: {#KITTO}\Bin\*.yaml; DestDir: {app}\kitto\Bin; Flags: ignoreversion; Components: Kitto3
Source: {#KITTO}\Docs\External\*.txt; DestDir: {app}\kitto\Docs\External; Flags: ignoreversion; Components: Kitto3
Source: {#KITTO}\Docs\External\*.png; DestDir: {app}\kitto\Docs\External; Flags: ignoreversion; Components: Kitto3Docs
Source: {#KITTO}\Home\*; DestDir: {app}\kitto\Home; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kitto3
Source: .\MyProjectsFolder.txt; DestDir: {app}\kitto\MyProjects; Flags: ignoreversion; Components: Kitto3
;Source: {#KITTO}\Docs\External\Reference\Html\*; DestDir: {app}\kitto\Docs\Reference; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Kitto3Docs

;KITTO EXAMPLES SECTION
Source: {#KITTO}\Examples\HelloKitto\DB\*.sql; DestDir: {app}\kitto\Examples\HelloKitto\DB; Flags: ignoreversion; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\DB\*.fbk; DestDir: {app}\kitto\Examples\HelloKitto\DB; Flags: ignoreversion; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\HelloKitto.exe; DestDir: {app}\kitto\Examples\HelloKitto\Home; Flags: ignoreversion; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\HelloKitto.kproj; DestDir: {app}\kitto\Examples\HelloKitto\Home; Flags: ignoreversion; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\Locale\*; DestDir: {app}\kitto\Examples\HelloKitto\Home\Locale; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\Metadata\*; DestDir: {app}\kitto\Examples\HelloKitto\Home\Metadata; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\Resources\*; DestDir: {app}\kitto\Examples\HelloKitto\Home\Resources; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Home\ReportTemplates\*; DestDir: {app}\kitto\Examples\HelloKitto\Home\ReportTemplates; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\*.ico; DestDir: {app}\kitto\Examples\HelloKitto\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D10_4\*.dpr; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D10_4\*.dproj; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D10_4\*.res; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D11_0\*.dpr; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D11_0\*.dproj; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Projects\D11_0\*.res; DestDir: {app}\kitto\Examples\HelloKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Source\*; DestDir: {app}\kitto\Examples\HelloKitto\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: HelloKittoExamples
Source: {#KITTO}\Examples\HelloKitto\Readme.txt; DestDir: {app}\kitto\Examples\HelloKitto; Flags: ignoreversion; Components: HelloKittoExamples

Source: {#KITTO}\Examples\TasKitto\DB\*.sql; DestDir: {app}\kitto\Examples\TasKitto\DB; Flags: ignoreversion; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\DB\*.fbk; DestDir: {app}\kitto\Examples\TasKitto\DB; Flags: ignoreversion; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Home\TasKitto.exe; DestDir: {app}\kitto\Examples\TasKitto\Home; Flags: ignoreversion; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Home\TasKitto.kproj; DestDir: {app}\kitto\Examples\TasKitto\Home; Flags: ignoreversion; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Home\Metadata\*; DestDir: {app}\kitto\Examples\TasKitto\Home\Metadata; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Home\Resources\*; DestDir: {app}\kitto\Examples\TasKitto\Home\Resources; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Home\ReportTemplates\*; DestDir: {app}\kitto\Examples\TasKitto\Home\ReportTemplates; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\*.ico; DestDir: {app}\kitto\Examples\TasKitto\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D10_4\*.dpr; DestDir: {app}\kitto\Examples\TasKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D10_4\*.dproj; DestDir: {app}\kitto\Examples\TasKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D10_4\*.res; DestDir: {app}\kitto\Examples\TasKitto\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D11_0\*.dpr; DestDir: {app}\kitto\Examples\TasKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D11_0\*.dproj; DestDir: {app}\kitto\Examples\TasKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Projects\D11_0\*.res; DestDir: {app}\kitto\Examples\TasKitto\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Source\*; DestDir: {app}\kitto\Examples\TasKitto\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: TasKittoExamples
Source: {#KITTO}\Examples\TasKitto\Readme.txt; DestDir: {app}\kitto\Examples\TasKitto; Flags: ignoreversion; Components: TasKittoExamples

Source: {#KITTO}\Examples\KEmployee\Home\KEmployee.kproj; DestDir: {app}\kitto\Examples\KEmployee\Home; Flags: ignoreversion; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Home\KEmployee.exe; DestDir: {app}\kitto\Examples\KEmployee\Home; Flags: ignoreversion; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Home\*.txt; DestDir: {app}\kitto\Examples\KEmployee\Home; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Home\Metadata\*; DestDir: {app}\kitto\Examples\KEmployee\Home\Metadata; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Home\Resources\*; DestDir: {app}\kitto\Examples\KEmployee\Home\Resources; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\*.ico; DestDir: {app}\kitto\Examples\KEmployee\Projects; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D10_4\*.dpr; DestDir: {app}\kitto\Examples\KEmployee\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D10_4\*.dproj; DestDir: {app}\kitto\Examples\KEmployee\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D10_4\*.res; DestDir: {app}\kitto\Examples\KEmployee\Projects\D10_4; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D11_0\*.dpr; DestDir: {app}\kitto\Examples\KEmployee\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D11_0\*.dproj; DestDir: {app}\kitto\Examples\KEmployee\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Projects\D11_0\*.res; DestDir: {app}\kitto\Examples\KEmployee\Projects\D11_0; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Source\*; DestDir: {app}\kitto\Examples\KEmployee\Source; Flags: ignoreversion recursesubdirs createallsubdirs; Components: KEmployeeExamples
Source: {#KITTO}\Examples\KEmployee\Readme.txt; DestDir: {app}\kitto\Examples\KEmployee; Flags: ignoreversion; Components: KEmployeeExamples

[Dirs]
Name: "{app}"; Permissions: users-full

[Icons]
Name: {group}\Kitto3; Filename: {app}\kitto\Kide\Bin\{#MyAppExeName}; Components: Kide3
Name: {commondesktop}\Kide3; Filename: {app}\kitto\Kide\Bin\{#MyAppExeName}; Tasks: desktopicon; Components: Kide3
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Kide3; Filename: {app}\kitto\Kide\Bin\{#MyAppExeName}; Tasks: quicklaunchicon; Components: Kide3

Name: {app}\kitto\Examples\HelloKitto\Home\HelloKitto - Install as service; Filename: {app}\kitto\Examples\HelloKitto\Home\HelloKitto.exe; Parameters: -install; Components: HelloKittoExamples
Name: {app}\kitto\Examples\HelloKitto\Home\HelloKitto - Uninstall service; Filename: {app}\kitto\Examples\HelloKitto\Home\HelloKitto.exe; Parameters: -uninstall; Components: HelloKittoExamples
Name: {app}\kitto\Examples\HelloKitto\Home\HelloKitto - Run as application; Filename: {app}\kitto\Examples\HelloKitto\Home\HelloKitto.exe; Parameters: -a; Components: HelloKittoExamples
Name: {app}\kitto\Examples\TasKitto\Home\TasKitto - Install as service; Filename: {app}\kitto\Examples\TasKitto\Home\TasKitto.exe; Parameters: -install; Components: TasKittoExamples
Name: {app}\kitto\Examples\TasKitto\Home\TasKitto - Uninstall service; Filename: {app}\kitto\Examples\TasKitto\Home\TasKitto.exe; Parameters: -uninstall; Components: TasKittoExamples
Name: {app}\kitto\Examples\TasKitto\Home\TasKitto - Run as application; Filename: {app}\kitto\Examples\TasKitto\Home\TasKitto.exe; Parameters: -a; Components: TasKittoExamples
Name: {app}\kitto\Examples\KEmployee\Home\KEmployee - Install as service; Filename: {app}\kitto\Examples\KEmployee\Home\KEmployee.exe; Parameters: -install; Components: KEmployeeExamples
Name: {app}\kitto\Examples\KEmployee\Home\KEmployee - Uninstall service; Filename: {app}\kitto\Examples\KEmployee\Home\KEmployee.exe; Parameters: -uninstall; Components: KEmployeeExamples
Name: {app}\kitto\Examples\KEmployee\Home\KEmployee - Run as application; Filename: {app}\kitto\Examples\KEmployee\Home\KEmployee.exe; Parameters: -a; Components: KEmployeeExamples

[Run]
Filename: {app}\kitto\Kide\Bin\{#MyAppExeName}; Description: {cm:LaunchProgram, Kide}; Flags: nowait postinstall skipifsilent

[Components]
Name: Kitto3; Description: Kitto3 source code; Types: full compact
Name: Kide3; Description: Kide3 - Kitto3 IDE; Types: custom compact full
Name: HelloKittoExamples; Description: HelloKitto example; Types: custom full
Name: TasKittoExamples; Description: TasKitto example; Types: custom full
Name: KEmployeeExamples; Description: KEmployee example; Types: custom full
Name: Kitto3Docs; Description: Kitto3 reference documentation; Types: custom full

[Registry]
;kproj extension opened by KIDE
Root: HKCR; SubKey: .kproj; ValueType: string; ValueData: Open; Flags: uninsdeletekey;
Root: HKCR; SubKey: Open; ValueType: string; ValueData: Kide project file; Flags: uninsdeletekey;
Root: HKCR; SubKey: Open\Shell\Open\Command; ValueType: string; ValueData: """{app}\kitto\Kide\Bin\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletevalue;
Root: HKCR; Subkey: Open\DefaultIcon; ValueType: string; ValueData: {app}\kitto\Kide\Bin\{#MyAppExeName},0; Flags: uninsdeletevalue;

[UninstallDelete]
Name: {app}; Type: filesandordirs
