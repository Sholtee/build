#
# common.ps1
#
# Author: Denes Solti
#
$ErrorActionPreference = "Stop"

function Create-Directory([Parameter(Position = 0)][string[]] $path) {
  if (!(Test-Path $path)) {
    New-Item -path $path -force -itemType "Directory" | Out-Null
  }
}

function Remove-Directory([Parameter(Position = 0)][string[]] $path) {
  if (Test-Path $path) {
    Remove-Item -path $path -force -recurse | Out-Null
  }
}

function Path-Combine([Parameter(Position = 0)][string[]] $path) {
  return [System.IO.Path]::Combine($path)
}

function Path-Add-Slash([Parameter(Position = 0)][string] $path) {
  $sep=[System.IO.Path]::DirectorySeparatorChar
  if ($path -NotMatch "\$($sep)$") { $path += $sep } 
  return $path
}

function Move-Directory([Parameter(Position = 0)][string] $src, [Parameter(Position = 1)][string] $dst, [switch] $clearDst) {
  $src=Path-Add-Slash $src

  if (!(Test-Path $src)) {
    throw "`"$($src)`" could not be found"
  }
  
  $dst=Path-Add-Slash $dst
  
  if ($clearDst) {
    Remove-Directory (Path-Combine $dst, (Directory-Name $src))
  }
  
  Move-Item -path $src -destination $dst -force | Out-Null
}

function Directory-Path([Parameter(Position = 0)][string] $path) {
  return [System.IO.Path]::GetDirectoryName($path)
}

function Directory-Name([Parameter(Position = 0)][string] $path) {
  return  (New-Object System.IO.DirectoryInfo -ArgumentList (Directory-Path $path)).Name
}

function Directory-Of([Parameter(Position = 0)][string] $filename) {
  $path=Path-Combine (Get-Location), $filename
  
  try {
    if (Test-Path $path) {
      return Directory-Path $path | Resolve-Path
    }
	
    return Directory-Of "$(Path-Combine '..', $filename)"
  } catch {
  }    
}

function FileName-Without-Extension([Parameter(Position = 0)][string]$filename) {
  return [System.IO.Path]::GetFileNameWithoutExtension($filename)
}

function Is-NullOrEmpty([Parameter(Position = 0)][string]$string) { return [System.String]::IsNullOrEmpty($string) }

function Write-Log([Parameter(ValueFromPipeline)][string]$text, [Parameter(Position = 0)][string]$filename) {
  if (!(Is-NullOrEmpty $text)) {
    Create-Directory $PROJECT.artifacts
    $text | Out-File (Path-Combine $PROJECT.artifacts, $filename) -Force -Append
  }
}

function Attach-ToProcess([Parameter(Position = 0)][System.Diagnostics.Process]$process, [Parameter(Position = 1)][string]$eventName) {
  $sb = New-Object System.Text.StringBuilder
  return New-Object -TypeName PSObject -Property @{
    Output = $sb
    Job = Register-ObjectEvent -InputObject $process -EventName $eventName -MessageData $sb -Action { 
      if (!(Is-NullOrEmpty $EventArgs.Data)) { 
        $Event.MessageData.AppendLine($EventArgs.Data) | Out-Null 
      } 
    }
  }
}

function Exec([Parameter(Position = 0)][string]$command, [string]$commandArgs = $null, [switch]$redirectOutput, [switch]$noLog, [switch]$ignoreError) {
  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.FileName = $command
  $startInfo.Arguments = $commandArgs
  $startInfo.UseShellExecute = $false
  $startInfo.RedirectStandardOutput = ($redirectOutput -Or !$noLog)
  $startInfo.RedirectStandardError = !$noLog 
  $startInfo.WorkingDirectory = Get-Location

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $startInfo

  $stdOut = Attach-ToProcess $process -EventName OutputDataReceived
  $stdErr = Attach-ToProcess $process -EventName ErrorDataReceived

  $process.Start() | Out-Null

  if ($startInfo.RedirectStandardOutput) { $process.BeginOutputReadLine() } 
  if ($startInfo.RedirectStandardError) { $process.BeginErrorReadLine() }

  $finished = $false

  try {
    while (!$process.WaitForExit(100)) {
      # Non-blocking loop is done to allow ctr-c interrupts
    }

    $finished = $true
  } finally {
    if (!$finished) { $process.Kill() }
  }

  # Flush outputs
  $stdOut.Job.StopJob()
  $stdErr.Job.StopJob()

  if (!$noLog) {
    $fmt = "{0}:{1}{{0}}{1}" -F $command, [System.Environment]::NewLine
    ($fmt -F $stdOut.Output.ToString()) | Write-Log -Filename "log.txt"
    ($fmt -F $stdErr.Output.ToString()) | Write-Log -Filename "errors.txt"
  }

  $exitCode = $process.ExitCode

  if ($exitCode -Ne 0) {
    if (!$ignoreError) { Exit $exitCode }
    return
  }

  if ($redirectOutput) { return $stdOut.ToString() }
}

function Get-SysInfo() {
  return New-Object -TypeName PSObject -Property @{
    WinVer = (Get-WmiObject Win32_OperatingSystem).Version
    PSVer = $PSVersionTable.PSVersion
    CoreVer = Get-CoreVer
  }
}

function Get-CoreVer() {
  return (dir (Get-Command dotnet).Path.Replace("dotnet.exe", "shared\Microsoft.NETCore.App")).Name.Split([System.Environment]::NewLine) | Where { $_ -Match "^\d+.\d+.\d+$" }
}

function Read-Project() {
  $json="project.json"
  $root=Directory-Of $json
  $hash=@{}

  (Get-Content (Path-Combine $root, $json) -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object {    
    if ($_.Value.StartsWith([System.IO.Path]::DirectorySeparatorChar)) {
      # Don't use Path-Combine here! It can't handle if a path-part starts with directory separator.
      $hash[$_.Name]=Join-Path $root $_.Value
    } else {
      $hash[$_.Name]=$_.Value
    }
  }
  
  [XML]$csproj= Get-Content $hash.app
  $hash.version=($csproj.Project.PropertyGroup.Version | Out-String).Trim()

  return New-Object -TypeName PSObject -Property $hash
}

Set-Variable PROJECT -Option Constant -Value (Read-Project)

$Env:CI = $PROJECT.CI