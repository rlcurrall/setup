. ./helpers.ps1

function Setup-Registry
{
    # Declutter the taskbar
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "TaskbarAl"                     "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "TaskbarDa"                     "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "TaskbarMn"                     "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "TaskbarSd"                     "1"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "ShowCopilotButton"             "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "ShowTaskViewButton"            "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "Start_AccountNotifications"    "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "Start_IrisRecommendations"     "0"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  "Start_Layout"                  "1"
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"             "SearchboxTaskbarMode"          "0"

    # Set Personal User Shell Folder to Documents folder
    Set-Registry-Value "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "Personal" "$HOME\Documents"
}

