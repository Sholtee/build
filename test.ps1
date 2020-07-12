#
# test.ps1
#
# Author: Denes Solti
#
function Regular-Tests() {
  Remove-Directory $PROJECT.artifacts
  Create-Directory $PROJECT.artifacts

  $opencover=Path-Combine (Get-Package "OpenCover" -Version "4.7.922"), "tools", "OpenCover.Console.exe" | Resolve-Path

  Get-ChildItem -Path (Path-Combine $PROJECT.root, $PROJECT.tests) | foreach {
    $resultsxml=Path-ChangeExtension $_.Name -Extension 'xml'

    $args="
      -target:`"$(Path-Combine $Env:ProgramFiles, 'dotnet', 'dotnet.exe')`"
      -targetargs:`"test $($_) --configuration:Debug --test-adapter-path:. --logger:nunit;LogFilePath=$(Path-Combine $PROJECT.artifacts, $resultsxml)`"
      -output:`"$(Path-Combine $PROJECT.artifacts, 'coverage.xml')`"
	  -mergeoutput
      -oldStyle 
      -register:user 
      -excludebyattribute:*.ExcludeFromCoverage* 
      -filter:`"$($PROJECT.coveragefilter)`"
    "

    Exec $opencover -commandArgs $args
  }
}