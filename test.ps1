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
	$coveragexml="coverage_$($resultsxml)"
  
    $args="
      -target:`"$(Path-Combine $Env:ProgramFiles, 'dotnet', 'dotnet.exe')`"
      -targetargs:`"test $($_) --framework $($PROJECT.testtarget) --configuration:Debug --test-adapter-path:. --logger:nunit;LogFilePath=$(Path-Combine $PROJECT.artifacts, $resultsxml)`"
      -output:`"$(Path-Combine $PROJECT.artifacts, $coveragexml)`"
      -oldStyle 
      -register:user 
      -excludebyattribute:*.ExcludeFromCoverage* 
      -filter:`"$($PROJECT.coveragefilter)`"
    "

    Exec $opencover -commandArgs $args
  }
}