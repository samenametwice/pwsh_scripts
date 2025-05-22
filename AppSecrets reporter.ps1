#Required Variables
$currentDate = Get-Date
$expirationDate = $currentDate.AddDays(30)
$teamsID = ""
$channelID = ""

#Get all applications
$Applications = Get-MgApplication | Where-Object { $_.PasswordCredentials.Count -gt 0 }
$ServiceApplications = Get-MgServicePrincipal -All
# Filter applications with KeyCredentials (non-empty)
$appsWithCertificates = $ServiceApplications | Where-Object { $_.KeyCredentials.Count -gt 0 }

#Application Registration Loop
#------------------------------#
foreach ($app in $Applications) {
    #Check if App had applications
    if ($app.PasswordCredentials) {
        foreach ($password in $app.PasswordCredentials) {
        #Check if secret has expired or will expire in next 30 days

            #Check if Secret has already expired
            if ($password.EndDateTime -lt $currentDate) {
                #Secret has expired
                $message = "The app '$($app.DisplayName)' secret '$($password.DisplayName)' has expired. Please renew and delete."

                #Send message in some form
                Write-Host $message

                #Teams Message Params
                $Teamsparams = @{
                body = @{
		                contentType = "html"
		                content = "<div>
                                   <at id='0'>Desktop Supp</at>
                                   </div>
                                   <div><u><strong style='font-size: 20px;'>App Registration Expired</strong></u></div>
                                   <br>
                                   <div>The secret <b>'$($password.DisplayName)'</b> for app registration <b>'$($app.DisplayName)'</b> has expired on $($password.EndDateTime.tostring('dd/MM/yyyy')).</div>
                                   <div><u><b>App Registration Name</u></b>: $($app.DisplayName)</div>
                                   <div><u><b>App Registration ID</u></b>: $($app.appId)</div>
                                   <div><b><a href=
                                   'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$($app.AppId)/isMSAApp~/false?Microsoft_AAD_IAM_legacyAADRedirect=true'>Link to App Registration</b></a></div>

                   
                                   <br>Please renew or delete this and alert the owner of the application.
                                   </div>"
	                }
	                mentions = @(
		                @{
			                id = 0
			                mentionText = "Team Name"
			                mentioned = @{
				                conversation = @{
					                id = ""
					                displayName = "Team Supp"
					                conversationIdentityType = "channel"
				                }
			                }
		                }
	                )
	                reactions = @(
	                )
	                messageHistory = @(
	                )
                }

                New-MgTeamChannelMessage -TeamId $teamsID -ChannelId $channelID -BodyParameter $Teamsparams
               }
            elseif ($password.EndDateTime -lt $expirationDate) {
                #Secret expires in 30 days
                $message = "The secret for '$($app.DisplayName)' will expire in 30 days on '$($password.EndDateTime.tostring('dd/MM/yyyy'))'"
                Write-Host $message
                $Teamsparams = @{
                body = @{
		                contentType = "html"
		                content = "<div>
                                   <at id='0'>Desktop Supp</at>
                                   </div>
                                   <div><u><strong style='font-size: 20px;'>App Registration Secret Expiring</strong></u></div>
                                   <br>
                                   <div>The secret <b>'$($password.DisplayName)'</b> for app registration <b>'$($app.DisplayName)'</b> will expire on $($password.EndDateTime.tostring('dd/MM/yyyy')).</div>
                                   <div><u><b>App Registration Name</u></b>: $($app.DisplayName)</div>
                                   <div><u><b>App Registration ID</u></b>: $($app.appId)</div>
                                   <div><b><a href=
                                   'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$($app.AppId)/isMSAApp~/false?Microsoft_AAD_IAM_legacyAADRedirect=true'>Link to App Registration</b></a></div>

                   
                                   <br>Please renew this and alert the owner of the application.
                                   </div>"
	                }
	                mentions = @(
		                @{
			                id = 0
			                mentionText = "Team Name"
			                mentioned = @{
				                conversation = @{
					                id = ""
					                displayName = "Team"
					                conversationIdentityType = "channel"
				                }
			                }
		                }
	                )
	                reactions = @(
	                )
	                messageHistory = @(
	                )
                }

                New-MgTeamChannelMessage -TeamId $teamsID -ChannelId $channelID -BodyParameter $Teamsparams
              }
            }
    } else {
        Write-Host "No secret credentials found for '$($app.DisplayName)'"
  }
}


#Service Principle loop
foreach ($Sapp in $appsWithCertificates) {
    #Check if App had applications
    if ($Sapp.KeyCredentials) {
        foreach ($Spassword in $Sapp.KeyCredentials) {
        #Check if secret has expired or will expire in next 30 days
            #Only get the 'Sign' cerificate
            if ($Spassword.Usage -eq 'Sign') {
                #Check to see if the App has already expired
                if ($Spassword.EndDateTime -lt $currentDate){
                    #Secret has expired message
                    $message = "The certificate has expired for '$($Sapp.DisplayName)'. Please renew this"

                    #Send message in some form
                    Write-Host $message
                    #Params required for sending Teams message
                    $Teamsparams = @{
                    body = @{
		                    contentType = "html"
		                    content = "<div>
                                       <at id='0'>Desktop Supp</at>
                                       </div>
                                       <div><u><strong style='font-size: 20px;'>App Certificate Expired</strong></u></div>
                                       <br>
                                       <div>The certificate the application <b>'$($Sapp.DisplayName)'</b> has expired on $($Spassword.EndDateTime.tostring('dd/MM/yyyy')).</div>
                                       <div><u><b>Application Name</u></b>: $($Sapp.DisplayName)</div>
                                       <div><u><b>Application ID</u></b>: $($Sapp.appId)</div>
                                       <div><b><a href=
                                       'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/22fbe0eb-8cbd-42fa-b181-79c44d762cbf/appId/$($Sapp.AppId)/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/?Microsoft_AAD_IAM_legacyAADRedirect=true'>Link to App Registration</b></a></div>

                   
                                       <br>Please renew this and alert the owner of the application.
                                       </div>"
	                    }
	                    mentions = @(
		                    @{
			                    id = 0
			                    mentionText = "Team"
			                    mentioned = @{
				                    conversation = @{
					                    id = "Team"
					                    displayName = "Team"
					                    conversationIdentityType = "channel"
				                    }
			                    }
		                    }
	                    )
	                    reactions = @(
	                    )
	                    messageHistory = @(
	                    )
                    }
                    #Sends the Message to the Teams channel
                    New-MgTeamChannelMessage -TeamId $teamsID -ChannelId $channelID -BodyParameter $Teamsparams
                }
                elseif ($Spassword.EndDateTime -lt $expirationDate) {
                #Secret expires in the next 30 days
                $message = "The certificate for '$($Sapp.DisplayName)' will expire in 30 days on '$($Spassword.EndDateTime.tostring('dd/MM/yyyy'))'"
                #Secret has expired message
                Write-Host $message
                #Params required for sending Teams message
                $Teamsparams = @{
                body = @{
		                contentType = "html"
		                content = "<div>
                                    <at id='0'>Desktop Supp</at>
                                    </div>
                                    <div><u><strong style='font-size: 20px;'>App Certificate Expiring</strong></u></div>
                                    <br>
                                    <div>The certificate for the application <b>'$($Sapp.DisplayName)'</b> will expire on $($Spassword.EndDateTime.tostring('dd/MM/yyyy')).</div>
                                    <div><u><b>Application Name</u></b>: $($Sapp.DisplayName)</div>
                                    <div><u><b>Application ID</u></b>: $($Sapp.appId)</div>
                                    <div><b><a href=
                                    'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($Sapp.Id)/appId/$($Sapp.AppId)/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/?Microsoft_AAD_IAM_legacyAADRedirect=true'>Link to App Registration</b></a></div>

                   
                                    <br>Please renew this and alert the owner of the application.
                                    </div>"
	                }
	                mentions = @(
		                @{
			                id = 0
			                mentionText = "Team"
			                mentioned = @{
				                conversation = @{
					                id = "Team"
					                displayName = "Team"
					                conversationIdentityType = "channel"
				                }
			                }
		                }
	                )
	                reactions = @(
	                )
	                messageHistory = @(
	                )
                }
                #Sends the Message to the Teams channel
                New-MgTeamChannelMessage -TeamId $teamsID -ChannelId $channelID -BodyParameter $Teamsparams
              }
            }
        }
    } else {
        Write-Host "No secret credentials found for '$($Sapp.DisplayName)'"
    }
}



