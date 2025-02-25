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

# Define the default network adapter name
$defaultAdapter = "Ethernet"

# Create a named mutex so Only one instance of the application can run at a time
$mutexName = "Global\NetConAppMutex"
$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, $mutexName, [ref]$createdNew)

if (-not $createdNew) {
    [System.Windows.Forms.MessageBox]::Show("NetCon is already running!", "Instance Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    exit
}

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

function New-Button {
    param (
        [string]$Text,
        [System.Drawing.Point]$Location,
        [int]$Width = 100,
        [int]$Height = 30,
        [scriptblock]$OnClick = $null,
        [System.Drawing.Font]$Font = $null
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = $Location
    $button.Width = $Width
    $button.Height = $Height

    if ($Font -eq "Segoe") {
        $button.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)
    }

    if ($OnClick) {
        $button.Add_Click($OnClick)
    }

    # Add the Button to the form
    $form.Controls.Add($button)

    return $button
}

function New-Label {
    param (
        [string]$Text,
        [System.Drawing.Point]$Location,
        [int]$Width = 100,
        [int]$Height = 20,
        [System.Drawing.Font]$Font = $null
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Location = $Location
    $label.Width = $Width
    $label.Height = $Height

    if ($Font) {
        $label.Font = $Font
    }

    # Add the Label to the form
    $form.Controls.Add($label)

    return $label
}

function New-TextBox {
    param(
        [string]$textBoxText,  # The initial text inside the TextBox
        [int]$x,               # X position
        [int]$y,               # Y position
        [int]$width            # Width of the TextBox
    )

    # Create a new TextBox object
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Text = $textBoxText
    $textBox.Location = New-Object System.Drawing.Point($x, $y)
    $textBox.Width = $width

    # Add the TextBox to the form
    $form.Controls.Add($textBox)

    
    return $textBox
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
$labelIP = New-Label -Text "IP:" -Location (New-Object System.Drawing.Point(30, 20))
$form.Controls.Add($labelIP)

$labelGateway = New-Label -Text "Gateway:" -Location (New-Object System.Drawing.Point(30, 60))
$form.Controls.Add($labelGateway)

$labelSubnet = New-Label -Text "Subnet mask:" -Location (New-Object System.Drawing.Point(30, 100))
$form.Controls.Add($labelSubnet)

$textBoxIP = New-TextBox -x 150 -y 20 -width 180
$textBoxGateway = New-TextBox -x 150 -y 60 -width 180
$textBoxSubnet = New-TextBox -x 150 -y 100 -width 180
$textBoxDNS = New-TextBox -x 150 -y 140 -width 180

# Event handler for when the Subnet Mask TextBox gets focus
$placeholderSubnet = "255.255.255.0"
$textBoxSubnet.Text = $placeholderSubnet
$textBoxSubnet.ForeColor = [System.Drawing.Color]::Gray

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

$labelDNS = New-Label -Text "DNS:" -Location (New-Object System.Drawing.Point(30, 140))
$form.Controls.Add($labelDNS)

# Event handler for when the DNS TextBox gets focus
$placeholderDNS = "8.8.8.8"
$textBoxDNS.Text = $placeholderDNS
$textBoxDNS.ForeColor = [System.Drawing.Color]::Gray

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
$saveButtonIP1 = New-Button -Text "1" -Location (New-Object System.Drawing.Point(150, 180)) -Width 40 -Height 20
$saveButtonIP2 = New-Button -Text "2" -Location (New-Object System.Drawing.Point(200, 180)) -Width 40 -Height 20
$saveButtonIP3 = New-Button -Text "3" -Location (New-Object System.Drawing.Point(250, 180)) -Width 40 -Height 20
$saveButtonIP4 = New-Button -Text "4" -Location (New-Object System.Drawing.Point(300, 180)) -Width 40 -Height 20

# Buttons to Change IP
$buttonIP1 = New-Button -Text "Change to IP - 1" -Location (New-Object System.Drawing.Point(30, 240)) -Width 120
$buttonIP2 = New-Button -Text "Change to IP - 2" -Location (New-Object System.Drawing.Point(210, 240)) -Width 120
$buttonIP3 = New-Button -Text "Change to IP - 3" -Location (New-Object System.Drawing.Point(30, 300)) -Width 120
$buttonIP4 = New-Button -Text "Change to IP - 4" -Location (New-Object System.Drawing.Point(210, 300)) -Width 120

# Change IP Lable
$labelIP1 = New-Label -Text "192.168.10.72" -Location (New-Object System.Drawing.Point(30, 220))
$form.Controls.Add($labelIP1)

$labelIP2 = New-Label -Text "192.168.10.72" -Location (New-Object System.Drawing.Point(210, 220))
$form.Controls.Add($labelIP2)

$labelIP3 = New-Label -Text "192.168.10.72" -Location (New-Object System.Drawing.Point(30, 280))
$form.Controls.Add($labelIP3)

$labelIP4 = New-Label -Text "192.168.10.72" -Location (New-Object System.Drawing.Point(210, 280))
$form.Controls.Add($labelIP4)

# Network Setting Buttons
$networkButton = New-Button -Text "🌐" -Location (New-Object System.Drawing.Point(350, 18)) -Width 26 -Height 26
$networkButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)

$resetButton = New-Button -Text "🔄" -Location (New-Object System.Drawing.Point(350, 58)) -Width 26 -Height 26
$resetButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)

$uninstallButton = New-Button -Text "🗑️" -Location (New-Object System.Drawing.Point(350, 98)) -Width 26 -Height 26
$uninstallButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)

$buttonDHCP = New-Button -Text "DHCP" -Location (New-Object System.Drawing.Point(30, 350)) -Width 120

$ConfirmButtonIP = New-Button -Text "Confirm" -Location (New-Object System.Drawing.Point(210, 350)) -Width 120

# ToolTip
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.AutoPopDelay = 5000
$tooltip.InitialDelay = 1000
$tooltip.ReshowDelay = 500

# Add a tooltip
$tooltip.SetToolTip($networkButton, "Network Settings")
$tooltip.SetToolTip($resetButton, "Reset Stored Config")
$tooltip.SetToolTip($uninstallButton, "Uninstall NetCon")

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

        $defaultAdapter = "Ethernet"

        try {
            $netshCommand = "netsh interface ip set address name=`"$defaultAdapter`" static $ip $subnet $gateway && netsh interface ip set dns name=`"$defaultAdapter`" static $dns"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $netshCommand" -Verb RunAs -WindowStyle Hidden
            
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

$ConfirmButtonIP.Add_Click({
    $ip = $textBoxIP.Text
    $gateway = $textBoxGateway.Text
    $subnet = $textBoxSubnet.Text
    $dns = $textBoxDNS.Text

    if (-not (Approve-Input -ip $ip -subnet $subnet -gateway $gateway -dns $dns)) {
        return 
    }

    $netshCommand = "netsh interface ip set address name=`"$defaultAdapter`" static $ip $subnet $gateway && netsh interface ip set dns name=`"$defaultAdapter`" static $dns"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $netshCommand" -Verb RunAs -WindowStyle Hidden

    [System.Windows.Forms.MessageBox]::Show("Network settings updated!", "Success", "OK", "Information")
})

$buttonDHCP.Add_Click({
    $netshCommand = "netsh interface ip set address name=`"$defaultAdapter`" source=dhcp && netsh interface ip set dns name=`"$defaultAdapter`" source=dhcp"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $netshCommand" -Verb RunAs -WindowStyle Hidden

    [System.Windows.Forms.MessageBox]::Show("DHCP enabled!", "Success", "OK", "Information")
})

$networkButton.Add_Click({
    try {
        Start-Process -FilePath "ncpa.cpl"
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error opening Network Connections.", "Error", "OK", "Error")
    }
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

$uninstallButton.Add_Click({
    $uninstallerPath = "C:\Program Files (x86)\NetCon\Uninstall.exe"
    try {
        # Start the uninstaller
        Start-Process -FilePath $uninstallerPath -ArgumentList "/silent"
        $form.Close()
        Exit
        [System.Windows.Forms.MessageBox]::Show("Uninstallation started.", "Uninstall", "OK", "Information")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error starting uninstaller.", "Error", "OK", "Error")
    }
})

$saveButtonIP1.Add_Click({ Save-IPConfig "1" })
$saveButtonIP2.Add_Click({ Save-IPConfig "2" })
$saveButtonIP3.Add_Click({ Save-IPConfig "3" })
$saveButtonIP4.Add_Click({ Save-IPConfig "4" })

$buttonIP1.Add_Click({ set-IPConfig "1" })
$buttonIP2.Add_Click({ set-IPConfig "2" })
$buttonIP3.Add_Click({ set-IPConfig "3" })
$buttonIP4.Add_Click({ set-IPConfig "4" })

Update-IPLabels

# Handle Form Closing to release mutex
$form.Add_FormClosing({
    $mutex.ReleaseMutex() | Out-Null
    $mutex.Dispose()
})

$form.ShowDialog() | Out-Null