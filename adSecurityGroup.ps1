Param ($sgname, $description, $sgpath, $GroupCategory, $GroupScope, $DisplayName)
$sgname         = $sgname.Split(",")
$description    = $description.Split(",")
$DisplayName    = $DisplayName.Split(",")

for($i = 0; $i -lt $sgname.length; $i++) { 
if (Get-ADGroup -Filter * -SearchBase $sgpath | where sAMAccountName -EQ $sgname[$i])
    {  
      #If Security group does exist, output a warning message
      Write-Warning "A Security Group $sgname already exist in Active Directory."
    }
  else
    {
      #If a Security group does not exist then create a new one.
	New-ADGroup -Name $sgname[$i] -SamAccountName $sgname[$i] -GroupCategory $GroupCategory -GroupScope $GroupScope -DisplayName $DisplayName[$i] -Path $sgpath -Description $description[$i]

	Write-Output "$sgname SG account created in $sgpath"
	}
   
}