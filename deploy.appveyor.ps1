#
# deploy.appveyor.ps1
#
# Author: Denes Solti
#
function Deploy() {
  if ($Env:APPVEYOR_REPO_TAG_NAME -match "^v\d+.\d+.\d+[-\w]*$") {
    Write-Host "Deploying to NuGet..."
	
    Pack | foreach {
      Write-Host "Deploying $($_.Name)"
      Exec "dotnet.exe" -commandArgs "nuget push `"$_`" -s https://api.nuget.org/v3/index.json -k $($Env:NUGET_REPO_TOKEN)"
    }
  }
  elseif ($Env:APPVEYOR_REPO_TAG_NAME -match "^web-v\d+.\d+.\d+[-\w]*$") {
    Write-Host "Deploying to NPM..."

    Web-PushPackage
  }
}