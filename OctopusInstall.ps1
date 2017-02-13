cd e:\
Invoke-WebRequest -Uri https://myqfilestorage.blob.core.windows.net/scripts/Octopus.Tentacle.3.5.2-x64.msi -OutFile E:\octopus.msi 
msiexec INSTALLLOCATION=E:\Octopus /i octopus.msi /quiet
sleep -Seconds 5
cd E:\Octopus
sleep -Seconds 5
.\Tentacle.exe create-instance --instance "Tentacle" --config "E:\Octopus\Tentacle.config"
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank
.\Tentacle.exe configure --instance "Tentacle" --reset-trust
.\Tentacle.exe configure --instance "Tentacle" --home "E:\Octopus" --app "E:\Octopus\Applications" --port "10933" --noListen "False"
.\Tentacle.exe configure --instance "Tentacle" --trust "9C8314985E311C124A39E8C7B4B07372AF7F8CDC"
netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
.\Tentacle.exe service --instance "Tentacle" --install --start