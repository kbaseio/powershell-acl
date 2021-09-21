#requires -version 4
<#
.SYNOPSIS
  List Permission that are not inherited

.DESCRIPTION
  Check files and folders permissions and list them should the value IsInerithed be set to FALSE

.WARNING
  This script was just placed into the script template and has not been tested yet by FingersOnFire.

.SOURCE
  https://community.spiceworks.com/topic/493582-list-file-permissions-that-are-not-inherited

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  Permission Report for Items with Disabled inheritance
  Permission Report for Items with Errors

.NOTES
  Version:        1.0
  Author:         cduff
  Creation Date:  2014-05-14
  Purpose/Change: Initial script development

.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$search_folder = "C:\Folder"
$out_file = "C:\Temp\ACLNotInherited.csv"
$out_error = "C:\Temp\ACLNotInherited-Errors.csv"

$items = @()

$found = @()
$errors = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Listing Files and Folders"¨
$items = Get-ChildItem -Path $search_folder -recurse


Write-Host "Checking ACLs for each Files and Folders"

ForEach ($item in $items) {

    try {
        $acl = Get-Acl $item.fullname

        ForEach ($entry in $acl.access) {
            If (!$entry.IsInherited) { 
                $found += New-Object -TypeName PSObject -Property @{
                    Folder = $item.fullname
                    Access = $entry.FileSystemRights
                    Control = $entry.AccessControlType
                    User = $entry.IdentityReference
                    # Inheritance = $entry.IsInherited    
                
                }        
            }
        }
    } catch {
    
        $errors += New-Object -TypeName PSObject -Property @{
            Item = $item.fullname
            Error = $_.exception
        }
    
    }
}

$found |  Export-Csv -NoTypeInformation -Path $out_file

$errors | Export-Csv -NoTypeInformation -Path $out_error