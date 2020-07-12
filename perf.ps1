#
# perf.ps1
#
# Author: Denes Solti
#
function Performance-Tests() {
  $artifacts=Path-Combine $PROJECT.artifacts, "BenchmarkDotNet.Artifacts"

  Remove-Directory $artifacts
  Create-Directory $artifacts

  Remove-Directory $PROJECT.bin
  Create-Directory $PROJECT.bin

  Exec "dotnet.exe" -commandArgs "build `"$($PROJECT.solution | Resolve-Path)`" -c Perf"

  [XML]$csproj=Resolve-Path $PROJECT.perftests | Get-Content
  $perfexe=Get-ChildItem -path (Path-Combine ($PROJECT.bin | Resolve-Path), "$(($csproj.Project.PropertyGroup.AssemblyName | Out-String).Trim()).exe") -recurse

  Exec $perfexe -commandArgs "-f * -e GitHub -a `"$(Resolve-Path $artifacts)`"" -noLog
}