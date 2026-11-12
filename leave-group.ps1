# Leave a Stoat group chat using the API.
# Run with:  powershell -ExecutionPolicy Bypass -File .\leave-group.ps1

$ApiBase = "https://api.stoat.chat"   # change this if your instance uses a different API URL

# --- Ask for the details ---
$secureToken = Read-Host "X-Session-Token (input hidden)" -AsSecureString
$token = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))
$channelId = (Read-Host "Group chat ID").Trim()
$silent = (Read-Host "Leave silently, without notifying the group? (y/N)").Trim().ToLower() -eq "y"

if (-not $token -or -not $channelId) {
    Write-Host "Token and group chat ID are both required." -ForegroundColor Red
    exit 1
}

$headers = @{ "x-session-token" = $token }

try {
    # Safety check: make sure this really is a group chat, because DELETE on a
    # server channel would delete the channel instead of leaving it.
    $channel = Invoke-RestMethod -Method Get -Uri "$ApiBase/channels/$channelId" -Headers $headers
    if ($channel.channel_type -ne "Group") {
        Write-Host "That ID is a '$($channel.channel_type)' channel, not a group chat. Nothing was changed." -ForegroundColor Red
        exit 1
    }

    $confirm = Read-Host "Leave group '$($channel.name)'? You can only rejoin if invited. (y/N)"
    if ($confirm.Trim().ToLower() -ne "y") {
        Write-Host "Cancelled. Nothing was changed." -ForegroundColor Yellow
        exit 0
    }

    $uri = "$ApiBase/channels/$channelId"
    if ($silent) { $uri += "?leave_silently=true" }
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers | Out-Null

    Write-Host "Success! You left '$($channel.name)'." -ForegroundColor Green
}
catch {
    $status = $null
    if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
    Write-Host "Failed: $($_.Exception.Message) (HTTP status: $status)" -ForegroundColor Red
    if ($status -eq 401) { Write-Host "The session token looks invalid or expired." -ForegroundColor Red }
    if ($status -eq 404) { Write-Host "Group chat not found. Check the ID." -ForegroundColor Red }
    exit 1
}
