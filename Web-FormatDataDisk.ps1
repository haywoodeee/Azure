#Changes DVD drive letter to Q:
$drive = Get-WmiObject -Class win32_volume -Filter “DriveLetter = 'e:'”
sleep -Seconds 2
Set-WmiInstance -input $drive -Arguments @{DriveLetter=”Q:”}
sleep -Seconds 3
#Initializes the new SSD drive and sets drive letter as E (E: needed for Octopus script)
Initialize-Disk -Number 2 -PartitionStyle MBR
sleep -Seconds 5
New-Partition -DiskNumber 2 -DriveLetter E -Size 127GB
sleep -Seconds 5
#Formats the SSD drive
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel DATA -Confirm:$false