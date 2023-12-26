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
          $testResult=Path-Combine $PROJECT.artifacts, "nunit", "$(Path-GetFileNameWithoutExtension $csproj).$targetFw.$variant.xml"       
          $testCmd="test $csproj --configuration:Debug --framework:$targetFw --test-adapter-path:. --logger:nunit;LogFilePath=$testResult -property:variant=$variant"

          if (!$targetFw.StartsWith('net4')) {
            $testCmd += " -property:CustomBeforeMicrosoftCSharpTargets=$('ExcludeFromCoverage.targets' | Resolve-Path)"
            $coverageResult=Path-Combine $PROJECT.artifacts, "coverage_$targetFw.$variant.xml"

            Exec $coverageTool -commandArgs "collect --output-format xml --output `"$coverageResult`" `"dotnet $testCmd`""

            Exec $coverageTool -commandArgs "merge --output-format xml --output `"$(Path-Combine $PROJECT.artifacts, 'dynamiccodecoverage.xml')`" --remove-input-files `"$coverageResult`""
          } else {
            # In .NET FW, ExcludeFromCodeCoverageAttribute cannot be placed on assemblies
            Exec 'dotnet' -commandArgs $testCmd
          }
        }
      }
    }
  }
}