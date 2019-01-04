#Enter a path to your import CSV file
$ADUsers = Import-csv C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.*\Downloads\*\ADUsers.csv

foreach ($User in $ADUsers)
{

       $Username    = $User.username
       $Password    = $User.password
       $Firstname   = $User.firstname
       $Lastname    = $User.lastname
    $Department = $User.department
       $OU           = $User.ou

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
              #If a user does not exist then create a new user account
          
        #Account will be created in the OU listed in the $OU variable in the CSV file; don’t forget to change the domain name in the"-UserPrincipalName" variable
              New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@globant.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Lastname, $Firstname" `
            -Department $Department `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
}
$out = Get-ADUser -Filter{name -like "*" } | Select-object Samaccountname,givenname,surname,enabled 
$Object = New-Object PSObject -Property @{
"User Name" = $out.givenname
"SamAccountName" = $out.Samaccountname
"User Active State" = $out.enabled
} | Export-Csv C:\userStatus.csv -NoTypeInformation -Encoding UTF8