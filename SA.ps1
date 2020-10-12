Param ($SAtestuser, $SAtestpass, $description)
$SAtestuser = $SAtestuser.Split(",")
$SAtestpass = $SAtestpass.Split(" ")
$description = $description.Split(",")

function New-ServiceAccount {
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $samaccountname,
         [Parameter(Mandatory=$true)]
        [string]
        $description,
         [Parameter(Mandatory=$true)]
        [string]
        $password,
         [Parameter(Mandatory=$true)]
        [string]
         $destou
    )
    $psw = convertto-securestring "$password" -asplaintext -force
    $destou="OU=$($ua_ouname[$i]),$oupath"

    New-ADUser -Path $destou -Name "$samaccountname"  -AccountPassword $psw -Enabled $true -AllowReversiblePasswordEncryption $false -CannotChangePassword $true -PasswordNeverExpires $true
    Write-Output "$samaccountname service account created in $destou"
}

for($i = 0; $i -lt $SAtestuser.length; $i++) { 

    if (Get-ADUser -F {SamAccountName -eq $SamAccountName})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $samaccountname already exist in Active Directory."
       }
       else
       {
              #If a user does not exist then create a new user account

    New-ServiceAccount -samaccountname $SAtestuser[$i] -description $description[$i] -password $SAtestpass[$i] -destou $DEST_OU
    
    }
}
