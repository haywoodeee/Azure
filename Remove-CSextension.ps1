Login-AzureRmAccount

$ResourceGroupName = "MyQ-PP-WEB-RG"
$customscriptname = "octopusinstall"

$nodes = Get-AzureRmVM -ResourceGroupName $ResourceGroupName

$nodes | % {Remove-AzurermVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -VMName $_.name –Name $customscriptname -Force}


