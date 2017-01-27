Login-AzureRmAccount

$RG = "MyQ-PP-MQ-RG"

$VMS = Get-AzureRmVM -ResourceGroupName $RG

foreach ($VM in $VMS) {

$VM = $VM | select name
$VM = $VM.Name + "-NIC"
$ip = Get-AzureRmNetworkInterface -Name $VM -ResourceGroupName $RG -ErrorAction Ignore

New-Object -TypeName PSObject -Property @{
IPaddress = $ip.IpConfigurations.PrivateIpAddress 
VM = $VM }

}