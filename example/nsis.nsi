!define APP_NAME "清语"
!define APP_VERSION "1.0"
!define APP_EXE "qingyu.exe"

OutFile "${APP_NAME}-${APP_VERSION}.exe"
InstallDir "$PROGRAMFILES\${APP_NAME}"

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    File "${APP_EXE}"
    File /r "data\*.*"  ; 包括其他资源
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\${APP_EXE}"
    RMDir "$INSTDIR"
SectionEnd
