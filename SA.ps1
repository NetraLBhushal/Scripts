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
   
    New-ADUser -Path $destou -Name "$samaccountname"  -AccountPassword $psw -Enabled $true -AllowReversiblePasswordEncryption $false -CannotChangePassword $true -PasswordNeverExpires $true
    Write-Output "$samaccountname service account created in $destou"
}

$DEST_OU="OU=Service,DC=azure,DC=energy,DC=internal"
for($i = 0; $i -lt $SAtestuser.length; $i++) { 

    New-ServiceAccount -samaccountname $SAtestuser[$i] -description $description[$i] -password $SAtestpass[$i] -destou $DEST_OU
    
    }
}
