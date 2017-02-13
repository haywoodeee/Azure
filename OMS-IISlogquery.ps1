Login-AzureRmAccount

#Selects the appropriate subscription based on name, between quotes.
$sub = get-AzureRmSubscription -SubscriptionName " "  | Select-AzureRmSubscription

#Path to folder containing *.log files
$path = " " 

#Static-set timestamp name
$TimeStampField = "Timestamp"

#This is the query in which you'd search in OMS. Name must have _CL for custom logging.
$logType = "_CL"

#OMS workspace ID between quotes
$OMSworkspace = " "

#OMS workspace primary key between quotes
$OMSkey = " "

#---------------------------------------------------------------------------------------------------

#Primary working portion. This will differ by the type of data that is coming in to your IIS server, as most data is space-delimited. 

#Gets all *.log files in path
$child = Get-ChildItem $path -Recurse -Include "*.log"

#Nested foreach loop that gets each file then...
foreach ($file in $child) {

#Reads the content and assigns to $data, then...
$data = Get-Content $file


foreach ($line in $data) {

#Foreach line in that file, create an empty table
$table = @()

#If the line starts with a #, do nothing.. otherwise
if($line.StartsWith("#"))
        { 
            
        }
        else
        {
                #Split each space-delimited item into its own line. THIS WILL VARY DEPENDING ON YOUR TYPE OF LOG AND DATA ASSOCIATED
                #Example: "192.168.1.100 Localhost" is space-delimited, so 192.168.1.100 and Localhost will become their own lines.
                $split = $line.Split(" ")

                #Create a new PSobject and assign to $sx. The below fields can be changed and is how they will appear in OMS.
                $sx = New-Object PSObject -Property @{
                                Timestamp = $split[0] + " " + $split[1];
                                ServerIp = $split[2];
                                HttpMethod = $split[3];
                                UriStem = $split[4];
                                UriQuery = $split[5];
                                Port = $split[6];
                                ClientIp = $split[8];
                                UserAgent = $split[9];
                                HttpStatus = $split[11];
                                TimeTaken = $split[14];
                        }
                        #Take the data from $sx and assign to the empty table
                        $table = $table += $sx
        }
        #Convert the table to JSON format for OMS
        $jsontable = ConvertTo-Json -InputObject $table

        #Send data to OMS. This may take a while at first, but once all fields are loaded it will be quick.
        Send-OMSAPIIngestionFile -customerId $OMSworkspace -sharedKey $OMSkey -body $jsonTable -logType $logType -TimeStampField $TimeStampField
}

}