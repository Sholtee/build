#
# web.ps1
#
# Author: Denes Solti
#

function Invoke-NPM([Parameter(Position = 0, Mandatory = $true)][string] $arg) {
  if ($PROJECT.web is [string]) {
    Exec (Get-Command "npm").Path -commandArgs $arg -cwd ($PROJECT.web | Resolve-Path)
  }
}

function Web-Restore() { Invoke-NPM "install" }

function Web-Tests() { Invoke-NPM "test --loglevel verbose" }

function Web-PushResults() { Invoke-NPM "pushresults --loglevel verbose" }