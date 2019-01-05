﻿#Enter a path to import User CSV file
$ADUsers = Import-csv C:\ADUsers.csv

foreach ($User in $ADUsers)
{

        $SAName = $User.SAName
        $FirstName = $User.FirstName
        $LastName = $User.LastName
        $Password = $User.Password
        $Path = $User.Path
        $FullName = "$FirstName $LastName"

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq "$SAName"}){
            
            #If user does exist, output a warning message
            Write-Warning "A user account $SAName already exists in Active Directory."
       } 
       else {
            #If a user does not exist then create a new user account
            New-ADUser -SamAccountName $SAName `
            -Name $FullName -GivenName $FirstName -Surname $LastName `
            -Path $Path -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $true -Enabled $true
       }
}
$out = Get-ADUser -Filter{name -like "*" } | Select-object Samaccountname,givenname,surname,enabled 
$Object = New-Object PSObject -Property @{
"User Name" = $out.givenname
"SamAccountName" = $out.Samaccountname
"User Active State" = $out.enabled
} | Export-Csv C:\userStatus.csv -NoTypeInformation -Encoding UTF8