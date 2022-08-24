#
# pack.ps1
#
# Author: Denes Solti
#
function Pack() {
  Remove-Directory $PROJECT.bin

  $cwd=Directory-Path ($PROJECT.solution | Resolve-Path)
  # don't break into multiple lines. MSBUILD doesn't like it
  $cmdArgs="pack `"$($PROJECT.solution | Resolve-Path)`" -c Release -p:RepositoryType=git -p:RepositoryCommit=$((Exec "git.exe" -cwd $cwd -commandArgs "rev-parse HEAD" -redirectOutput).Trim()) -p:RepositoryBranch=$((Exec "git.exe" -cwd $cwd -commandArgs "rev-parse --abbrev-ref HEAD" -redirectOutput).Trim()) -p:RepositoryUrl=$((Exec "git.exe" -cwd $cwd -commandArgs "config --get remote.origin.url" -redirectOutput).Trim())"

  Exec "dotnet.exe" -commandArgs $cmdArgs
  Exec "dotnet.exe" -commandArgs "$($cmdArgs) -p:IncludeSymbols=true -p:SymbolPackageFormat=snupkg"

  return Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "*") -Include "*.nupkg", "*.snupkg" -Recurse
}