#
# nuget.ps1
#
# Author: Denes Solti
#
function Get-Package([Parameter(Position = 0)][string]$packageName, [string]$version) {
  # Install fails if the destination directory does not exist
  Create-Directory $PROJECT.vendor
  
  Exec "nuget.exe" -commandArgs "install $($packageName) -OutputDirectory `"$($PROJECT.vendor)`" -Version $($version)"
  
  # Resolve-Path to verify package folder
  return (Path-Combine $PROJECT.vendor, "$($packageName).$($version)") | Resolve-Path
}