Login-AzureRmAccount

$loc = Get-AzureRmLocation | select DisplayName,Location | sort DisplayName  | OGV -passthru  #first set a location
$RGname = Get-AzureRmResourceGroup | ? Location -Contains $loc.Location | select Location,ResourceGroupName | sort ResourceGroupName | OGV -PassThru | select ResourceGroupName
$Node = Get-AzureRmVM | ? ResourceGroupName -Contains $RGname.ResourceGroupName | select Location,ResourceGroupName,Name | OGV -PassThru | select Name
$Pip = Get-AzureRmPublicIpAddress -ResourceGroupName $RGname.ResourceGroupName | ? Name -Like ($node.Name + "*") | select Name,IpAddress,PublicIpAllocationMethod | OGV -PassThru
$TestObj = New-Object PSObject -Property @{

VMName = $Node.Name
PublicIP = $pip.IpAddress
IPAllocation = $pip.PublicIpAllocationMethod

}
$TestObj

Read-Host "Press any key to exit..."
exit