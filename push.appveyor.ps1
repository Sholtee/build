#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  if ($Env:APPVEYOR_REPO_TAG_NAME -is [string] -and $Env:APPVEYOR_REPO_TAG_NAME.StartsWith("perf")) { return }

  $client= New-Object System.Net.WebClient
  $coveragexml="coverage.xml"
	
  Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*.xml") -Exclude $coveragexml | foreach {
    Write-Host "Uploading test result: $($_.Name)"
    $client.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($Env:APPVEYOR_JOB_ID)", $_.ToString())
  }

  $coveragereport=Path-Combine $PROJECT.artifacts, $coveragexml
 
  if (Test-Path $coveragereport) {
    Write-Host "Uploading coverage report..."

    $coveralls=Path-Combine (Get-Package "coveralls.io" -Version "1.4.2"), "tools", "coveralls.net.exe" | Resolve-Path
    Exec $coveralls -commandArgs "--opencover `"$($coveragereport)`" -r $($Env:COVERALLS_REPO_TOKEN)" -cwd (Resolve-Path "..")
  }

  if ($PROJECT.web -is [string]) {
    Write-Host "Uploading WEB test results..."
    Web-PushResults
    Write-Host "Uploading WEB coverage report..."
    Web-PushCoverage
  }
}

function Push-Artifact([Parameter(Position = 0)][string]$pattern) {
  $pattern=Path-Combine $PROJECT.artifacts, $pattern

  if (!(Directory-Path $pattern | Test-Path)) { return }
  
  Get-ChildItem -path $pattern | foreach { Push-AppveyorArtifact $_.FullName }
}