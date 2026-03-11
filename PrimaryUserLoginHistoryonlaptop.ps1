# Set custom date range
$StartDate = Get-Date "2026-02-10"
$EndDate   = Get-Date "2026-02-26 23:59:59"

# Detect primary interactive user (ignores SYSTEM/service accounts)
$Logons = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624; StartTime=$StartDate; EndTime=$EndDate} |
    Where-Object { $_.Properties[5].Value -notmatch "SYSTEM|LOCAL SERVICE|NETWORK SERVICE|ANONYMOUS LOGON" }

$PrimaryUser = $Logons | Group-Object { $_.Properties[5].Value } | Sort-Object Count -Descending | Select-Object -First 1 -ExpandProperty Name
Write-Output "Primary user detected: $PrimaryUser"

# Get login/logout events for the primary user in the date range
$Events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=@(4624,4634,4647); StartTime=$StartDate; EndTime=$EndDate} |
    Where-Object { $_.Properties[5].Value -eq $PrimaryUser } |
    Select-Object TimeCreated, Id, @{Name="User";Expression={$_.Properties[5].Value}}, @{Name="Device";Expression={$_.MachineName}} |
    Sort-Object TimeCreated

# Display results
$Events

# Optional: export to CSV
#$Events | Export-Csv -Path "C:\Temp\LoginLogout_Feb10-26.csv" -NoTypeInformation
