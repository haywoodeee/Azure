
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

##This section queries current Azure locations and prompts for selection.
$location = Get-AzureRmLocation | sort location 
$menu = @{}
for ($i=1;$i -le $location.count; $i++) 
{ Write-Host "$i. $($location[$i-1].location)"
$menu.Add($i,($location[$i-1].location)) }

[int]$ans = Read-Host 'Enter selection'
$rgloc = $menu.Item($ans)

write-host "!!! You have chosen $rgloc !!!" -foregroundcolor "Yellow" `n

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

#This section queries current VM sizes based on location and prompts for selection.
$size = Get-AzureRmVMSize -Location $rgloc
$menu = @{}
for ($i=1;$i -le $size.count; $i++) 
{ Write-Host "$i. $($size[$i-1].name)"
$menu.Add($i,($size[$i-1].name)) }
[int]$ans = Read-Host 'Enter selection'
$vmsize = $menu.Item($ans)
write-host "!!! You have chosen $vmsize !!!" -foregroundcolor "Yellow" `n

   
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



