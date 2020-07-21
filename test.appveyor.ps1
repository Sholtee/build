#
# test.appveyor.ps1
#
# Author: Denes Solti
#
function Test() {
  $match = [System.Text.RegularExpressions.Regex]::Match($Env:APPVEYOR_REPO_TAG_NAME, "^perf(?:-v(?<version>\d+.\d+.\d+[-\w]*))?$")
  if ($match.Success) {
    $ver = $match.Groups["version"]
    if ($ver.Success) {
      $Env:LibVersion = $ver.Value
    }
	
    if($Env:LibVersion -is [String]) {$target = $Env:LibVersion} else {$target = "source"}
	
    Write-Host "Running performance tests against $($target)..."	
    Performance-Tests
  } else {
    Write-Host Running regular tests...
    Regular-Tests
	
    if ($PROJECT.web -is [String]) {
	  Write-Host Running WEB tests...
	  Web-Restore
	  Web-Tests
    }
  }
}