#Imports Azure module
Import-Module Azure

#Log into your specific Azure account
Login-AzureRmAccount

#Registers Site Recovery namespaces on local machine
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.SiteRecovery
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.RecoveryServices

#Checks if the path 'c:\ASR' exists. If not, creates the directory.
$Path = 'c:\ASR'
if(!(Test-Path -Path $Path)){
Write-Host "Directory does not exist. Creating directory." 
New-Item -ItemType directory -Path $Path}
else {write-host "Directory already exists!"}

Start-Transcript -Path $Path\ASRDeployTranscript.txt

#Assigned variables for later use within the script. Location is Azure canned.\\
$Location = 'NorthCentralUS'
$ResourceGroupName = 'RP-ASR-RG'
$Sitename = "Rightpoint Chicago Primary Site"
$SubscriptionName = "Rightpoint - Development" 
$VaultName = 'RP-ASR-Demo'
$StorageName = 'rpasrdemostorage'


#Assigns specific subscription using SubscriptionName variable.
Select-AzureRmSubscription -SubscriptionName $SubscriptionName

#Creates new ARM resource group.
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 

#Create new ASR Storage account
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageName -Location $Location -Type Standard_GRS 

#Creates a new recovery services vault
$vault = new-AzureRmRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location

#Sets vault settings configuration based off $vault.
Set-AzureRmSiteRecoveryVaultSettings -ARSVault $Vault

#Creates recovery site. In this example, created Hyper-V recovery site.
New-AzureRmSiteRecoverySite -Name $sitename 

#Assigns Recovery Site Site Identifier to variable.
$SiteIdentifier = Get-AzureRmSiteRecoverySite -Name $sitename | select -ExpandProperty SiteIdentifier

#Sleep just to provide some delay to last command.
sleep -Seconds 10

#Downloads the ARM Recovery Vault settings file for use with the installer at a later date.
Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault -SiteIdentifier $SiteIdentifier -SiteFriendlyName $sitename -Path $Path 

#Prompts to start Hyper-V agent download.
Read-Host -Prompt "Please press enter to download Hyper-V agent to ASR folder" 

#URL for agent download.
$source = "http://download.microsoft.com/download/9/0/1/901B1962-D422-46DF-AB03-D2C5B4B32FC2/AzureSiteRecoveryProvider.exe"

#Creates request for download file.
Invoke-WebRequest $source -OutFile $Path\'ASRAgent.exe' 

#Starts the install process of the agent.
Start-Process $Path\'ASRAgent.exe' -Wait

#Gets the Hyper-V recovery server
$server =  Get-AzureRmSiteRecoveryServer | select friendlyname

#Sets the ASR policy. To be tweaked per deployment.
$ReplicationFrequencyInSeconds = "300";     #options are 30,300,900
$PolicyName = “RPOPolicy1”
$Recoverypoints = 6                 #specify the number of recovery points
$storageaccountID = Get-AzureRmStorageAccount -Name $StorageName -ResourceGroupName $ResourceGroupName | Select -ExpandProperty Id 


#Overall result of policy set and assigned to variable.
$PolicyResult = New-AzureRmSiteRecoveryPolicy -Name $PolicyName -ReplicationProvider “HyperVReplicaAzure” `
-ReplicationFrequencyInSeconds $ReplicationFrequencyInSeconds  -RecoveryPoints $Recoverypoints -ApplicationConsistentSnapshotFrequencyInHours 1 `
-RecoveryAzureStorageAccountId $storageaccountID 

#Sets the hyper-v protection container to a variable
$protectionContainer = Get-AzureRmSiteRecoveryProtectionContainer 

#Sets recovery policy to variable
$Policy = Get-AzureRmSiteRecoveryPolicy -FriendlyName $PolicyName 

#Starts association job
$associationJob  = Start-AzureRmSiteRecoveryPolicyAssociationJob -Policy $Policy -PrimaryProtectionContainer $protectionContainer

#VM friendly name for the on-premises VM you want to protect
$VMFriendlyName = "RPC-DEV-ASR" 

#Assigns VM to protection entity
$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity -ProtectionContainer $protectionContainer -FriendlyName $VMFriendlyName 

#The OS of the protected VM. Windows or Linux
$OS = "Windows"

#Enables protection for the noted VM 

Set-AzureRmSiteRecoveryProtectionEntity -ProtectionEntity $protectionEntity -Policy $Policy -Protection Enable -RecoveryAzureStorageAccountId $storageaccountID  -OS $OS -OSDiskName $protectionEntity.Disks[0].Name

Stop-Transcript