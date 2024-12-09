param (

[Parameter(Mandatory = $true)]

[string]$senderEmailAddress,

[Parameter(Mandatory = $true)]

[string]$recipientEmailAddresses,

[Parameter(Mandatory = $true)]

[string]$subject,

[Parameter(Mandatory = $true)]

[string]$body

)

$smtpServer = "smtp-lob.office365.com"

$smtpPort = "587"

# Prompt user for sender credentials

$credentials = Get-Credential -UserName $senderEmailAddress -Message "Enter sender credentials"

# Test HVE account

Send-MailMessage -From $senderEmailAddress -To $recipientEmailAddresses -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credentials