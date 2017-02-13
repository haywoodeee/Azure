cd c:\
mkdir OMS
Invoke-WebRequest -Uri https://myqfilestorage.blob.core.windows.net/applications/InstallDependencyAgent-Windows.exe -OutFile C:\OMS\InstallDependencyAgent-Windows.exe
sleep -seconds 5
$install = "C:\OMS\InstallDependencyAgent-Windows.exe"
Start-Process -FilePath $install -ArgumentList '/S' -Wait -Verb RunAs


