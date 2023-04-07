How to contribute to RealUI
---------------------------

## Localization ##

If you know a language other than English, this is the easiest way to contribute. There is a [localization project](https://wow.curseforge.com/projects/realui-localization/localization) on Curse where you can easily see what phrases need translation or review.

## Bug Reports and Feature Requests ##

Before you report a bug, [follow these steps](http://www.wowinterface.com/forums/showthread.php?t=500891) first. In addition to checking the forums, also check the [issue tracker](https://github.com/RealUI/RealUI/issues) here on GitHub, to ensure that there isn't an existing issue reported.

### Submitting A Bug Report ###
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

If you would like to contribute code, a [pull request](https://help.github.com/articles/about-pull-requests/) is the best way to do so. Check out [the wiki](https://github.com/RealUI/RealUI/wiki/Dev-Environment-Setup) on how to set up a development environment.

Before making any code changes, create a new topic branch (based on the `main` branch) to contain your feature, change, or fix.

``` bash
git checkout -b my-topic-branch
```

In your new topic branch, make your code changes and prepare a commit. Be sure to review the [code standards](https://github.com/RealUI/RealUI/wiki/Styleguide-reference) before you commit and push the changes to your fork.

``` bash
git commit -a -m "commit-description"
git push
```

When [submitting a pull request](https://github.com/RealUI/RealUI/pulls), please adhere to the following guidelines.

  * Make a short but descriptive name.
  * Have a detailed description of what your PR provides and/or what it's trying to solve.
  * Include screenshots and/or animated GIFs in your pull request whenever applicable.
  * Pull requests must pass luacheck in order to be considered for acceptance.

### Keeping your fork updated

When contributing to a project that other people are also contributing to, it's important to keep your fork updated to ensure you're working with the latest code. You can specify a new remote upstream repository that will be used to sync your fork (you only need to do this once).

``` bash
git remote add upstream https://github.com/RealUI/RealUI.git
```

Then you can sync your fork with the upstream repository with the following commands.

``` bash
git fetch upstream
git checkout main
git rebase upstream/main
```

### Keeping your pull request updated

If you have a topic branch that already has code changes, you can updated it with a `rebase`. This will sync your pull request with the upstream RealUI repository in case there have been changes to the same files.

```bash
git fetch upstream
git checkout my-topic-branch
git rebase upstream/main
```

If there are any conflicts, you will now have to [fix them manually](https://help.github.com/articles/resolving-merge-conflicts-after-a-git-rebase/). When you're done with that, you can force-push your changes back to your fork.

```bash
git push --force
```

**Note**: Force-pushing is a destructive operation, so make sure you don't lose something in the progress. If you want to know more about force-pushing and why it's done, there are a two good posts about it: one by [Atlassian](https://www.atlassian.com/git/tutorials/merging-vs-rebasing#the-golden-rule-of-rebasing) and one on [Reddit](https://www.reddit.com/r/git/comments/6jzogp/why_am_i_force_pushing_after_a_rebase/).
