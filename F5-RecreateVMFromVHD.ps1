
$osDiskUri = "https://myqppms1.blob.core.windows.net/vhds/MyQ-PP-MS120161021102233.vhd"
$RGname = Read-Host -Prompt "Enter the resource group name"
$vmName = Read-Host -Prompt "Enter the VM name"
$vmNIC = Read-Host -Prompt "Enter the VM NIC name"
$vmSize = Read-Host -Prompt "Enter the VM size"

$location = "North Central US"


$pip = Get-AzureRmPublicIpAddress -Name $vmName -ResourceGroupName $RGname
$nic = Get-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId "/subscriptions/b5b15d81-e24a-43c7-84a6-1bb272624805/resourceGroups/MyQ-PP-MS-RG/providers/Microsoft.Compute/availabilitySets/MESSAGESIGHT-AVAILSET"

Set-AzureRmVMPlan -VM $vmConfig -Publisher f5-networks -Product f5-big-ip -Name f5-bigip-virtual-edition-good-byol
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $vmName -VhdUri $osDiskUri -CreateOption Attach -Linux
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
 
$vm = New-AzureRmVM -VM $vmConfig -Location $location -ResourceGroupName $RGname 

