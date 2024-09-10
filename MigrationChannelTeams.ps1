# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "Group.ReadWrite.All", "ChannelSettings.ReadWrite.All", "ChannelMessage.Read.All", "TeamMember.ReadWrite.All", "TeamSettings.ReadWrite.All"

# Specify the source and destination Teams and Channels
$AskSourceTeamId = Read-Host "Enter the Source Team ID"
$sourceTeamId = $AskSourceTeamId
$AskSourceChannelId = Read-Host "Enter the Source Channel ID"
$sourceChannelId = $AskSourceChannelId
$AskDestTeamId = Read-Host "Enter the Destination Team ID"
$destTeamId = $AskDestTeamId
$AskDestChannelId = Read-Host "Enter the Destination Channel ID"
$destChannelId = $AskDestChannelId

# Fetch messages from the source channel and adjust their dates based on their latest reply
$sourceMessages = Get-MgTeamChannelMessage -TeamId $sourceTeamId -ChannelId $sourceChannelId 

foreach ($message in $sourceMessages) {
    $replies = Get-MgTeamChannelMessageReply -TeamId $sourceTeamId -ChannelId $sourceChannelId -ChatMessageId $message.Id
    if ($replies) {
        $latestReplyDate = ($replies | Sort-Object -Property CreatedDateTime -Descending | Select-Object -First 1).CreatedDateTime
        if ($latestReplyDate -gt $message.CreatedDateTime) {
            $message.CreatedDateTime = $latestReplyDate
        }
    }
}

# Sort messages by their adjusted dates
$sortedMessages = $sourceMessages | Sort-Object -Property CreatedDateTime 

# Migrate sorted messages and their replies to the destination channel
foreach ($message in $sortedMessages) {
    # Migrate the main message
    $updatedMessageContent = "Originally posted by: $($message.From.User.DisplayName) on $($message.CreatedDateTime)`n" + $message.Body.Content
    # Append (Migrated) to the subject
    $newSubject = "$($message.Subject) (Migrated)"
    $newMessage = New-MgTeamChannelMessage -TeamId $destTeamId -ChannelId $destChannelId -Subject $newSubject -Body @{ content = $updatedMessageContent; contentType = "html" } 

    # Migrate the replies for the message
    $replies = Get-MgTeamChannelMessageReply -TeamId $sourceTeamId -ChannelId $sourceChannelId -ChatMessageId $message.Id | Sort-Object -Property CreatedDateTime
    foreach ($reply in $replies) {
        $updatedReplyContent = "Originally replied by: $($reply.From.User.DisplayName) on $($reply.CreatedDateTime)`n" + $reply.Body.Content
        New-MgTeamChannelMessageReply -TeamId $destTeamId -ChannelId $destChannelId -ChatMessageId $newMessage.Id -Body @{ content = $updatedReplyContent; contentType = "html" }
    }
}

if ($?) {
    Write-Host "Messages and Replies Successfully Migrated" -ForegroundColor Green
} else {
    Write-Host "You had some error in migration" -ErrorAction Stop -ForegroundColor Red
}

Write-Host "Migration completed!"
Disconnect-MgGraph
