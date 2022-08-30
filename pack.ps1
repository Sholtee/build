#
# pack.ps1
#
# Author: Denes Solti
#
function Pack() {
  Remove-Directory $PROJECT.bin

  $cmdArgs="pack `"$($PROJECT.solution | Resolve-Path)`" -c Release -p:RepositoryType=git -p:RepositoryCommit=$($PROJECT.hash) -p:RepositoryBranch=$($PROJECT.branch) -p:RepositoryUrl=$($PROJECT.repo)  -p:CommitHash=$($PROJECT.hash)  -p:CustomBeforeMicrosoftCSharpTargets=$('GitMeta.targets' | Resolve-Path)"

  Exec "dotnet.exe" -commandArgs $cmdArgs
  Exec "dotnet.exe" -commandArgs "$cmdArgs -p:IncludeSymbols=true -p:SymbolPackageFormat=snupkg"

  return Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "*") -Include "*.nupkg", "*.snupkg" -Recurse
}