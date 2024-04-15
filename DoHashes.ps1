##******************************************************************
##
## Revision date: 2024.04.15
##
## Copyright (c) 2021-2024 PC-Évolution enr.
## This code is licensed under the GNU General Public License (GPL).
##
## THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
## ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
## IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
## PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
##
##******************************************************************

param(
	# Default parameter values
	[parameter( Mandatory = $false )] [string] $CatalogName = "Hashes.txt",
	[parameter( Mandatory = $false )] [string] $Algorithm = "SHA256",
	[parameter( Mandatory = $false )] [string] $KnownSignature
)


$Root = (Split-Path $script:MyInvocation.MyCommand.Path) + "\"
$Mask = $Root.Replace("\", "\\")

Write-Output "Hasher maker:"
Try	{
	$Test = Get-Content -Path "$Root\$CatalogName" -ErrorAction Stop
	# Pass 1: Test known signature (published somewhere else, obviously!)
	$Signature = Get-FileHash "$Root\$CatalogName" -Algorithm $Algorithm
	$PublishedSignature = If ( [string]::IsNullOrEmpty( $KnownSignature ) ) { Read-Host -Prompt "Enter known signature" } else { $KnownSignature }
	If ($PublishedSignature -ieq $Signature.Hash) { Write-Output ("Catalogue signature verified in catalogue {0}" -f ("$Root\$CatalogName")) }
	else {
		Write-Warning ("Signatures do not match. Catalogue signature: {0}" -f $Signature.Hash)
		Write-Warning ("Catalogue name: {0}" -f ("$Root\$CatalogName"))
	}
}
Catch {
 Write-Warning "Creating signatures ..."
	# Pass 1: create signatures list.
	$AllFiles = (Get-ChildItem -Path "$Root" -File -Recurse -Force -ErrorAction SilentlyContinue)
	$List = Get-FileHash -LiteralPath $AllFiles.FullName -Algorithm $Algorithm
	$Test = ForEach ($Result in $List) { "{0}`t{1}" -f $Result.Hash, ([System.IO.Path]::GetFullPath($Result.Path) -Replace "$Mask", "") }
	$Test | Out-File "$Root\$CatalogName"
	# Spit out the directory signature (files can still be added to this directory ;-)
	$Signature = Get-FileHash "$Root\$CatalogName" -Algorithm $Algorithm
	Write-Output "Catalogue signature:" $Signature.Hash
}

# Pass 2: verify signatures
$RealFiles = @()
foreach ($Item in $Test) {
	$Fields = $Item -Split ("`t")
	Try {
		If ($Fields[0] -ne (Get-FileHash -LiteralPath "$Root$($Fields[1])" -Algorithm $Algorithm  -ErrorAction Stop ).Hash)
		{ Write-Warning ("File {0} has been altered." -f $Fields[1]) }
		$RealFiles += $Fields[1]
	}
	Catch { Write-Warning ("File {0} is missing!" -f $Fields[1]) }
}

# Pass 3: Find out if files were added to this directory ;-)
$RealFiles += "$CatalogName"
$AllFiles = (Get-ChildItem -Path "$Root" -File -Recurse -Force -ErrorAction SilentlyContinue).Fullname -Replace "$Mask", ""
$OtherFiles = Compare-Object -ReferenceObject $AllFiles -DifferenceObject $RealFiles
If ($OtherFiles.InputObject.Count -gt 0) { Write-Output "Unknown files present in this directory: " $OtherFiles.InputObject }

Write-Output "Done."
Pause
