[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](#)

# 🔑 Flipper Zero BadUSB Payload - WiFi Password Grabber

> [!NOTE]  
> This is a BadUSB payload for the Flipper Zero device

> [!IMPORTANT]  
> For penetration testing and security research only

## 📝 Description

A BadUSB payload written in DuckyScript that extracts stored WiFi credentials from Windows machines. When executed, this payload launches PowerShell with elevated privileges to retrieve all saved wireless network profiles and their passwords, sending the data through Discord webhook.

## ⚡ Features

- 🔄 Quick execution
- 🔑 Extracts all stored WiFi passwords
- 📤 Exfiltrates data via Discord
- 💨 Auto-closes after completion

## 🛠️ Requirements

- Target: Windows
- Flipper Zero with BadUSB
- Discord webhook URL
- Internet connection on target

## 📲 Installation

1. Download the `WiFiGrabber.txt`
2. Replace `YOUR_DISCORD_WEBHOOK` with your webhook URL
3. Copy to Flipper Zero's BadUSB folder
4. Execute on target system

## 🎯 Execution Flow

1. Launches PowerShell
2. Extracts WiFi credentials
3. Formats data into readable output
4. Sends to Discord webhook
5. Cleans up and exits

## ⚠️ Disclaimer

This payload is for **authorized penetration testing and educational purposes only**. Unauthorized use on systems you don't own is illegal. The author assumes no liability for misuse.

---
*Created for security research and educational purposes* 
