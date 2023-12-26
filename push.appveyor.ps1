#
# push.appveyor.ps1
#
# Author: Denes Solti
#
function Push-Test-Results() {
  if ($Env:APPVEYOR_REPO_TAG_NAME -is [string] -and $Env:APPVEYOR_REPO_TAG_NAME.StartsWith("perf")) { return }

  Push-TestResults "nunit"
  Push-TestResults "junit"

  Push-CoverageReports "coverage.xml", "lcov.info"
}

function Push-Artifact([Parameter(Position = 0)][string]$pattern) {
  $pattern=Path-Combine $PROJECT.artifacts, $pattern

  if (!(Directory-Path $pattern | Test-Path)) { return }
  
  Get-ChildItem -path $pattern | foreach { Push-AppveyorArtifact $_.FullName }
}

function Push-TestResults([Parameter(Position = 0)][string] $type) {
  $artifacts=Path-Combine $PROJECT.artifacts, $type
  if (!(Test-Path $artifacts)) { return }

  $client=New-Object System.Net.WebClient

  Get-ChildItem -Path (Path-Combine $artifacts, "*.xml") | foreach {
    Write-Host "Uploading [$type] test result: $($_.Name)"
    $client.UploadFile("https://ci.appveyor.com/api/testresults/$type/$Env:APPVEYOR_JOB_ID", $_.FullName)
  }
}

function Push-CoverageReports([Parameter(Position = 0)][string[]] $reports) {
  $coveralls=Path-Combine (Get-Package "coveralls.net" -Version "4.0.1" -IsTool), "csmacnz.Coveralls.exe" | Resolve-Path
  $i=0

  Get-ChildItem -Path (Path-Combine $PROJECT.artifacts, "*") -Include $reports | foreach {
    Write-Host "Uploading coverage report: $($_.Name)"

    $type=[System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $i+=1

    $commandArgs="--$type -i `"$($_.FullName)`" --repoToken $Env:COVERALLS_REPO_TOKEN --commitId $Env:APPVEYOR_REPO_COMMIT --commitBranch $Env:APPVEYOR_REPO_BRANCH --commitAuthor `"$Env:APPVEYOR_REPO_COMMIT_AUTHOR`" --commitEmail $Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL --commitMessage `"$Env:APPVEYOR_REPO_COMMIT_MESSAGE`" --jobId $Env:APPVEYOR_JOB_ID.$i --serviceName appveyor --serviceNumber $Env:APPVEYOR_BUILD_NUMBER --parallel --useRelativePaths"
    if ($Env:DEBUG_CI) { $commandArgs+=" -o `"$(Path-Combine $PROJECT.artifacts, "$type.debug.json")`""}

    Exec $coveralls -commandArgs $commandArgs -cwd (Resolve-Path "..")
  }

  Exec $coveralls -commandArgs "--completeParallelWork --repoToken $Env:COVERALLS_REPO_TOKEN --serviceNumber $Env:APPVEYOR_BUILD_NUMBER" -cwd (Resolve-Path "..")
}