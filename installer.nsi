!include "MUI2.nsh"

Name "Network Configurator"
OutFile "Network Configurator 1.0.0 Installer.exe"
InstallDir "$PROGRAMFILES\NetCon"
RequestExecutionLevel admin
Icon "Icon.ico"

!define AppName "NetCon"
!define AppVersion "1.0.0"
!define Publisher "T5"
!define UninstallRegKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${AppName}"

; Define installer pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM

Section "MainSection"
    ; Install application files to Program Files
    SetOutPath "$INSTDIR"
    File "NetCon.exe"
    File "Icon.ico"
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Create a desktop shortcut
    CreateShortCut "$DESKTOP\NetCon.lnk" "$INSTDIR\NetCon.exe" "" "$INSTDIR\Icon.ico" 0

    ; Add registry entries for "Apps & features"
    WriteRegStr HKLM "${UninstallRegKey}" "DisplayName" "${AppName}"
    WriteRegStr HKLM "${UninstallRegKey}" "DisplayVersion" "${AppVersion}"
    WriteRegStr HKLM "${UninstallRegKey}" "Publisher" "${Publisher}"
    WriteRegStr HKLM "${UninstallRegKey}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${UninstallRegKey}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "${UninstallRegKey}" "DisplayIcon" "$INSTDIR\icon.ico"
SectionEnd

Section "Install Certificate"
    ; Install certificate to AppData folder
    SetOutPath "$APPDATA\NetCon"
    File "C:\Users\Admin\Desktop\Certificates\PublicCert.pfx"

    ; Install Certificate to Trusted Root Certification Authorities
    ExecWait 'powershell.exe -ExecutionPolicy Bypass -File "InstallCert.bat"'
SectionEnd

Section "Uninstall"
    ; Remove application files
    Delete "$INSTDIR\NetCon.exe"
    Delete "$INSTDIR\Icon.ico"
    Delete "$INSTDIR\Uninstall.exe"

    ; Remove desktop shortcut
    Delete "$DESKTOP\NetCon.lnk"

    ; Remove registry entries
    DeleteRegKey HKLM "${UninstallRegKey}"

    ; Remove certificate files from AppData
    Delete "$APPDATA\NetCon\PublicCert.pfx"

    ; Remove directory if empty
    RMDir "$INSTDIR"
SectionEnd
