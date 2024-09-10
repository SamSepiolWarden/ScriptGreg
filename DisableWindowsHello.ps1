$Disable = Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name "AllowDomainPINLogon" -Value 0
$Disable1 = Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions -Name "value" -Value 0

if ($Disable -eq 0 -and $Disable1 -eq 0) {
    Write-Output "Windows Hello has been disabled successfully"
} else {
    Write-Output "Failed to disable Windows Hello"}