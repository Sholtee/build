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
- Create the `appveyor.yml` file in your project root from the [sample](https://github.com/Sholtee/build/blob/master/samples/appveyor.yml ). You should modify only the values of the environment variables (marked with `xXx` in the sample).
- Create the `project.json` file in your "scripts" folder from the [sample](https://github.com/Sholtee/build/blob/master/samples/project.json ). Your project should consist of an `app` project, a `tests` project and a `perftests` project.
- Add the followings to the `csproj` of your project (under the `Project` node):
  ```xml
  <ItemGroup>
    <None Remove="docfx.json" />
    <None Remove="index.md" />
  </ItemGroup>
  
  <PropertyGroup>
    <DocumentationFile>..\BIN\YourProject.xml</DocumentationFile>
    <Product>...</Product>  
    <Description>...</Description>
    <PackageId>...</PackageId>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageIconUrl>https://github.com/YourName/YourProject/raw/master/icon.png</PackageIconUrl>
    <PackageTags>...;...;...;</PackageTags>
    <PackageReleaseNotes>See homepage.</PackageReleaseNotes>
    <RepositoryType>git</RepositoryType>
    <RepositoryUrl>https://github.com/YourName/YourProject</RepositoryUrl>
    <RepositoryBranch>$(CurrentBranch)</RepositoryBranch>
  </PropertyGroup>  
  ```
- Copy the [docfx.json](https://github.com/Sholtee/build/blob/master/samples/API/docfx.json ) and [index.md](https://github.com/Sholtee/build/blob/master/samples/API/index.md ) to the source folder of your project (`SRC` by default). In `docfx.json` modify `csproj` name and title, in `index.md` modify the URLs.
- [GitIgnore](https://git-scm.com/docs/gitignore ) everything in your "scripts" folder except the project.json in the root (the submodule is responsible for keeping script files up to date).
- GitIgnore the `Artifacts` folder in your project root.
- Create a project icon (named `icon.png`) in your project root.

## Add status badges (to your README.MD)
- [AppVeyor](https://www.appveyor.com/docs/status-badges/ )
- [NuGet](https://buildstats.info/ )
- Coveralls
