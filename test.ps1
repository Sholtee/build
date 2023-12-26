#
# test.ps1
#
# Author: Denes Solti
#
function Regular-Tests() {
  Remove-Directory $PROJECT.artifacts
  Create-Directory $PROJECT.artifacts

  $coverageTool=Path-Combine (Get-Package "dotnet-coverage" -Version "17.9.6" -IsTool), "dotnet-coverage.exe" | Resolve-Path

  $PROJECT.variants | ForEach-Object {
    $variant=$_

    Get-ChildItem -Path (Path-Combine $PROJECT.root, $PROJECT.tests) | ForEach-Object {
      $csproj=$_

      # Run tests against each TFMs separately to get the results not merged
      (Get-Prop $csproj -Property "TargetFrameworks" -GlobalProperties @{"Variant" = $variant} | Out-String).Trim().Split(";") | ForEach-Object {
        $targetFw=$_

        if (!($PROJECT.skipon -Contains $targetFw)) {
          Exec 'dotnet' -commandArgs "build $csproj --configuration:Debug --framework:$targetFw -property:variant=$variant"
          
          $binFolder=Join-Path $PROJECT.bin $targetFw
          $filesToBeInstrumented=[string]::Join(',', ($PROJECT.coverage | Select-Object @{ Name = 'Value'; Expression = { "`"$(Join-Path $binFolder $_)`"" } } | Select-Object -ExpandProperty Value))

          $testResult=Path-Combine $PROJECT.artifacts, "nunit", "$(Path-GetFileNameWithoutExtension $csproj).$targetFw.$variant.xml"       
          $coverageResult=Path-Combine $PROJECT.artifacts, "coverage_$targetFw.$variant.xml"

          Exec $coverageTool -commandArgs "collect --include-files $filesToBeInstrumented --output-format xml --output `"$coverageResult`" `"dotnet test $csproj --no-build --no-restore --framework:$targetFw --test-adapter-path:. --logger:nunit;LogFilePath=$testResult`""
          Exec $coverageTool -commandArgs "merge --output-format xml --output `"$(Path-Combine $PROJECT.artifacts, 'dynamiccodecoverage.xml')`" --remove-input-files `"$coverageResult`""
        }
      }
    }
  }
}