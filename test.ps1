$Location = 'NorthCentralUS'
$ResourceGroupName = 'RP-ASR-RG'
$Sitename = "Rightpoint Chicago Primary Site"
$SubscriptionName = "Rightpoint - Development" 
$VaultName = 'RP-ASR-Demo'
$StorageName = 'rpasrdemostorage'
	
$username = "bprescott@rightpoint.com"
$password = ConvertTo-SecureString "Xerxes1010!!" -AsPlainText -Force

$psCred = New-Object System.Management.Automation.PSCredential($username, $Password)
Login-AzureRmAccount -Credential $psCred

Select-AzureRmSubscription -SubscriptionName $SubscriptionName 
Get-AzureSiteRecoveryVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location
#Creates a new recovery services vault
$vault = get-AzureRmRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location

#Sets vault settings configuration based off $vault.
Set-AzureRmSiteRecoveryVaultSettings -ARSVault $Vault

#Assigns Recovery Site Site Identifier to variable.
$SiteIdentifier = Get-AzureRmSiteRecoverySite -Name $sitename | select -ExpandProperty $SiteIdentifier

#Gets the Hyper-V recovery server
$server =  Get-AzureRmSiteRecoveryServer | select friendlyname

#Sets the hyper-v protection container to a variable
$protectionContainer = Get-AzureRmSiteRecoveryProtectionContainer 

#Sets recovery policy to variable
$PolicyName = “RPOPolicy1”
$Policy = Get-AzureRmSiteRecoveryPolicy -FriendlyName $PolicyName 

#VM friendly name for the on-premises VM you want to protect
$VMFriendlyName = "RPC-DEV-ASR" 

$RecoveryPlan = Get-AzureRmSiteRecoveryRecoveryPlan

Start-AzureRmSiteRecoveryTestFailoverJob -RecoveryPlan $RecoveryPlan -Direction PrimaryToRecovery