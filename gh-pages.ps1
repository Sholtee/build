#
# gh-pages.ps1
#
# Author: Denes Solti
#
function GH-Pages() {
  $DOC_FOLDER="doc"
  $PERF_FOLDER="perf"

  Write-Host Preparing DOCS repo...

  $repodir=Path-Combine (Directory-Path $PROJECT.solution | Resolve-Path), $PROJECT.docsbranch
  Remove-Directory $repodir

  try {
    Exec "git.exe" -commandArgs "clone $($PROJECT.repo) --branch `"$($PROJECT.docsbranch)`" `"$repodir`""
    $repodir=Resolve-Path $repodir

    function BuildNMove([string]$projectDir, [string]$docsOutput) {
      DocFx "$(Path-Combine $projectDir, 'docfx.json')"
      Write-Host "Moving docs..."
      Move-Directory $docsOutput $repodir -clearDst	
    }

    $updateAPI=!(Path-Combine $PROJECT.artifacts, "BenchmarkDotNet.Artifacts" | Test-Path)

    if ($updateAPI) {
      Write-Host Building API docs...
      BuildNMove -projectDir (Directory-Path $PROJECT.app) -docsOutput (Path-Combine $PROJECT.artifacts, $DOC_FOLDER)
    } else {
      Write-Host Building benchmark docs...
      BuildNMove -projectDir (Directory-Path $PROJECT.perftests) -docsOutput (Path-Combine $PROJECT.artifacts, "BenchmarkDotNet.Artifacts", $PERF_FOLDER)
    }

    function Commit([Parameter(Position = 0)][string]$path, [string]$message) {
      Write-Host Committing changes...
      $oldLocation=Get-Location
      Set-Location -path $repodir
      try {
        Exec "git.exe" -commandArgs "add `"$($path)`"" -ignoreError
        Exec "git.exe" -commandArgs "commit -m `"$($message)`"" -ignoreError
        Exec "git.exe" -commandArgs "push origin $($PROJECT.docsbranch)"
      } finally {
        Set-Location -path $oldLocation	  
      }	  
    }

    if ($updateAPI) {
      Commit $DOC_FOLDER -message "docs up"
    } else {
      Commit $PERF_FOLDER -message "benchmarks up"	
    }	
  } finally {
    Remove-Directory $repodir
  }
}