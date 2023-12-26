#
# nuget.ps1
#
# Author: Denes Solti
#
function Get-Package([Parameter(Position = 0)][string]$packageName, [string]$version, [switch]$isTool) {
  # Install fails if the destination directory does not exist
  Create-Directory $PROJECT.vendor
  
  if ($isTool) {
    Exec "dotnet.exe" -commandArgs "tool install $($packageName) --version $($version) --tool-path `"$(Path-Combine $PROJECT.vendor, ('{0}.{1}' -F $packageName, $version))`"" -ignoreError
  } else {
    Exec "nuget.exe" -commandArgs "install $($packageName) -OutputDirectory `"$($PROJECT.vendor)`" -Version $($version)" -ignoreError
  }

  # Resolve-Path to verify package folder
  return (Path-Combine $PROJECT.vendor, "$($packageName).$($version)") | Resolve-Path
}