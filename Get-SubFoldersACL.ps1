param (
    [string]$FolderPath = $( Read-Host "Folder Path" )
)

$FolderList = Get-ChildItem $FolderPath | where-object { $_.PSIScontainer }
$ExcludedUsers = @("NT AUTHORITY\SYSTEM", "NT AUTHORITY\SYSTEM", "CREATOR OWNER", "BUILTIN\Administrators")
$ACLReport = @();

foreach ($Folder in $FolderList){

    $FolderACLList = Get-Acl $Folder.FullName | Select -expand Access

    foreach ($FolderACL in $FolderACLList){
    
        if($ExcludedUsers -notcontains $FolderACL.IdentityReference){
    
           $ACLReportData = @{
                "FolderName" = $Folder.Name;
                "FolderFullName" = $Folder.FullName;
                "Identity" = $FolderACL.IdentityReference;
                "AccessRights" = $FolderACL.FileSystemRights;
           }

           $ACLReport += (New-Object -TypeName PSObject -Property $ACLReportData)

        }
    
    }

}

$ACLReport