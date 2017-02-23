# Replace with your Workspace ID

$User = "guest"
$File = "C:\OMS\MQqueue.txt"
$Credential=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)


$CustomerId = "20c35212-62bb-4331-9c79-298d750c2c8f"  

# Replace with your Primary Key
$SharedKey = "VDCVRSyErB4XrwsBr5jmuVLrIL+HbKTH/gcy3vqE+f7fztWosjRLe5HQPlaL/RxHZHfhil8EAOvhwQN9M8Q+lw=="

# Specify the name of the record type that you'll be creating
$LogType = "RabbitQueue"

# Specify a field with the created time for the records
$TimeStampField = "DateValue"

$json1 = Invoke-RestMethod -Method Get -Uri http://localhost:15672/api/queues -Credential $Credential 
# Create two records with the same set of properties to create


# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-OMSData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -fileName $fileName `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-RestMethod -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body 
    return $json

}



#Defined JSON sections
$node = $json1.node | select -First 1 
$memory = $json1.memory | select -First 1
$reduction = $json1.reductions | select -First 1
$messages = $json1.messages | select -First 1
$messagesready = $json1.messages_ready | select -First 1
$messagesunack = $json1.messages_unacknowledged | select -First 1
$idle = $json1.idle_since | select -First 1
$policy = $json1.policy | select -First 1
$state = $json1.state | select -First 1
$durable = $json1.durable | select -First 1
$name = $json1.name | select -First 1

<#
incoming
consumers
consumer utilization
ready
#>

$json = @{Computer=$node;Memory=$memory;Reductions=$reduction;Messages=$messages;MessagesReady=$messagesready;MessageUnacknowledged=$messagesunack;IdleSince=$idle;Policy=$policy;State=$state;Durable=$durable;Name=$name}

$json = $json | ConvertTo-Json

# Submit the data to the API endpoint
Post-OMSData -customerId $customerId -sharedKey $sharedKey -body $json -logType $logType 