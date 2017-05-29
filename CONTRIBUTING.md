How to contribute to RealUI
---------------------------

## Localization ##

If you know a language other than English, this is the easiest way to contribute. There is a [localization project](https://wow.curseforge.com/projects/realui-localization/localization) on Curse where you can easily see what phrases need translation or review.

## Bug Reports ##

Before you report a bug, [follow these steps](http://www.wowinterface.com/forums/showthread.php?t=500891) first. In addition to checking the forums, also check the [issue tracker](https://github.com/RealUI/RealUI/issues) here on GitHub, to ensure that there isn't an existing issue reported.

### Submitting A (Good) Bug Report ###
Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem. You can use [this tool](http://www.cockos.com/licecap/) to record GIFs on OSX and Windows.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Provide more context by answering these questions:

* **Which version of RealUI are you using?** You can get the exact version by opening the advanced options with `/realadv`, and looking at the header.
* **Did the problem start happening recently** (e.g. after updating to a new version of RealUI) or was this always a problem?
* If the problem started happening recently, **can you reproduce the problem in an older version of RealUI?** What's the most recent version in which the problem doesn't happen? You can download older versions of RealUI from [the releases page](https://github.com/RealUI/RealUI/releases).
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.
* **What addons _not_ included in RealUI do you have installed?**.


## Pull Requests ##

If you would like to contribute code, a [pull request](https://help.github.com/articles/about-pull-requests/) is the best way to do so. When submitting a pull request, please adhere to the following guidelines.

  * Make a short but descriptive name.
  * Have a detailed description of what your PR provides and/or what it's trying to solve.
  * Include screenshots and animated GIFs in your pull request whenever applicable.
  * Code and commits must follow the [Lua](#lua-styleguide) and [Git](#git-commit-messages) styleguides respectively.
  * Pull requests must pass luacheck in order to be considered for acceptance.

### Getting Started ###

Given the file structure of this project, it's recommended to setup symbolic links between the addons in the repo and your AddOns folder for the game. To facilitate this, [a script is available](https://gist.github.com/Gethe/aa3325ed88b2a92d23ec276c7383e034) to perform this setup. Be sure to update the file path to suit your own install directories. The script was written in Powershell, but it should be fairly simple to convert into another language if desired.

Most of the libraries used are not included in the repo since they will get brought in when a new release is packaged. These libraries will need to be installed separately to ensure RealUI works properly. All of these are available via Curse.
  
  * [Ace3](https://mods.curse.com/addons/wow/ace3)
  * [AceGUI-3.0-SharedMediaWidets](https://mods.curse.com/addons/wow/ace-gui-3-0-shared-media-widgets)
  * [HereBeDragons-1.0](https://mods.curse.com/addons/wow/herebedragons)
  * [LibArtifactData-1.0](https://mods.curse.com/addons/wow/libartifactdata-1-0)
  * [LibChatAnims](https://mods.curse.com/addons/wow/libchatanims)
  * [LibInspect](https://mods.curse.com/addons/wow/libinspect)
  * [LibItemUpgradeInfo-1.0](https://mods.curse.com/addons/wow/libitemupgradeinfo-1-0)
  * [LibQTip-1.0](https://mods.curse.com/addons/wow/libqtip-1-0)
  * [LibRangeCheck-2.0](https://mods.curse.com/addons/wow/librangecheck-2-0)
  * [LibSharedMedia-3.0](https://mods.curse.com/addons/wow/libsharedmedia-3-0)
  * [LibStrataFix](https://mods.curse.com/addons/wow/libstratafix)
  * [LibWindow-1.1](https://mods.curse.com/addons/wow/libwindow-1-1)
  * [UTF8](https://mods.curse.com/addons/wow/utf8)


## Packaging ##

RealUI uses a [customized fork of the BigWigsMods packager.](https://github.com/RealUI/packager/tree/RealUI_edits) This is a shell script that can be run on Windows 10 if [WSL is installed](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide), in addition to Linux or Mac. In order for this script to run properly you must have the following commands available:

  * [git](http://packages.ubuntu.com/xenial/git) and [svn](http://packages.ubuntu.com/xenial/subversion) - to retrieve externals
  * [pandoc](http://packages.ubuntu.com/xenial/pandoc) - to create a bbcode changelog for WoWI
  * [zip and unzip](http://packages.ubuntu.com/xenial/zip) - to unpack externals and create final package
  * [jq](http://packages.ubuntu.com/xenial/jq) - to upload the package to WoWI and create a GitHub release

**Note:** While this script *can* be run locally, it's not necessary to do so as the script will be run as part of the Travis CI build. That said, a `package.bat` file is available for testing purposes.


## Styleguides ##

### Git Commit Messages ###

Commit messages should follow [these guidelines](http://chris.beams.io/posts/git-commit/).

1. [Separate subject from body with a blank line](http://chris.beams.io/posts/git-commit/#separate)
2. [Limit the subject line to 50 characters](http://chris.beams.io/posts/git-commit/#limit-50)
3. [Capitalize the subject line](http://chris.beams.io/posts/git-commit/#capitalize)
4. [Do not end the subject line with a period](http://chris.beams.io/posts/git-commit/#end)
5. [Use the imperative mood in the subject line](http://chris.beams.io/posts/git-commit/#imperative)
6. [Wrap the body at 72 characters](http://chris.beams.io/posts/git-commit/#wrap-72)
7. [Use the body to explain what and why vs. how](http://chris.beams.io/posts/git-commit/#why-not-how)

### Lua Styleguide ###

#### Whitespace ###

* Use four spaces when indenting code blocks
* Use spaces around operators
    * `a = 1` instead of `a=1`
* Use spaces after commas (unless separated by newlines)
* Do not use spaces at the beginning and end of a table declaration.
    * `{a = 1, b = 2}` instead of `{ a = 1, b = 2 }`
* End a file with a new line

### Variables ###

* Use locals instead of globals whenever possible
* Variable names should generally use [lowerCamelCase](https://en.wikipedia.org/wiki/CamelCase), though functions should be UpperCamelCase.
* Capitalize initial-isms and acronyms, unless it's the first word, which should be lower-case:
    * function: `GetUIScale` instead of `getUiScale`
    * variable: `uiScale` instead of `UiScale`
* If a variable in not expected to change (eg. a constant), consider using `ALL_CAPS` with an underscore separating each word.
