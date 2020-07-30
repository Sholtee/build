#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  $client= New-Object System.Net.WebClient
  $coveragexml="coverage.xml"
	
  Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*.xml") -Exclude $coveragexml | foreach {
    Write-Host "Uploading test result: $($_.Name)"
    $client.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($Env:APPVEYOR_JOB_ID)", $_.ToString())
  }

  $coveragereport=Path-Combine $PROJECT.artifacts, $coveragexml
 
  if (Test-Path $coveragereport) {
    Write-Host "Uploading coverage report..."

    $coveralls=Path-Combine (Get-Package "coveralls.net" -Version "1.0.0" -IsTool), "csmacnz.coveralls.exe" | Resolve-Path
    Exec $coveralls -commandArgs "--opencover -i `"$($coveragereport)`" --repoToken $($Env:COVERALLS_REPO_TOKEN) --commitId $($Env:APPVEYOR_REPO_COMMIT) --commitBranch $($Env:APPVEYOR_REPO_BRANCH) --commitAuthor $($Env:APPVEYOR_REPO_COMMIT_AUTHOR) --commitEmail $($Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL) --commitMessage $($Env:APPVEYOR_REPO_COMMIT_MESSAGE) --jobId $($Env:APPVEYOR_JOB_ID)" -cwd (Resolve-Path "..")
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