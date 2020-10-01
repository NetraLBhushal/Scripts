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

$CSVFILEPATH = "https://raw.githubusercontent.com/NetraLBhushal/Scripts/master/Service_Accounts.csv"
$DEST_OU="OU=Service Accounts,DC=azure,DC=energy,DC=internal"

if ((Test-path ($CSVFILEPATH)) -eq $false){
    throw "CSV FILE $CSVFILEPATH not found!"
}

Foreach ($sa in $(import-csv -Path $CSVFILEPATH)){
    New-ServiceAccount -samaccountname $sa.samaccountname -description $sa.description -password $sa.password -destou $DEST_OU
}

get-aduser -searchbase "OU=Service Accounts,DC=azure,DC=energy,DC=internal" -filter * | select-object samaccountname



