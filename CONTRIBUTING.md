How to contribute to RealUI
---------------------------

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

* Include screenshots and animated GIFs in your pull request whenever possible.
* Follow the [Lua](#lua-styleguide) and [Git](#git-commit-messages) styleguides.
* Modifying non-RealUI addons is considered as a last resort; however, if it is necessary all modifications should be clearly marked.
* Pull requests must pass luacheck in order to be considered for acceptance.

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
