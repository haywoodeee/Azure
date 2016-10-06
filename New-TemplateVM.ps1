Import-Module Azure
Login-AzureRmAccount

Get-AzureRmSubscription

#**** VM Template Creation ****#

$Subscription = read-host -Prompt "Type the subscription ID that you would like to use"

Select-AzureRmSubscription -SubscriptionId $Subscription

Get-AzureRmVm | FT -AutoSize

$VM = read-host -Prompt "Type the name of the VM you want to template"
$RG = Read-Host -Prompt "Type the name of the VM's ResourceGroupName"

Stop-AzureRmVM -ResourceGroupName $RG -Name $VM

Set-AzureRmVM -ResourceGroupName $RG -Name $VM -Generalized

$state = Get-AzureRmVM -ResourceGroupName $RG -Name $VM -Status
$state.statuses

Save-AzureRmVMImage -ResourceGroupName $RG -Name $VM -DestinationContainerName rpo-templates -VHDNamePrefix Win2012R2 -Path "C:\Users\bprescott\Documents\Azure Scripts\ARM Templates" -Overwrite

$imageURI = 

#**** vNet Creation ****#


