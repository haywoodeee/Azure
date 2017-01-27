

#MAKE SURE TO DISASSOCIATE THE PUBLIC IP FOR THE SPECIFIC VM FIRST!!!!!


Login-AzureRmAccount



$RGname = "MyQ-PP-MS-RG"




# Get the VNET to which to connect the NIC
$VNET = Get-AzureRmVirtualNetwork -Name ‘Pre-Production’ -ResourceGroupName ‘MyQ-PP-RG’
# Get the Subnet ID to which to connect the NIC
$SubnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name ‘MyQ-PreProd’ -VirtualNetwork $VNET).Id
# NIC Name
$vmNIC = Read-Host -Prompt "Enter the new VM NIC name"
#NIC Resource Group


$VMname = Read-Host -Prompt "Enter the existing VM name"

#Network Security Group for that Resource Group
$NSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $RGname 
$NSG = $NSG.Id
#NIC creation location
$Location = ‘North Central US’

$machine = Get-AzureRmNetworkInterface | where Name -Match $VMname
$machine.IpConfigurations.PrivateIPAddress

$machine.IpConfigurations[0].PrivateIpAllocationMethod
#Enter the IP address
$IPAddress = Read-Host -Prompt "Enter a private IP address"

$pip = Get-AzureRmPublicIpAddress | ? Name -Match $VMname
#–> Create now the NIC Interface
New-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname -Location $Location -SubnetId $SubnetID -PrivateIpAddress $IPAddress -NetworkSecurityGroupId $NSG -PublicIpAddressId $pip.Id -DnsServer "172.16.128.15", "172.16.128.16"

sleep -Seconds 3

$VMRG = $RGname
#Get the VM
$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $VMRG
#Add the second NIC

$NewNIC =  Get-AzureRmNetworkInterface -Name $vmNIC -ResourceGroupName $RGname
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NewNIC.Id
# Show the Network interfaces
$VM.NetworkProfile.NetworkInterfaces
#we have to set one of the NICs to Primary, i will set the first NIC in this example
$VM.NetworkProfile.NetworkInterfaces.Item(1).Primary = $true
$old = $vm.NetworkProfile.NetworkInterfaces.id | select -First 1

$VM = Remove-AzureRmVMNetworkInterface -VM $VM -NetworkInterfaceIDs $old
#Update the VM configuration (The VM will be restarted)
Update-AzureRmVM -VM $VM -ResourceGroupName $RGname










