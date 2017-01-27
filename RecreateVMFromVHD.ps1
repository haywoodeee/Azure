
$osDiskUri = "https://myqppstor1.blob.core.windows.net/vhds/MyQ-PP-DC120161017132258.vhd"
$RGname = Read-Host -Prompt "Enter the resource group name"
$vmName = Read-Host -Prompt "Enter the VM name"
$vmNIC = Read-Host -Prompt "Enter the VM NIC name"
$vmSize = Read-Host -Prompt "Enter the VM size"

$location = "North Central US"


$nic = Get-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $vmName -VhdUri $osDiskUri -CreateOption Attach -Windows
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = New-AzureRmVM -VM $vmConfig -Location $location -ResourceGroupName $RGname

