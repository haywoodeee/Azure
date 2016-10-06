
<######################################################################################################
                                                                                                       
Version: 1.0
Author: Ben Prescott
Date: 10/4/2016

This script will log in to the Azure RM portal and start a full deployment process which includes:

1. Resource Group
2. Storage Account
3. Virtual Network
4. Virtual Machine(s)

The script will allow you to create multiple VMs to the same virtual network/storage/resource groups
as long as you continue to select "yes" during re-prompt. To exit, select "No"

######################################################################################################>

#Logs in to Azure RM tenant
Login-AzureRmAccount
#Creates variables for choice prompt found in functions.
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)


#Function that deploys a resource group.
Function deploy-RG {
#Error checking for the RG name prompt.
do {
        $error.clear()
        [ValidatePattern('^[a-zA-Z0-9]+$')]$rgname = Read-Host -Prompt "Enter a RESOURCE GROUP Name"
       
   } 
    until ($error.Count -eq 0)
#$Script defines the $rgname variable for use outside of this function.
$script:RGname = $rgname

#List of available Azure locations
Write-host "1. East Asia"
Write-host "2. Southeast Asia"
Write-host "3. Central US"
Write-host "4. East US"
Write-host "5. East US 2"
Write-host "6. West US"
Write-host "7. North Central US"
Write-host "8. South Central US"
Write-host "9. North Europe"
Write-host "10. West Europe"
Write-host "11. Japan West"
Write-host "12. Japan East"
Write-host "13. Brazil South"
Write-host "14. Canada Central"
Write-host "15. Canada East"
Write-host "16. UK South"
Write-host "17. UK West"
Write-host "18. West Central US"
Write-host "19. West US 2"
$rgloc = read-host "Please select a location..."

#Switches the $rgloc variable to match a number pressed with an actual Azure recognized location name.
switch ($rgloc)
 {
     '1' {
         $rgloc = 'eastasia'
     } '2' {
         $rgloc = 'southeastasia'
     } '3' {
         $rgloc = 'centralus'
     } '4' {
         $rgloc = 'eastus'
     } '5' {
         $rgloc = 'eastus2'
     }'6' {
         $rgloc = 'westus'
     }'7' {
         $rgloc = 'northcentralus'
     }'8' {
         $rgloc = 'southcentralus'
     }'9' {
         $rgloc = 'northeurope'
     }'10' {
         $rgloc = 'westeurope'
     }'11' {
         $rgloc = 'japanwest'
     }'12' {
         $rgloc = 'japaneast'
     }'13' {
         $rgloc = 'brazilsouth'
     }'14' {
         $rgloc = 'canadacentral'
     }'15' {
         $rgloc = 'canadaeast'
     }'16' {
         $rgloc = 'uksouth'
     }'17' {
         $rgloc = 'ukwest'
     }'18' {
         $rgloc = 'westcentralus'
     }'19' {
         $rgloc = 'westus2'
     }
   
 }
 #Assigns #script for use in later functions
 $script:rgloc = $rgloc
 
#Creates a new Azure RM Resource Group based on name and location.
New-AzureRmResourceGroup -Name $rgname -Location $rgloc


}

#Function that deploys a storage account.
Function deploy-SA {
<###################################################################################### 

Provides the option to create and deploy a Storage Account into the same resource group.

#>#####################################################################################

$title = "Storage Account" 
$message = "Do you want to deploy a storage account?"
$result1 = $host.ui.PromptForChoice($title, $message, $options, 1)

switch ($storagequestion) {
    0{
        Write-Host "Yes"
    }1{
        Write-Host "No"
    }
}
if ($result1 -eq 0)
    {
    #Error checking for the SA name prompt.
    do {
        $error.clear()
        [ValidatePattern('^[a-zA-Z0-9]+$')]$storagename = Read-Host -Prompt "Enter a STORAGE ACCOUNT Name"
       
   } 
    until ($error.Count -eq 0)
    
    #Creates the new Storage Account
    New-AzureRmStorageAccount -ResourceGroupName $rgname -AccountName $storagename -Location $rgloc -Type Standard_GRS 
    #Gets the new storage account and creates a new container named "vhds"
    Get-AzureRmStorageAccount -ResourceGroupName $rgname -Name $storagename | New-AzureStorageContainer -Name "vhds" 
    #Gets the storage account and assigns to variable
    $storageaccount = get-AzureRmStorageAccount -ResourceGroupName $rgname -Name $storagename 
    
    #Assigns for user in other functions
    $script:storageaccount = $storageaccount
    }

   else {
   
   }
   }
  
 
#Function that deploys a virtual network.
Function deploy-VNET {

<###################################################################################### 

Provides the option to create and deploy a Virtual Network into the same resource group.

#>#####################################################################################


$title = "vNet Deployment" 
$message = "Do you want to deploy a Virtual Network?"
$result2 = $host.ui.PromptForChoice($title, $message, $options, 1)
switch ($vnetquestion) {
    0{
        Write-Host "Yes"
    }1{
        Write-Host "No"
    }
}
if ($result2 -eq 0)
    {
    #Error checking for the vNet name prompt.
   do {
        $error.clear()
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]$vNetname = Read-Host -Prompt "Enter a VIRTUAL NETWORK Name"
       
   } 
    until ($error.Count -eq 0)

    #Prompts for address prefix per the mentioned format.
    $AddressPrefix = Read-Host -Prompt "Enter the vNet address and cidr in 192.168.1.0/16 format"
    #Prompts for default subnet name, usually Subnet1
    $subnetname = Read-Host -Prompt "Enter a name for the default subnet"
    #Prompts for Subnet address space
    $subnetprefix = Read-Host -Prompt "Enter the address and cidr for the subnet based on $AddressPrefix."
    #Creates the virtual network based on the given variables
    New-AzureRmVirtualNetwork -ResourceGroupName $rgname -Name $vNetname -Location $rgloc -AddressPrefix $AddressPrefix
    #Gets the new virtual network and assigns to #virtnet
    $virtnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgname -Name $vNetname
    #Adds a new config to the virtual network to include the subnet - temporary
    Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $virtnet -AddressPrefix $subnetprefix
    #Permanently sets the subnet configuration to the virtual network
    Set-AzureRmVirtualNetwork -VirtualNetwork $virtnet
    #Assigns the post-subnet virtual network config to #virtnet
    $virtnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgname -Name $vNetname
    
    #Block of #scripts for later user in functions
    $script:vNetname = $vNetname
    $script:AddressPrefix = $AddressPrefix
    $script:subnetname = $subnetname
    $script:subnetprefix = $subnetprefix
    $script:virtnet = $virtnet
    }

   else {
   
   }

   }

#Function that deploys 1 or many Azure VMs (continuous prompt)
Function deploy-VM {
<######################################################################################################## 

Provides the option to create and deploy a Virtual Machine into the same resource/storage/network groups.

#>#######################################################################################################

#Titles for the choice prompt
$title = "Virtual Machine Deployment" 
$message = "Do you want to deploy a Virtual Machine?"
#Run the prompt
$result3 = $host.ui.PromptForChoice($title, $message, $options, 1)
switch ($VMquestion) {
    0{
        Write-Host "Yes"
    }1{
        Write-Host "No"
    }
}
if ($result3 -eq 0)
 {

Write-host "1. A0"
Write-host "2. A1"
Write-host "3. A2"
Write-host "4. A3"
Write-host "5. A4"
Write-host "6. A5"
Write-host "7. A6"
Write-host "8. A7"
Write-host "9. A8"
Write-host "10. A9"
Write-host "11. A10"
Write-host "12. A11"
Write-host "13. D1 V2"
Write-host "14. D2 V2"
Write-host "15. D3 V2"
Write-host "16. D4 V2"
Write-host "17. D5 V2"
Write-host "18. D11 V2"
Write-host "19. D12 V2"
Write-host "20. D13 V2"
Write-host "21. D14 V2"
Write-host "22. D15 V2"
Write-host "23. F1"
Write-host "24. F2"
Write-host "25. F4"
Write-host "26. F8"
Write-host "27. F16"
Write-host "28. DS1 V2"
Write-host "29. DS2 V2"
Write-host "30. DS3 V2"
Write-host "31. DS4 V2"
Write-host "32. DS5 V2"
Write-host "33. DS11 V2"
Write-host "34. DS12 V2"
Write-host "35. DS13 V2"
Write-host "36. DS14 V2"
Write-host "37. DS15 V2"

$vmsize = read-host "Please select a VM size..."

#Current list of most Azure VM sizes to exclude deprecated editions.
switch ($vmsize)
 {
     '1' {
         $vmsize = 'Standard_A0'
     } '2' {
         $vmsize = 'Standard_A1'
     } '3' {
         $vmsize = 'Standard_A2'
     } '4' {
         $vmsize = 'Standard_A3'
     } '5' {
         $vmsize = 'Standard_A4'
     }'6' {
         $vmsize = 'Standard_A5'
     }'7' {
         $vmsize = 'Standard_A6'
     }'8' {
         $vmsize = 'Standard_A7'
     }'9' {
         $vmsize = 'Standard_A8'
     }'10' {
         $vmsize = 'Standard_A9'
     }'11' {
         $vmsize = 'Standard_A10'
     }'12' {
         $vmsize = 'Standard_A11'
     }'13' {
         $vmsize = 'Standard_D1_v2'
     }'14' {
         $vmsize = 'Standard_D2_v2'
     }'15' {
         $vmsize = 'Standard_D3_v2'
     }'16' {
         $vmsize = 'Standard_D4_v2'
     }'17' {
         $vmsize = 'Standard_D5_v2'
     }'18' {
         $vmsize = 'Standard_D11_v2'
     }'19' {
         $vmsize = 'Standard_D12_v2'
     }'20' {
         $vmsize = 'Standard_D13_v2'
     } '21' {
         $vmsize = 'Standard_D14_v2'
     } '22' {
         $vmsize = 'Standard_D15_v2'
     } '23' {
         $vmsize = 'Standard_F1'
     } '24' {
         $vmsize = 'Standard_F2'
     }'25' {
         $vmsize = 'Standard_F4'
     }'26' {
         $vmsize = 'Standard_F8'
     }'27' {
         $vmsize = 'Standard_F16'
     }'28' {
         $vmsize = 'Standard_DS1_v2'
     }'29' {
         $vmsize = 'Standard_DS2_v2'
     }'30' {
         $vmsize = 'Standard_DS3_v2'
     }'31' {
         $vmsize = 'Standard_DS4_v2'
     }'32' {
         $vmsize = 'Standard_DS5_v2'
     }'33' {
         $vmsize = 'Standard_DS11_v2'
     }'34' {
         $vmsize = 'Standard_DS12_v2'
     }'35' {
         $vmsize = 'Standard_DS13_v2'
     }'36' {
         $vmsize = 'Standard_DS14_v2'
     }'37' {
         $vmsize = 'Standard_DS15_v2'
     }
   
 }
   #Prompts for VM name and assigns to variable.
   $vmName = Read-Host -Prompt "Type a name for the virtual machine"
   #Takes VM name and appends "pip" for the public IP name
   $ipName = $vmname + "pip"
   #Creates the new public IP address based on variables.
   $pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $rgloc -AllocationMethod Static
   #Takes the VM name and appens "nic" for the network interface name
   $nicName = $vmname + "nic"
   #Creates the new network interface based on variables
   $nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $rgloc -SubnetId $virtnet.Subnets[0].Id -PublicIpAddressId $pip.Id
    
   #Prompts for local admin credentials that will be assigned as the primary local admin 
   $localadmin = Get-Credential -Message "Username and password of the new local admin for the VM. DO NOT USE ADMINISTRATOR"
   #Creates the new VM configuration and assigns to variable
   $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmsize
   #Updates variable with operating system information
   $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $localadmin -ProvisionVMAgent -EnableAutoUpdate
   #Updates variable with source image info (server 2012 R2)
   $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
   #Updates variable with the network interface info
   $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

   #Assigns a path to the blob in created "vhds" container with a vhd name of the VMname + OSdisk.vhd
   $blobPath = "vhds/$($vmName)OSdisk.vhd"
   #Assigns blob path to the variable
   $osDiskUri = $storageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath
   #Assigns vhd name (excluding path and .vhd) to the variable
   $diskName = "$($vmName)OSdisk"
   #Updates variable to include the OS disk information
   $vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
   
   #Creates and starts the new Azure RM VM based on given information
   New-AzureRmVM -ResourceGroupName $rgName -Location $rgloc -VM $vm
   
    }

   else {
   
   }
   #If the user selects "Yes" the VM creation function will loop until selected "no", allowing multi-VM creation.
   if ($result3 -eq 0) {

   deploy-vm
   }
   else {
   }

   
   }

#Auto-start of various functions in specified order
deploy-RG
deploy-SA
deploy-VNET
deploy-VM



