Login-AzureRmAccount

$sub = get-AzureRmSubscription -SubscriptionId e12d538c-ed56-4d10-9bb5-e600ee212144 -TenantId 21f195bc-13e5-4339-82ea-ef8b8ecdd0a9  | Select-AzureRmSubscription

$StartTime = [dateTime]::Now.Subtract([TimeSpan]::FromMinutes(120))

$TimeStampField = "Timestamp"

# Find-AzureRMResource | select ResourceType           <---- This will list all resource types

$redis = Find-AzureRmResource -ResourceType Microsoft.Cache/Redis -ResourceNameContains "adientprod"

$cache = Get-AzureRmRedisCache -name $redis.Name -ResourceGroupName $redis.ResourceGroupName

$metrics = $metrics + (Get-AzureRmMetric -ResourceId subscriptions/e12d538c-ed56-4d10-9bb5-e600ee212144/resourceGroups/int-prod/providers/Microsoft.Cache/Redis/adientprod  -TimeGrain ([TimeSpan]::FromMinutes(60)) -StartTime $StartTime)

$logType = "redis"

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
                                			ResourceGroup = $cache.ResourceGroupName;
                                			RedisName = $cache.Name;
                                            URL = $cache.HostName
                                            State = $cache.ProvisioningState;
                                            OutboundIPAddresses = $cache.OutboundIpAddresses;                                			
		                        		AzureSubscription = $sub.subscription.subscriptionName;
		                        		ResourceLink = "https://portal.azure.com/#resource/subscriptions/$($sub.Subscription.SubscriptionId)/resourceGroups/$($site.ResourceGroup)/providers/Microsoft.Web/sites/$($site.Name)"
                            				}
                            				$table = $table += $sx
                        			}
                        	# Convert table to a JSON document for ingestion 
		    				$jsonTable = ConvertTo-Json -InputObject $table
                    			}

                   # Send-OMSAPIIngestionFile -customerId $OMSworkspace -sharedKey $OMSkey -body $jsonTable -logType $logType -TimeStampField $TimeStampField


            