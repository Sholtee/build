#
# pack.ps1
#
# Author: Denes Solti
#
function Pack() {
  Remove-Directory $PROJECT.bin

  $cwd=Directory-Path ($PROJECT.solution | Resolve-Path)
  $hash=(Exec "git.exe" -cwd $cwd -commandArgs "rev-parse HEAD" -redirectOutput).Trim()
  $branch=(Exec "git.exe" -cwd $cwd -commandArgs "rev-parse --abbrev-ref HEAD" -redirectOutput).Trim()
  $repo=(Exec "git.exe" -cwd $cwd -commandArgs "config --get remote.origin.url" -redirectOutput).Trim()
  $cmdArgs="pack `"$($PROJECT.solution | Resolve-Path)`" -c Release -p:RepositoryType=git -p:RepositoryCommit=$hash -p:RepositoryBranch=$branch -p:RepositoryUrl=$repo -p:CommitHash=$hash -p:CustomBeforeMicrosoftCSharpTargets=$('GitMeta.targets' | Resolve-Path)"

  Exec "dotnet.exe" -commandArgs $cmdArgs
  Exec "dotnet.exe" -commandArgs "$cmdArgs -p:IncludeSymbols=true -p:SymbolPackageFormat=snupkg"

  return Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "*") -Include "*.nupkg", "*.snupkg" -Recurse
}