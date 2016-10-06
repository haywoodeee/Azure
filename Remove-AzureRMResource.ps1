Import-Module Azure
Login-AzureRmAccount

$Search = Read-Host -Prompt "Enter a string to search for" 

$Resources = Get-AzureRmResource | where {$_.name -like '*' + $search + '*'} | Format-table -wrap -AutoSize -Property ResourceID | Out-String

Remove-AzureRmResource -ResourceID $Resources -Confirm