#
# pack.ps1
#
# Author: Denes Solti
#
function Pack() {
  Remove-Directory $PROJECT.bin

  $PROJECT.variants | ForEach-Object {
    $variant=$_
    $cmdArgs="pack `"$($PROJECT.solution | Resolve-Path)`" -c Release -p:Variant=$variant -p:RepositoryType=git -p:RepositoryCommit=$($PROJECT.hash) -p:RepositoryBranch=$($PROJECT.branch) -p:RepositoryUrl=$($PROJECT.repo) -p:CommitHash=$($PROJECT.hash) -p:CustomBeforeMicrosoftCSharpTargets=$('GitMeta.targets' | Resolve-Path)"

    Exec "dotnet.exe" -commandArgs $cmdArgs
    Exec "dotnet.exe" -commandArgs "$cmdArgs -p:IncludeSymbols=true -p:SymbolPackageFormat=snupkg"
  }

  # Return .nupkg only. .snupkg will also be published if it is present alongside the primary package
  return Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "*") -Include "*.nupkg" -Recurse
}