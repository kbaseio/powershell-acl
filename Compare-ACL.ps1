#requires -version 4
<#
.SYNOPSIS
  Compare ACLs from two differnt folders

.DESCRIPTION
  Compares ACLs on a share that exists on $SourceSystem and $DestSystem matches 'local' user names even if the SIDs differ. Ignores unresolvable SIDs.

.WARNING
  This script was just placed into the script template and has not been tested yet by FingersOnFire.

.WARNING
  get-acl cannot be used on strings containg certain characters (e.g. \\nas\common\report[1].pdf)
  Use .GetAccessControl() instead.
  See also: http://technet.microsoft.com/en-us/library/ff730956.aspx

.SOURCE
  https://github.com/buckelij/powershell/blob/master/compare-acl.ps1

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None>

.NOTES
  Version:        1.0
  Author:         Elijah Buck
  Creation Date:  Sept 2011
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

$SourceSystem="stor"
$DestSystem="nas"
$path="\common\"
$outfile="c:\compare-acl.txt" #File to log differences and errors to

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function compareAcl{
  process{
	$file = $_
	$item1=$file.FullName
	$item2=$pathroot2 + $item1.SubString($pathroot1.length)
	#write-output ("--" + $item1)
  try {
	#if item2 doesn't exist, skip it. It hasn't been copied yet.
	if(test-path -Literalpath $item2) {
	  #Get the ACL. Split into an array of lines. Sort. Match local sids to names. Filter out unresolved SIDs.
	  #acl1
	  $aclstring1=((get-item -literalpath "$item1").GetAccessControl()).AccessToString.split("`n")
	  foreach ( $SIDsub in $SourceSidreplacements ) {
	    $aclstring1 = $aclstring1 -replace $SIDSub[1], $SIDSub[0] #replace instance of SID with instances of NAME
	  }
	  $acl1 = $aclstring1|sort|select-string -notmatch -pattern "^S-.*" #remove any remaining unmatched SIDs
	  #acl2
	  $aclstring2=((get-item -literalpath "$item2").GetAccessControl()).AccessToString.split("`n")
	  foreach ( $SIDsub in $DestSidreplacements ) {
	    $aclstring2 = $aclstring2 -replace $SIDSub[1], $SIDSub[0]
	  }
	  $acl2 = $aclstring2|sort|select-string -notmatch -pattern "^S-.*"
  	  if (compare-object -Passthru $acl1 $acl2 ) {
	  	write-output $item1
		out-file -filepath $outfile -append -encoding ASCII -inputobject $item1
	  }
	}
  } catch {
		$err="ERR" + $item1 + $item2 + "ENDERR"
		write-output $err
		out-file -filepath $outfile -append -encoding ASCII -inputobject $err
	}
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$date=date

out-file -filepath $outfile -append -encoding ASCII -inputobject $date

#Enumerate local users and groups on SourceSystem and Destsystem
$SourceSIDreplacements = @()
$DestSIDreplacements = @()
$SourceComputerObj = [ADSI]("WinNT://" + $SourceSystem + ",computer")
$DestComputerObj = [ADSI]("WinNT://" + $DestSystem + ",computer")
$SourceUsers = $SourceComputerObj.psbase.children

if ($SourceUsers) {
  foreach ($u in $SourceUsers) {
    $SIDsub = @($u.name, (new-object System.Security.Principal.SecurityIdentifier $u.objectsid[0],0).Value)
	$SourceSIDreplacements += ,$SIDsub #wrap $SIDsub in array to prevent excessive unwrapping
  } 
}
$DestUsers = $DestComputerObj.psbase.children
if ($DestUsers) {
  foreach ($u in $DestUsers) {
    $SIDsub = @($u.name, (new-object System.Security.Principal.SecurityIdentifier $u.objectsid[0],0).Value)
    $DestSIDreplacements += ,$SIDsub #wrap $SIDsub in array to prevent excessive unwrapping
  } 
}


$pathroot1="\\" + $SourceSystem + $path
$pathroot2="\\" + $DestSystem+ $path

#MAIN
date
get-childitem -path $pathroot1 -recurse | compareAcl
date





