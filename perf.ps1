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

  $perfexe=Get-ChildItem -Path (Path-Combine ($PROJECT.bin | Resolve-Path), "$((Get-Prop $PROJECT.perftests -Property "AssemblyName" | Out-String).Trim()).exe") -recurse
  Exec $perfexe -commandArgs "-f * -e GitHub -a `"$(Resolve-Path $artifacts)`"" -noLog
}