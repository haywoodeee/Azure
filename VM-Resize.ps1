Login-AzureRmAccount

$rgname = "MyQ-PP-TSKSVC-RG"
$NewVMSize = "Standard_F4s"

$vms = Get-AzureRmVM -ResourceGroupName $rgname

foreach ($vm in $vms) {

$vm.HardwareProfile.vmSize = $NewVMSize
Update-AzureRmVM -ResourceGroupName $rgname -VM $vm

}