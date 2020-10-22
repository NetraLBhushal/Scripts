# Log File Path
$LogFile = "C:\Temp\PostInstallScript.log"

# Create C:\Temp directory
New-Item -ItemType Directory -Path "C:\Temp" -Force

# Label C:\
Set-Volume -DriveLetter C -NewFileSystemLabel "SYSTEM"

# Move CDROM to Z:\
(gwmi Win32_cdromdrive).drive | %{$a = mountvol $_ /l;mountvol $_ /d;$a = $a.Trim();mountvol z: $a}

# Enable Incoming traffic on the Domain Profile 
Get-NetFirewallRule -DisplayName Allow-All -ErrorAction SilentlyContinue
if ($? -ne $true)
{
	Add-Content -Value "Allow-All Firewall rule does not exists" -Path $LogFile
	New-NetFirewallRule -DisplayName "Allow-All" -Profile Domain -Direction Inbound 
}

# Disable IE Enhanced Security Configuration for Administrators
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0

# Unbind IPv6 from the Network Adapter
$NIC = Get-NetAdapterBinding | where-object {$_.ComponentID -eq "ms_tcpip6"}
Disable-NetAdapterBinding -Name $NIC.Name -ComponentID "ms_tcpip6"

# Setup Disk Drives
Add-Content -Value "Setting up drives " -Path $LogFile
try {
	$NewDisk = @(Get-Disk | Sort-Object Number | Where-Object partitionstyle -eq 'raw')
	$DiskLetter = @('F')
	$DiskLabel = @('NTDS')

	for($i = 0; $i -lt $NewDisk.Count ; $i++)
	{
		$DiskNum = $NewDisk[$i].Number
		Get-Disk $DiskNum | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter $DiskLetter[$i] -UseMaximumSize
		Format-Volume -DriveLetter $DiskLetter[$i] -FileSystem NTFS -NewFileSystemLabel $DiskLabel[$i] -Confirm:$false
		Add-Content -Value "Format Drive $DiskNum - $($DiskLetter[$i]) - $($DiskLabel[$i])" -Path $LogFile
	}
}
catch {
	Add-Content -Value "Drive Setup Failed" -Path $LogFile
	Add-Content -Value $Error[0] -Path $LogFile
	Exit
}

# Install Additional Windows Roles
$roles = "Windows-Server-Backup"

try {
	foreach ($role in $roles)
	{
		$check = Get-WindowsFeature -name $role

		if ($check.Installed -ne "True") 
		{
			Install-WindowsFeature $role
			Add-Content -Value "Installing role : $role" -Path $LogFile
		}
	}
}
catch {
	Add-Content -Value "$role : failed to install" -Path $LogFile
	Add-Content -Value $Error[0] -Path $LogFile
	Exit
}