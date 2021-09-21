param (
    [string]$FolderPath = $( Read-Host "Folder Path" )
)


$FolderItems = Get-ChildItem -Directory -Path $FolderPath -Recurse -Force
$Output = @()
$SkippedsAccounts = @("NT AUTHORITY\SYSTEM", "NT AUTHORITY\SYSTEM", "CREATOR OWNER", "BUILTIN\Administrators")

ForEach ($Folder in $FolderItems) {

    $Acl = Get-Acl -Path $Folder.FullName

    ForEach ($Access in $Acl.Access) {

        if(-not($SkippedsAccounts -contains $Access.IdentityReference))
        {
                $Properties = [ordered]@{'Folder Name'=$Folder.FullName;'Group/User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
                $Output += New-Object -TypeName PSObject -Property $Properties            
        }
    }
}

$Output # | Out-GridView