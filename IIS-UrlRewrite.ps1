cd E:\
sleep -seconds 1
Invoke-WebRequest -Uri https://myqfilestorage.blob.core.windows.net/applications/rewrite_amd64.msi -OutFile E:\rewrite.msi 
sleep -Seconds 3
msiexec  /i rewrite.msi /quiet