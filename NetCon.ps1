<#
 ============================================================================
  Copyright [2025] [T-Can404] | [T-Can404@protonmail.com]
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at:
 
      http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the LICENSE.txt for the specific language governing permissions and
  limitations under the License.
 ============================================================================
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the JSON file path in %APPDATA%\NetCon\UserData.json
$folderPath = [System.IO.Path]::Combine($env:APPDATA, "NetCon")
$jsonPath = [System.IO.Path]::Combine($folderPath, "UserData.json")

# Ensure the directory exists
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

# Create the JSON file
if (-not (Test-Path $jsonPath)) {
    $defaultConfig = [ordered]@{
        "1" = [ordered]@{
            "IP"      = "0.0.0.0"
            "Gateway" = "0.0.0.0"
            "Subnet"  = "0.0.0.0"
            "DNS"     = "0.0.0.0"
        }
        "2" = [ordered]@{
            "IP"      = "0.0.0.0"
            "Gateway" = "0.0.0.0"
            "Subnet"  = "0.0.0.0"
            "DNS"     = "0.0.0.0"
        }
        "3" = [ordered]@{
            "IP"      = "0.0.0.0"
            "Gateway" = "0.0.0.0"
            "Subnet"  = "0.0.0.0"
            "DNS"     = "0.0.0.0"
        }
        "4" = [ordered]@{
            "IP"      = "0.0.0.0"
            "Gateway" = "0.0.0.0"
            "Subnet"  = "0.0.0.0"
            "DNS"     = "0.0.0.0"
        }
    }

    $defaultConfig | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 -FilePath $jsonPath
}

# Read JSON
$existingData = @{}
if (Test-Path $jsonPath) {
    try {
        $existingData = Get-Content $jsonPath | ConvertFrom-Json
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error loading configuration from JSON file.", "Error", "OK", "Error")
        exit
    }
}

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Network Configurator"
$form.Size = New-Object System.Drawing.Size(400, 500)
$form.StartPosition = "CenterScreen"

$iconPath = "$PWD\Icon.ico"
if (Test-Path $iconPath) {
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# Labels and TextBoxes
$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "IP:"
$labelIP.Location = New-Object System.Drawing.Point(30, 20)
$form.Controls.Add($labelIP)

$textBoxIP = New-Object System.Windows.Forms.TextBox
$textBoxIP.Location = New-Object System.Drawing.Point(150, 20)
$textBoxIP.Width = 180
$form.Controls.Add($textBoxIP)

$labelGateway = New-Object System.Windows.Forms.Label
$labelGateway.Text = "Gateway:"
$labelGateway.Location = New-Object System.Drawing.Point(30, 60)
$form.Controls.Add($labelGateway)

$textBoxGateway = New-Object System.Windows.Forms.TextBox
$textBoxGateway.Location = New-Object System.Drawing.Point(150, 60)
$textBoxGateway.Width = 180
$form.Controls.Add($textBoxGateway)

$labelSubnet = New-Object System.Windows.Forms.Label
$labelSubnet.Text = "Subnet mask:"
$labelSubnet.Location = New-Object System.Drawing.Point(30, 100)
$form.Controls.Add($labelSubnet)

# Create the TextBox control for Subnet Mask with placeholder
$textBoxSubnet = New-Object System.Windows.Forms.TextBox
$textBoxSubnet.Location = New-Object System.Drawing.Point(150, 100)
$textBoxSubnet.Width = 180
$form.Controls.Add($textBoxSubnet)

$placeholderSubnet = "255.255.255.0"
$textBoxSubnet.Text = $placeholderSubnet
$textBoxSubnet.ForeColor = [System.Drawing.Color]::Gray

# Event handler for when the Subnet Mask TextBox gets focus
$textBoxSubnet.Add_Enter({
    if ($textBoxSubnet.Text -eq $placeholderSubnet) {
        $textBoxSubnet.Text = ""
        $textBoxSubnet.ForeColor = [System.Drawing.Color]::Black  
    }
})

# Event handler for when the Subnet Mask TextBox loses focus
$textBoxSubnet.Add_Leave({
    if ([string]::IsNullOrEmpty($textBoxSubnet.Text)) {
        $textBoxSubnet.Text = $placeholderSubnet
        $textBoxSubnet.ForeColor = [System.Drawing.Color]::Gray
    }
})

$labelDNS = New-Object System.Windows.Forms.Label
$labelDNS.Text = "DNS:"
$labelDNS.Location = New-Object System.Drawing.Point(30, 140)
$form.Controls.Add($labelDNS)

# Create the TextBox control for DNS with placeholder
$textBoxDNS = New-Object System.Windows.Forms.TextBox
$textBoxDNS.Location = New-Object System.Drawing.Point(150, 140)
$textBoxDNS.Width = 180
$form.Controls.Add($textBoxDNS)

$placeholderDNS = "8.8.8.8"
$textBoxDNS.Text = $placeholderDNS
$textBoxDNS.ForeColor = [System.Drawing.Color]::Gray

# Event handler for when the DNS TextBox gets focus
$textBoxDNS.Add_Enter({
    if ($textBoxDNS.Text -eq $placeholderDNS) {
        $textBoxDNS.Text = ""
        $textBoxDNS.ForeColor = [System.Drawing.Color]::Black
    }
})

# Event handler for when the DNS TextBox loses focus
$textBoxDNS.Add_Leave({
    if ([string]::IsNullOrEmpty($textBoxDNS.Text)) {
        $textBoxDNS.Text = $placeholderDNS
        $textBoxDNS.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Save Buttons for each Numbered Slot
$saveButtonIP1 = New-Object System.Windows.Forms.Button
$saveButtonIP1.Text = "1"
$saveButtonIP1.Location = New-Object System.Drawing.Point(150, 180)
$saveButtonIP1.Width = 40
$saveButtonIP1.Height = 20
$form.Controls.Add($saveButtonIP1)

$saveButtonIP2 = New-Object System.Windows.Forms.Button
$saveButtonIP2.Text = "2"
$saveButtonIP2.Location = New-Object System.Drawing.Point(200, 180)
$saveButtonIP2.Width = 40
$saveButtonIP2.Height = 20
$form.Controls.Add($saveButtonIP2)

$saveButtonIP3 = New-Object System.Windows.Forms.Button
$saveButtonIP3.Text = "3"
$saveButtonIP3.Location = New-Object System.Drawing.Point(250, 180)
$saveButtonIP3.Width = 40
$saveButtonIP3.Height = 20
$form.Controls.Add($saveButtonIP3)

$saveButtonIP4 = New-Object System.Windows.Forms.Button
$saveButtonIP4.Text = "4"
$saveButtonIP4.Location = New-Object System.Drawing.Point(300, 180)
$saveButtonIP4.Width = 40
$saveButtonIP4.Height = 20
$form.Controls.Add($saveButtonIP4)

# Buttons to Change IP
$buttonIP1 = New-Object System.Windows.Forms.Button
$buttonIP1.Text = "Change to IP - 1"
$buttonIP1.Location = New-Object System.Drawing.Point(30, 240)
$buttonIP1.Width = 120
$form.Controls.Add($buttonIP1)

$buttonIP2 = New-Object System.Windows.Forms.Button
$buttonIP2.Text = "Change to IP - 2"
$buttonIP2.Location = New-Object System.Drawing.Point(210, 240)
$buttonIP2.Width = 120
$form.Controls.Add($buttonIP2)

$buttonIP3 = New-Object System.Windows.Forms.Button
$buttonIP3.Text = "Change to IP - 3"
$buttonIP3.Location = New-Object System.Drawing.Point(30, 300)
$buttonIP3.Width = 120
$form.Controls.Add($buttonIP3)

$buttonIP4 = New-Object System.Windows.Forms.Button
$buttonIP4.Text = "Change to IP - 4"
$buttonIP4.Location = New-Object System.Drawing.Point(210, 300)
$buttonIP4.Width = 120
$form.Controls.Add($buttonIP4)

# Change IP Lable
$labelIP1 = New-Object System.Windows.Forms.Label
$labelIP1.Text = "192.168.10.72"
$labelIP1.Location = New-Object System.Drawing.Point(30, 220)
$form.Controls.Add($labelIP1)

$labelIP2 = New-Object System.Windows.Forms.Label
$labelIP2.Text = "192.168.10.72"
$labelIP2.Location = New-Object System.Drawing.Point(210, 220)
$form.Controls.Add($labelIP2)

$labelIP3 = New-Object System.Windows.Forms.Label
$labelIP3.Text = "192.168.10.72"
$labelIP3.Location = New-Object System.Drawing.Point(30, 280)
$form.Controls.Add($labelIP3)

$labelIP4 = New-Object System.Windows.Forms.Label
$labelIP4.Text = "192.168.10.72"
$labelIP4.Location = New-Object System.Drawing.Point(210, 280)
$form.Controls.Add($labelIP4)

# Reset Button
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)
$resetButton.Text = "🔄"
$resetButton.Location = New-Object System.Drawing.Point(350, 20)
$resetButton.Width = 22
$resetButton.height = 22
$form.Controls.Add($resetButton)

# ToolTip
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.AutoPopDelay = 5000
$tooltip.InitialDelay = 1000
$tooltip.ReshowDelay = 500

# Add a tooltip to Reset Button
$tooltip.SetToolTip($resetButton, "Reset Stored Config")

function Update-IPLabels {
    if ($existingData."1".IP -ne "0.0.0.0") {
        $labelIP1.Text = "IP: " + $existingData."1".IP
    } else {
        $labelIP1.Text = "IP: Not Set"
    }
    if ($existingData."2".IP -ne "0.0.0.0") {
        $labelIP2.Text = "IP: " + $existingData."2".IP
    } else {
        $labelIP2.Text = "IP: Not Set"
    }
    if ($existingData."3".IP -ne "0.0.0.0") {
        $labelIP3.Text = "IP: " + $existingData."3".IP
    } else {
        $labelIP3.Text = "IP: Not Set"
    }
    if ($existingData."4".IP -ne "0.0.0.0") {
        $labelIP4.Text = "IP: " + $existingData."4".IP
    } else {
        $labelIP4.Text = "IP: Not Set"
    }
}

function Approve-Input {
    param (
        [string]$ip,
        [string]$subnet,
        [string]$gateway,
        [string]$dns
    )

    $ipRegex = "^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}$"
    
    $subnetRegex = "^(128|192|224|240|248|252|254|255)\.0\.0\.0$|^255\.(0|128|192|224|240|248|252|254)\.0\.0$|^255\.255\.(0|128|192|224|240|248|252|254)\.0$|^255\.255\.255\.(0|128|192|224|240|248|252|254|255)$"

    if ($ip -notmatch $ipRegex) {
        [System.Windows.Forms.MessageBox]::Show("Invalid IP address format!", "Validation Error", "OK", "Error")
        return $false
    }
    if ($gateway -notmatch $ipRegex) {
        [System.Windows.Forms.MessageBox]::Show("Invalid Gateway format!", "Validation Error", "OK", "Error")
        return $false
    }
    if ($dns -notmatch $ipRegex) {
        [System.Windows.Forms.MessageBox]::Show("Invalid DNS format!", "Validation Error", "OK", "Error")
        return $false
    }
    if ($subnet -notmatch $subnetRegex) {
        [System.Windows.Forms.MessageBox]::Show("Invalid Subnet Mask format!", "Validation Error", "OK", "Error")
        return $false
    }

    return $true
}
Update-IPLabels

# DHCP Button
$buttonDHCP = New-Object System.Windows.Forms.Button
$buttonDHCP.Text = "DHCP"
$buttonDHCP.Location = New-Object System.Drawing.Point(30, 350)
$buttonDHCP.Width = 120
$form.Controls.Add($buttonDHCP)

# Confirm Button
$ConfirmButtonIP = New-Object System.Windows.Forms.Button
$ConfirmButtonIP.Text = "Confirm"
$ConfirmButtonIP.Location = New-Object System.Drawing.Point(210, 350)
$ConfirmButtonIP.Width = 120
$form.Controls.Add($ConfirmButtonIP)

$defaultAdapter = "Ethernet"

$ConfirmButtonIP.Add_Click({
    $ip = $textBoxIP.Text
    $gateway = $textBoxGateway.Text
    $subnet = $textBoxSubnet.Text
    $dns = $textBoxDNS.Text

    if (-not (Approve-Input -ip $ip -subnet $subnet -gateway $gateway -dns $dns)) {
        return 
    }

    Start-Process -FilePath "netsh" -ArgumentList "interface ip set address name=`"$defaultAdapter`" static $ip $subnet $gateway" -Verb RunAs
    Start-Process -FilePath "netsh" -ArgumentList "interface ip set dns name=`"$defaultAdapter`" static $dns" -Verb RunAs

    [System.Windows.Forms.MessageBox]::Show("Network settings updated!", "Success", "OK", "Information")
})

$buttonDHCP.Add_Click({
    Start-Process -FilePath "netsh" -ArgumentList "interface ip set address name=`"$defaultAdapter`" source=dhcp" -Verb RunAs
    Start-Process -FilePath "netsh" -ArgumentList "interface ip set dns name=`"$defaultAdapter`" source=dhcp" -Verb RunAs

    [System.Windows.Forms.MessageBox]::Show("DHCP enabled!", "Success", "OK", "Information")
})

$resetButton.Add_Click({
    $confirmation = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to reset and delete the configuration?", "Confirm Reset", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

    if ($confirmation -eq [System.Windows.Forms.DialogResult]::Yes) {
        try {
            # Delete the JSON file
            Remove-Item -Path $jsonPath -Force
            [System.Windows.Forms.MessageBox]::Show("Configuration was Reset Programm will now Restart.", "Success", "OK", "Information")

            Restart-Executable
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error deleting configuration file.", "Error", "OK", "Error")
        }
    }
})

function Save-IPConfig($buttonNum) {
    $ip = $textBoxIP.Text.Trim()
    $subnet = $textBoxSubnet.Text.Trim()
    $gateway = $textBoxGateway.Text.Trim()
    $dns = $textBoxDNS.Text.Trim()

    # Input Data
    $newConfig = @{
        IP = $ip
        Subnet = $subnet
        Gateway = $gateway
        DNS = $dns
    }

    if (-not (Approve-Input -ip $ip -subnet $subnet -gateway $gateway -dns $dns)) {
        return
    }

    # Update existing data with new configuration
    $existingData.$buttonNum = $newConfig

    # Write to JSON file
    try {
        $existingData | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 -FilePath $jsonPath
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to save configuration.", "Error", "OK", "Error")
    }

    Update-IPLabels
}

function set-IPConfig($buttonNum) {
    $config = $existingData.$buttonNum

    # Ensure valid config exists
    if ($config -and $config.IP -ne "0.0.0.0") {
        $ip = $config.IP
        $subnet = $config.Subnet
        $gateway = $config.Gateway
        $dns = $config.DNS

        $adapterName = "Ethernet"

        try {
            Start-Process -FilePath "netsh" -ArgumentList "interface ip set address name=`"$adapterName`" static $ip $subnet $gateway"
            Start-Process -FilePath "netsh" -ArgumentList "interface ip set dns name=`"$adapterName`" static $dns"
            
            [System.Windows.Forms.MessageBox]::Show("Network settings updated!", "Success", "OK", "Information")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error applying network settings.", "Error", "OK", "Error")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No valid configuration found for this slot.", "Error", "OK", "Error")
    }
}

function Restart-Executable {
    $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

    $form.Close()

    Start-Sleep -Milliseconds 200

    Start-Process $exePath
}

$saveButtonIP1.Add_Click({ Save-IPConfig "1" })
$saveButtonIP2.Add_Click({ Save-IPConfig "2" })
$saveButtonIP3.Add_Click({ Save-IPConfig "3" })
$saveButtonIP4.Add_Click({ Save-IPConfig "4" })

$buttonIP1.Add_Click({ set-IPConfig "1" })
$buttonIP2.Add_Click({ set-IPConfig "2" })
$buttonIP3.Add_Click({ set-IPConfig "3" })
$buttonIP4.Add_Click({ set-IPConfig "4" })

$form.ShowDialog() | Out-Null