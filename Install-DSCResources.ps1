new-item "c:\temp2" -type Directory
$url = "https://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/131371/4/DSC%20Resource%20Kit%20Wave%2010%2004012015.zip"
$outputPath = "C:\temp2\dscresource.zip"

Invoke-WebRequest -Uri $url -OutFile $outputPath

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}

Expand-ZIPFile -file $outputPath -destination "c:\program files\WindowsPowerShell\Modules\"
