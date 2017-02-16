Login-AzureRmAccount

$sub = get-AzureRmSubscription -SubscriptionId  -TenantId | Select-AzureRmSubscription

$StartTime = [dateTime]::Now.Subtract([TimeSpan]::FromMinutes(120))

$TimeStampField = "Timestamp"

# Find-AzureRMResource | select ResourceType           <---- This will list all resource types

$redis = Find-AzureRmResource -ResourceType Microsoft.Cache/Redis -ResourceNameContains " "

$cache = Get-AzureRmRedisCache -name $redis.Name -ResourceGroupName $redis.ResourceGroupName

$metrics = $metrics + (Get-AzureRmMetric -ResourceId   -TimeGrain ([TimeSpan]::FromMinutes(60)) -StartTime $StartTime)

$logType = "redis"

$OMSworkspace = " "

$OMSkey = " "



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

                    Send-OMSAPIIngestionFile -customerId $OMSworkspace -sharedKey $OMSkey -body $jsonTable -logType $logType -TimeStampField $TimeStampField


            