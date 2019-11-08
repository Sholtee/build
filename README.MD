# How to use

## Pre requirements
- Existing [GitHub](https://help.github.com/en/github/getting-started-with-github/create-a-repo ) repo
- A [submodule](https://gist.github.com/gitaarik/8735255 ) in your main repo containing [this](https://github.com/Sholtee/build ) repository (e.g. in "scripts" folder)
- An [AppVeyor](https://www.appveyor.com ) account [set](https://www.appveyor.com/docs/ ) up for your repo
- A [Coveralls](https://coveralls.io ) account [set](https://docs.coveralls.io ) up for your repo
- A [NuGet](https://www.nuget.org ) account for your project

## Access tokens
To work properly you need to create some access token and [secure](https://ci.appveyor.com/tools/encrypt ) them:
- [GitHub](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line ): only the **repo** scope required
- A Coveralls `repo_token` (you get it during the repo registration)
- A [NuGet](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package ) API key
In the followings you MUST use the **SECURED** values of the tokens above