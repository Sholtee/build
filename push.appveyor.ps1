#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  if ($Env:APPVEYOR_REPO_TAG_NAME -is [string] -and $Env:APPVEYOR_REPO_TAG_NAME.StartsWith("perf")) { return }

  $client= New-Object System.Net.WebClient

  Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*.xml") -Exclude "coverage.xml" | foreach {
    Write-Host "Uploading test result: $($_.Name)"
    $client.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($Env:APPVEYOR_JOB_ID)", $_.ToString())
  }

  if ($PROJECT.web -is [string]) {
    Write-Host "Uploading WEB test results..."
    Web-PushResults
  }

  Push-CoverageReports "coverage.xml", "lcov.info"
}

function Push-Artifact([Parameter(Position = 0)][string]$pattern) {
  $pattern=Path-Combine $PROJECT.artifacts, $pattern

  if (!(Directory-Path $pattern | Test-Path)) { return }
  
  Get-ChildItem -path $pattern | foreach { Push-AppveyorArtifact $_.FullName }
}

function Push-CoverageReports([Parameter(Position = 0)][string[]] $reports) {
  $coveralls=Path-Combine (Get-Package "coveralls.net" -Version "3.0.0" -IsTool), "csmacnz.Coveralls.exe" | Resolve-Path

  $i=$reports.Length
  Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*") -Include $reports | foreach {
    $last=$i-- -EQ 0
    Write-Host "Uploading coverage report: $($_.Name) [last: $($last)]"

    $commandArgs="--opencover -i $($_) --repoToken $($Env:COVERALLS_REPO_TOKEN) --useRelativePaths --commitId $($Env:APPVEYOR_REPO_COMMIT) --commitBranch $($Env:APPVEYOR_REPO_BRANCH) --commitAuthor $($Env:APPVEYOR_REPO_COMMIT_AUTHOR) --commitEmail $($Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL) --commitMessage $($Env:APPVEYOR_REPO_COMMIT_MESSAGE) --jobId $($Env:APPVEYOR_BUILD_NUMBER) --serviceName appveyor --parallel"
    if ($last) { $commandArgs+= "--completeParallelWork"}

    Exec $coveralls -commandArgs  -cwd (Resolve-Path "..")
  }
}