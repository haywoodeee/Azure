Login-AzureRmAccount

# Get the VNET to which to connect the NIC
$VNET = Get-AzureRmVirtualNetwork -Name ‘Pre-Production’ -ResourceGroupName ‘MyQ-PP-RG’
# Get the Subnet ID to which to connect the NIC
$SubnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name ‘MyQ-PreProd’ -VirtualNetwork $VNET).Id
# NIC Name
$vmNIC = Read-Host -Prompt "Enter the VM NIC name"
#NIC Resource Group
$RGname = Read-Host -Prompt "Enter the resource group name"



#Network Security Group for that Resource Group
$NSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $RGname
$NSG = $NSG.Id
#NIC creation location
$Location = ‘North Central US’
#Enter the IP address
$IPAddress = Read-Host -Prompt "Enter a private IP address"
#–> Create now the NIC Interface
New-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname -Location $Location -SubnetId $SubnetID -PrivateIpAddress $IPAddress -NetworkSecurityGroupId $NSG



$osDiskUri = "https://myqppdmpr4.blob.core.windows.net/vhds/MyQ-PP-DMPR420170109150444.vhd"
$datadiskuri = 
$vmSize = "Standard_F4s"
$vmName = Read-Host -Prompt "Enter the VM name"



$nic = Get-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $vmName -VhdUri $osDiskUri -CreateOption Attach -Windows
$vmconfig = Add-AzureRmVMDataDisk -VM $vmConfig -Name $vmName -VhdUri "https://myqppdmpr4.blob.core.windows.net/vhds/MyQ-PP-DMPR4-DATA.vhd" -CreateOption Attach
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = New-AzureRmVM -VM $vmConfig -Location $location -ResourceGroupName $RGname

















