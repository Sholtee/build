#
# docfx.ps1
#
# Author: Denes Solti
#
function DocFx([Parameter(Position = 0)][string] $jsonpath) {
  $docFx=Path-Combine (Get-Package "docfx.console" -Version "2.59.3"), "tools", "docfx.exe" | Resolve-Path
  Exec $docFx -commandArgs "$jsonpath --warningsAsErrors"
}