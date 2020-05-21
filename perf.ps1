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

  Exec "dotnet.exe" -commandArgs "build $(Resolve-Path $PROJECT.perftests) --framework $($PROJECT.perftarget) --configuration Perf --output `"$(Resolve-Path $PROJECT.bin)`""

  [XML]$csproj=Resolve-Path $PROJECT.perftests | Get-Content
  $perfexe="$(($csproj.Project.PropertyGroup.AssemblyName | Out-String).Trim()).exe"

  Exec "$(Path-Combine $PROJECT.bin, $perfexe | Resolve-Path)" -commandArgs "-f * -e GitHub -a `"$(Resolve-Path $artifacts)`"" -noLog
}