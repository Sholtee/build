#
# test.ps1
#
# Author: Denes Solti
#
function Regular-Tests() {
  Remove-Directory $PROJECT.artifacts
  Create-Directory $PROJECT.artifacts

  $opencover=Path-Combine (Get-Package "OpenCover" -Version "4.7.1221"), "tools", "OpenCover.Console.exe" | Resolve-Path

  Get-ChildItem -Path (Path-Combine $PROJECT.root, $PROJECT.tests) | foreach {
    $csproj=$_

    if ($PROJECT.testcommonprops -is [string]) { $propsPath=$PROJECT.testcommonprops }
    else { $propsPath=$csproj }

    [XML]$props=Get-Content $propsPath
    ($props.Project.PropertyGroup.TargetFrameworks | Out-String).Trim().Split(";") | foreach {
      $targetFw=$_

      $resultsxml="$(Path-GetFileNameWithoutExtension $csproj).$targetFw.xml"

      $cmdArgs="
        -target:`"$(Path-Combine $Env:ProgramFiles, 'dotnet', 'dotnet.exe')`"
        -targetargs:`"test $csproj --configuration:Debug --framework:$targetFw --test-adapter-path:. --logger:nunit;LogFilePath=$(Path-Combine $PROJECT.artifacts, 'nunit', $resultsxml)`"
        -output:`"$(Path-Combine $PROJECT.artifacts, 'opencover.xml')`"
        -mergeoutput
        -oldStyle
        -register:user
        -threshold:1
        -excludebyattribute:*.ExcludeFromCoverage*
        -filter:`"$($PROJECT.coveragefilter)`"
        -returntargetcode
      "

      Exec $opencover -commandArgs $cmdArgs
    }
  }
}