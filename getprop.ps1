#
# getprop.ps1
#
# Author: Denes Solti
#

$sdks = dotnet --list-sdks
$latestSDK = (
	$sdks.Split([System.Environment]::NewLine) `
		| Sort-Object `
		| Select-Object @{
			Name = "Match";
			Expression = { [System.Text.RegularExpressions.Regex]::Match($_, "(\d+\.\d+\.\d+) \[(.*)\]") }
		} `
		| Where-Object {$_.Match.Success} `
		| Select-Object @{
		    Name = "Value";
		    Expression = { Join-Path $_.Match.Groups[2].Value $_.Match.Groups[1].Value }
		} -Last 1
).Value

$msbuild = Join-Path $latestSDK "Microsoft.Build.dll"

#Write-Host MSBuild DLL to be loaded: $msbuild

Add-Type -AssemblyName $msbuild

function Get-Prop([Parameter(Position = 0, Mandatory = $true)][string] $csproj, [Parameter(Position = 1, Mandatory = $true)][string] $property, [Parameter(Position = 2)][hashtable] $globalProperties = @{}) {
  $dict = New-Object "System.Collections.Generic.Dictionary[String,String]"  
  
  $globalProperties.GetEnumerator() | ForEach-Object {
    $dict.Add($_.Name, $_.Value)
  }
  
  $proj = New-Object -TypeName Microsoft.Build.Evaluation.Project -ArgumentList $csproj, $dict, "Current"

  return $proj.GetPropertyValue($property)
}