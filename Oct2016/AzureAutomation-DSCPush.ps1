#Login-AzureRmAccount

#function pick-AutomationAccount {
$automation = Get-AzureRmAutomationAccount 
$menu = @{}
for ($i=1;$i -le $automation.count; $i++) 
{ Write-Host "$i. $($automation[$i-1].AutomationAccountName)"
$menu.Add($i,($automation[$i-1].AutomationAccountName)) }

[int]$ans = Read-Host 'Select an Azure Automation account...'
$autoaccount = $menu.Item($ans)

write-host "!!! You have chosen $autoaccount !!!" -foregroundcolor "Yellow" `n

$autorg = Get-AzureRmAutomationAccount | where AutomationAccountName -EQ $autoaccount | %{$_.ResourceGroupName}

$script:autoaccount = $autoaccount
$script:resource = $autorg
#}


#function pick-dscNode {
$dscConfig = Get-AzureRmAutomationDscConfiguration -ResourceGroupName $autorg -AutomationAccountName $autoaccount
$menu = @{}
for ($i=1;$i -le $dscConfig.count; $i++) 
{ Write-Host "$i. $($dscConfig[$i-1].Name)"
$menu.Add($i,($dscConfig[$i-1].Name)) }

[int]$ans = Read-Host 'Select a node to apply DSC to...'
$hostDSC = $menu.Item($ans)

write-host "!!! You have chosen $hostDSC !!!" -foregroundcolor "Yellow" `n


#}
#pick-AutomationAccount
#pick-dscNode