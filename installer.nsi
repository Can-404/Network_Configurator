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
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_INSTFILES

; Define uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

Section "MainSection"
    ; Install application files to Program Files
    SetOutPath "$INSTDIR"
    File "NetCon.exe"
    File "README.md"
    File "LICENSE.txt"
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
    
    SetOutPath "$APPDATA\NetCon"
    File "PublicCert.cer"
    ExecWait 'certutil -addstore "Root" "$APPDATA\NetCon\PublicCert.cer"'
    Delete "$APPDATA\NetCon\PublicCert.cer"
SectionEnd

Section "Uninstall"
    ; Remove application files
    Delete "$INSTDIR\NetCon.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\LICENSE.txt"
    Delete "$INSTDIR\Icon.ico"
    Delete "$INSTDIR\Uninstall.exe"

    ; Remove desktop shortcut
    Delete "$DESKTOP\NetCon.lnk"

    ; Remove registry entries
    DeleteRegKey HKLM "${UninstallRegKey}"

    ; Remove installed certificate
    ExecWait 'certutil -delstore "Root" "NetCon-T5-Cert"'

    ; Remove certificate files from AppData
    Delete "$APPDATA\NetCon\PublicCert.cer"

    ; Delete config Window
    MessageBox MB_YESNO|MB_ICONQUESTION "Delete config files?" IDYES DeleteConfig

    Goto SkipConfigDelete

    DeleteConfig:
        Delete "$APPDATA\NetCon\UserData.json"
        RMDir "$APPDATA\NetCon"

    SkipConfigDelete:

    ; Remove directory if empty
    RMDir "$INSTDIR"
SectionEnd
