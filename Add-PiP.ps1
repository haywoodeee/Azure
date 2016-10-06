<#

This script adds a public IP to a machine failed over using ASR. This is best utilized as an added "Step" in an ASR recovery plan.

!!! Make sure to rename the $_.Name -like "*RPC-DEV-RDS*" to whatever host you want to add the PiP to. Keep the * surrounds !!!

#>

$cred = Get-AutomationPSCredential -Name 'Admin'
login-azurermaccount -credential $cred

Select-AzureRmSubscription -SubscriptionId 76d210f9-5d7b-4875-b92a-1267ab071303

$VMName = get-azurermvm | ? {$_.Name -like "*RPC-DEV-RDS*"} 

$NetID = $VMName.NetworkInterfaceIDs[0]
$PreTrim = $NetID.TrimStart("/subscriptions/76d210f9-5d7b-4875-b92a-1267ab071303/resourceGroups/ASR-Demo-test/providers/Microsoft.Network/Interfaces/")
$NetName = $PreTrim.Insert(0,"R")

$NIC = Get-AzureRmNetworkInterface -ResourceGroupName "ASR-DEMO-TEST" -Name $NetName
$PiP = Get-AzureRmPublicIpAddress -Name RPC-DEV-ASR-PIP -ResourceGroupName FailoverTest
$NIC.IpConfigurations[0].PublicIpAddress = $PiP
Set-AzureRmNetworkInterface -NetworkInterface $NIC