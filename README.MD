# How to use

## Pre requirements
- Existing [GitHub](https://help.github.com/en/github/getting-started-with-github/create-a-repo ) repo
- A [submodule](https://gist.github.com/gitaarik/8735255 ) in your main repo containing [this](https://github.com/Sholtee/build ) repository (e.g. in "scripts" folder)
- Enabled [GitHub pages](https://guides.github.com/features/pages/ ) using [gh-pages](https://help.github.com/en/github/working-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site ) branch
- An [AppVeyor](https://www.appveyor.com ) account [set](https://www.appveyor.com/docs/ ) up for your repo
- A [Coveralls](https://coveralls.io ) account [set](https://docs.coveralls.io ) up for your repo
- A [NuGet](https://www.nuget.org ) account for your project

## Access tokens
To work properly you need to create some access tokens and [secure](https://ci.appveyor.com/tools/encrypt ) them:
- [GitHub](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line ): only the **repo** scope required
- A Coveralls `repo_token` (you get it during the repo registration)
- A [NuGet](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package ) API key

In the followings you MUST use the **SECURED** values of the tokens above

## Setup your project
- Create the `appveyor.yml` file in your project root from the [template](https://github.com/Sholtee/build/blob/master/templates/appveyor.yml ). You should modify only the values of the environment variables (marked with `xXx` in the sample).
- Create the `project.json` file in your project root from the [template](https://github.com/Sholtee/build/blob/master/templates/project.json ). Your project should consist of an `app` project, a `tests` project and a `perftests` project.
- Add/merge the followings to the `csproj` of your project (under the `Project` node):
  ```xml
  <PropertyGroup>
    <TargetFrameworks>netstandard1.6;netstandard2.0;netstandard2.1</TargetFrameworks>
    <Company>Your Company</Company>
    <Authors>Your Name</Authors>
    <Version>1.0.0-preview1</Version>
    <AssemblyName>YourProject</AssemblyName>
  </PropertyGroup>

  <ItemGroup>
    <None Remove="docfx.json" />
    <None Remove="index.md" />
    <None Include="path\to\icon.png" Pack="true" PackagePath=""/>
  </ItemGroup>
  
  <PropertyGroup>
    <DocumentationFile>..\BIN\YourProject.xml</DocumentationFile>
    <Product>...</Product>  
    <Description>...</Description>
    <PackageId>...</PackageId>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageIcon>icon.png</PackageIcon>
    <PackageTags>...;...;...;</PackageTags>
    <PackageReleaseNotes>See homepage.</PackageReleaseNotes>
  </PropertyGroup>  
  ```
- Copy the [docfx.json](https://github.com/Sholtee/build/blob/master/templates/API/docfx.json ) and [index.md](https://raw.githubusercontent.com/Sholtee/build/master/templates/API/index.md ) to the source folder of your project (`SRC` by default). In `docfx.json` modify `csproj` name and title, in `index.md` modify the URLs.  
- Add/merge the followings to the `csproj` of your test project (under the `Project` node):
  ```xml
  <PropertyGroup>
    <TargetFrameworks>net5.0</TargetFrameworks>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
    <AssemblyName>YourProject.Tests</AssemblyName>
    <RootNamespace>YourProject.Tests</RootNamespace>
    <Configurations>Debug</Configurations>
    <OutputType>Library</OutputType>
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="nunit" Version="3.*" />
    <PackageReference Include="NUnit3TestAdapter" Version="3.*" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="16.*" />
    <PackageReference Include="NunitXml.TestLogger" Version="3.*" />
  </ItemGroup> 
  ```
- Add/merge the followings to the `csproj` of your benchmark project (under the `Project` node):
  ```xml
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <IsPackable>false</IsPackable>
    <TargetFramework>net5.0</TargetFramework>
    <AssemblyName>YourProject.Perf</AssemblyName>
  </PropertyGroup>
  
  <ItemGroup>
    <None Remove="docfx.json" />
    <None Remove="index.md" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="BenchmarkDotNet" Version="0.12.*" />
    <PackageReference Condition="'$(LibVersion)' != ''" Include="YourProjectId" Version="$(LibVersion)"></PackageReference>
  </ItemGroup>
  
  <ItemGroup>
    <ProjectReference Condition="'$(LibVersion)' == ''" Include="..\SRC\YourProject.csproj" />
  </ItemGroup>
  ```
- Copy the [docfx.json](https://github.com/Sholtee/build/blob/master/templates/PERF/docfx.json ) and [index.md](https://raw.githubusercontent.com/Sholtee/build/master/templates/PERF/index.md ) to the source folder of your benchmark project (`PERF` by default). In `index.md` modify the URLs.
- [GitIgnore](https://git-scm.com/docs/gitignore ) the `Artifacts` folder in your project root.
- GitIgnore `manifest.json` on your `gh-pages` branch.
- Create an `index.html` on your `gh-pages` branch:
  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="Refresh" content="0; url=https://YourName.github.io/YourProject/doc/">
    </head>
  </html>  
  ```
- Create a project icon (named `icon.png`) in your project root.
## Artifacts
Will be placed on your `gh-pages` branch under the `doc` and `perf` folder
## Add status badges (to your README.MD)
- [AppVeyor](https://www.appveyor.com/docs/status-badges/ )
- [NuGet](https://buildstats.info/ )
- Coveralls
## Using
- Regular tests are done on every branch on every commit
- Performance tests are done on `perf` tag but results are publishd only if the tag was placed on a `master` branch commit
- API docs are updated and publishd on every `master` branch commit
- NuGet package is deployed on version tags (e.g. `v1.0.0-preview1`) placed on a `master` branch commit