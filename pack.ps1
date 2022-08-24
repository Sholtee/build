#
# pack.ps1
#
# Author: Denes Solti
#
function Pack() {
  Remove-Directory $PROJECT.bin

  $currentbranch=Exec "git.exe" -commandArgs "rev-parse --abbrev-ref HEAD" -redirectOutput 
  $cmdArgs="pack `"$($PROJECT.solution | Resolve-Path)`" -c Release -p:CurrentBranch=$($currentbranch)"

  Exec "dotnet.exe" -commandArgs $cmdArgs
  Exec "dotnet.exe" -commandArgs "$($cmdArgs) -p:IncludeSymbols=true -p:SymbolPackageFormat=snupkg"

  return Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "*") -Include "*.nupkg", "*.snupkg" -Recurse
}