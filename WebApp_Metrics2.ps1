Login-AzureRmAccount

$sub = get-AzureRmSubscription -SubscriptionId 76d210f9-5d7b-4875-b92a-1267ab071303 -TenantId 5fbbce2a-c3e6-4b5e-a51f-222674fdb44d  | Select-AzureRmSubscription

$StartTime = [dateTime]::Now.Subtract([TimeSpan]::FromMinutes(5))

$TimeStampField = "Timestamp"

# Find-AzureRMResource | select ResourceType           <---- This will list all resource types

$webapps = Find-AzureRmResource -ResourceType Microsoft.Web/sites -ResourceNameContains "rp-wowwall"

$site = Get-AzureRmWebApp -name $webapps.Name -ResourceGroupName $webapps.ResourceGroupName

$metrics = $metrics + (Get-AzureRmMetric -ResourceId $site.Id -TimeGrain ([TimeSpan]::FromMinutes(60)) -StartTime $StartTime)

$logType = "webapp"

$OMSworkspace = "e1d6d0c0-f069-4c80-ac18-dc7b5813e697"

$OMSkey = "cO/8ZDsUmwePeVpgb1EPrOjRIucogQudwSvqF9kqbs3a/4xid/oOmYxMwyi7zKLAUVyDRxmCL1b54URgVvjkxg=="




$table = @()
                    			foreach($metric in $Metrics)
                    			{ 
                				foreach($metricValue in $metric.MetricValues)
	                        		{
        	                			$sx = New-Object PSObject -Property @{
                	                		Timestamp = $metricValue.Timestamp.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                        	        		MetricName = $metric.Name; 
                                			Average = $metricValue.Average;
                                			SubscriptionID = $sub.Subscription.SubscriptionId;
                                			ResourceGroup = $site.ResourceGroup;
                                			SiteName = $site.Name;
                                            URL = $site.DefaultHostName
                                            State = $site.State;
                                            OutboundIPAddresses = $site.OutboundIpAddresses;                                			
		                        		AzureSubscription = $sub.subscription.subscriptionName;
		                        		ResourceLink = "https://portal.azure.com/#resource/subscriptions/$($sub.Subscription.SubscriptionId)/resourceGroups/$($site.ResourceGroup)/providers/Microsoft.Web/sites/$($site.Name)"
                            				}
                            				$table = $table += $sx
                        			}
                        	# Convert table to a JSON document for ingestion 
		    				$jsonTable = ConvertTo-Json -InputObject $table
                    			}

                    Send-OMSAPIIngestionFile -customerId $OMSworkspace -sharedKey $OMSkey -body $jsonTable -logType $logType -TimeStampField $TimeStampField
