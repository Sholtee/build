#
# test.ps1
#
# Author: Denes Solti
#
function Regular-Tests() {
  Remove-Directory $PROJECT.artifacts
  Create-Directory $PROJECT.artifacts

  $opencover=Path-Combine (Get-Package "OpenCover" -Version "4.7.922"), "tools", "OpenCover.Console.exe" | Resolve-Path

  $args="
    -target:`"$(Path-Combine $Env:ProgramFiles, 'dotnet\dotnet.exe')`"
    -targetargs:`"test $(Resolve-Path $PROJECT.tests) --framework $($PROJECT.testtarget) --configuration:Debug --test-adapter-path:. --logger:nunit;LogFilePath=$(Path-Combine (Resolve-Path $PROJECT.artifacts), 'testresults.xml')`"
    -output:`"$(Path-Combine (Resolve-Path $PROJECT.artifacts), 'coverage.xml')`"
    -oldStyle 
    -register:user 
    -excludebyattribute:*.ExcludeFromCoverage* 
    -filter:`"$($PROJECT.coveragefilter)`"
  "

  Exec $opencover -commandArgs $args
}