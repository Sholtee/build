#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  $testresults=Path-Combine $PROJECT.artifacts, "testresults.xml"

  if (Test-Path $testresults) {
    Write-Host Uploading test results...
  
    $client= New-Object System.Net.WebClient
    $client.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($Env:APPVEYOR_JOB_ID)", $testresults)
  }

  $coveragereport=Path-Combine $PROJECT.artifacts, "coverage.xml"

  if (Test-Path $coveragereport) {
    Write-Host Uploading coverage report...

    $coveralls=Path-Combine (Get-Package "coveralls.net" -Version "1.0.0"), "tools", "csmacnz.coveralls.exe" | Resolve-Path
    Exec $coveralls -commandArgs "--opencover -i `"$($coveragereport)`" --repoToken $Env:COVERALLS_REPO_TOKEN --commitId $Env:APPVEYOR_REPO_COMMIT --commitBranch $Env:APPVEYOR_REPO_BRANCH --commitAuthor $Env:APPVEYOR_REPO_COMMIT_AUTHOR --commitEmail $Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL --commitMessage $Env:APPVEYOR_REPO_COMMIT_MESSAGE --jobId $Env:APPVEYOR_BUILD_NUMBER --serviceName appveyor"
  }
}

function Push-Artifact([Parameter(Position = 0)][string]$pattern) {
  $pattern=Path-Combine $PROJECT.artifacts, $pattern

  if (!(Directory-Path $pattern | Test-Path)) { return }
  
  Get-ChildItem -path $pattern | foreach { Push-AppveyorArtifact $_.FullName }
}