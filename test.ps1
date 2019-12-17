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
    -targetargs:`"test $($PROJECT.tests) --framework $($PROJECT.testtarget) --configuration:Debug --test-adapter-path:. --logger:nunit;LogFilePath=$(Path-Combine $PROJECT.artifacts, $PROJECT.testresults)`"
    -output:`"$(Path-Combine $PROJECT.artifacts, $PROJECT.coveragereport)`"
    -oldStyle 
    -register:user 
    -excludebyattribute:*.ExcludeFromCoverage* 
    -filter:`"$($PROJECT.coveragefilter)`"
  "

  Exec $opencover -commandArgs $args
}