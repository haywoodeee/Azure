Import-Module Azure
Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId 76d210f9-5d7b-4875-b92a-1267ab071303

Get-AzureRmVM | FT -AutoSize

$VM = Read-Host -Prompt "Type the name of the VM you would like to power on."
$RG = read-host -Prompt "Type the name of the VM's Resource Group"

Get-AzureRMVM -Name $VM -ResourceGroupName $RG | Start-AzureRmVM

sleep -Seconds 30

get-azurermvm -Name BP-DC1 -ResourceGroupName BP-RG -Status

<# BELOW SECTION: Used for internal DHCP address gathering, NOT public IP.

$MyVM = Get-AzureRmVM -Name BP-DC1 -ResourceGroupName BP-RG
$MyVMIP = Get-AzureRmNetworkInterface 

foreach ($NIC in $MyVMIP) {
    $vm = $MyVM | Where-Object -Property Id -EQ $NIC.VirtualMachine.Id
    $prv = $NIC.IpConfigurations | Select-Object -ExpandProperty PrivateIpAddress
    $alloc = $NIC.IpConfigurations | Select-Object -ExpandProperty PrivateIpAllocationMethod
    Write-Output "$($vm.Name) : $prv , $alloc"
    }

    #>

$CurrentIP = Get-AzureRmVm -Name $VM -ResourceGroupName $RG | Get-AzureRmPublicIpAddress | select IpAddress | Format-Table -HideTableHeaders

$TheIP = Out-String -InputObject $CurrentIP



