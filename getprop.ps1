#
# getprop.ps1
#
# Author: Denes Solti
#

if ( $PSVersionTable.PSVersion -lt [Version] "6.0") {
  function Get-Prop([Parameter(Position = 0, Mandatory = $true)][string] $csproj, [Parameter(Position = 1, Mandatory = $true)][string] $property, [Parameter(Position = 2)][hashtable] $globalProperties = @{}) {
    $command =  "& { . $(Join-Path $PSScriptRoot 'getprop.ps1'); Get-Prop -CSProj '$csproj' -Property $property -GlobalProperties @{"
    $globalProperties.GetEnumerator() | ForEach-Object {
      $command += "'$($_.Name)' = '$($_.Value)';"
    }
    $command += "} }"

    $result = pwsh -Command $command
	return $result
  }
} else {
  $sdks = dotnet --list-sdks
  $latestSDK = (
    $sdks.Split([System.Environment]::NewLine) `
	  | Sort-Object `
	  | Select-Object @{
	    Name = "Match";
	    Expression = { [System.Text.RegularExpressions.Regex]::Match($_, "^((?:6|7)\.\d+\.\d+) \[(.*)\]$") }
	  } `
	  | Where-Object {$_.Match.Success} `
	  | Select-Object @{
        Name = "Value";
        Expression = { Join-Path $_.Match.Groups[2].Value $_.Match.Groups[1].Value }
	  } -Last 1
  ).Value
  if ($latestSDK -eq $NULL) {
	Write-Error ".NET SDK cannot be found"
    Exit
  }
  $msbuild = Join-Path $latestSDK "Microsoft.Build.dll"

  #Write-Host MSBuild DLL to be loaded: $msbuild

  Add-Type -AssemblyName $msbuild

  function Get-Prop([Parameter(Position = 0, Mandatory = $true)][string] $csproj, [Parameter(Position = 1, Mandatory = $true)][string] $property, [Parameter(Position = 2)][hashtable] $globalProperties = @{}) {
    $dict = New-Object -TypeName "System.Collections.Generic.Dictionary[String,String]" 
  
    $globalProperties.GetEnumerator() | ForEach-Object {
      $dict.Add($_.Name, $_.Value)
    }
  
    $proj = New-Object -TypeName "Microsoft.Build.Evaluation.Project" -ArgumentList $csproj, $dict, "Current"

    return $proj.GetPropertyValue($property)
  }
}