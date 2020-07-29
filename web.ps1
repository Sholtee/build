#
# web.ps1
#
# Author: Denes Solti
#

function Invoke-NPM([Parameter(Position = 0, Mandatory = $true)][string] $arg) {
  if ($PROJECT.web -is [string]) {
    Exec (Get-Command "npm").Path -commandArgs $arg -cwd ($PROJECT.web | Resolve-Path)
  }
}

function Web-Restore() { Invoke-NPM "install" }

function Web-Tests() { Invoke-NPM "test --loglevel verbose" }

function Web-PushResults() { Invoke-NPM "run pushresults --loglevel verbose" }

function Web-PushCoverage() { Invoke-NPM "run pushcoverage --loglevel verbose" }

function Web-PushPackage() {
  Invoke-NPM "run build --loglevel verbose"
  Out-File -FilePath (Path-Combine $PROJECT.web, ".npmrc") -Encoding "UTF8" -InputObject "//registry.npmjs.org/:_authToken=$($Env:NPM_REPO_TOKEN)"
  Invoke-NPM "publish --access public --loglevel verbose"
}