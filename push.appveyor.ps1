#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  $testresults=Path-Combine $PROJECT.artifacts, $PROJECT.testresults

  if (Test-Path $testresults) {
    $client= New-Object System.Net.WebClient
	
    Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*.xml") -Exclude "coverage_*" | foreach {
      Write-Host "Uploading test result: $($_.Name)"
      $client.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($Env:APPVEYOR_JOB_ID)", $_.ToString())
    }
  }

  $coveragereport=Path-Combine $PROJECT.artifacts, $PROJECT.coveragereport

  if (Test-Path $coveragereport) {
    $coveralls=Path-Combine (Get-Package "coveralls.io" -Version "1.4.2"), "tools", "coveralls.net.exe" | Resolve-Path
    
	Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "coverage_*.xml") | foreach {
	  Write-Host "Uploading coverage report: $($_.Name)"
      Exec $coveralls -commandArgs "--opencover `"$($_.ToString())`" -r $Env:COVERALLS_REPO_TOKEN"
    }
  }
}

function Push-Artifact([Parameter(Position = 0)][string]$pattern) {
  $pattern=Path-Combine $PROJECT.artifacts, $pattern

  if (!(Directory-Path $pattern | Test-Path)) { return }
  
  Get-ChildItem -path $pattern | foreach { Push-AppveyorArtifact $_.FullName }
}