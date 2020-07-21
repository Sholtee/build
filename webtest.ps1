#
# webtest.ps1
#
# Author: Denes Solti
#
function Web-Tests() {
  $npm = (Get-Command npm).Path

  Exec $npm -commandArgs "install" -cwd ($PROJECT.web | Resolve-Path)
  Exec $npm -commandArgs "test" -cwd $PROJECT.web
}