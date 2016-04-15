local LIF = LibStub("LibIconFonts-1.0", true)
print("octicons")

-- Preview available at octicons.github.com
local function octicons(version)
    local font = {
        ["alert"] = "", -- f02d
        ["arrow-down"] = "", -- f03f
        ["arrow-left"] = "", -- f040
        ["arrow-right"] = "", -- f03e
        ["arrow-small-down"] = "", -- f0a0
        ["arrow-small-left"] = "", -- f0a1
        ["arrow-small-right"] = "", -- f071
        ["arrow-small-up"] = "", -- f09f
        ["arrow-up"] = "", -- f03d
        ["book"] = "", -- f007
        ["bookmark"] = "", -- f07b
        ["briefcase"] = "", -- f0d3
        ["broadcast"] = "", -- f048
        ["browser"] = "", -- f0c5
        ["bug"] = "", -- f091
        ["calendar"] = "", -- f068
        ["check"] = "", -- f03a
        ["checklist"] = "", -- f076
        ["chevron-down"] = "", -- f0a3
        ["chevron-left"] = "", -- f0a4
        ["chevron-right"] = "", -- f078
        ["chevron-up"] = "", -- f0a2
        ["circle-slash"] = "", -- f084
        ["circuit-board"] = "", -- f0d6
        ["clippy"] = "", -- f035
        ["clock"] = "", -- f046
        ["cloud-download"] = "", -- f00b
        ["cloud-upload"] = "", -- f00c
        ["code"] = "", -- f05f
        ["color-mode"] = "", -- f065  Removed in 3.4
        ["comment"] = "", -- f02b
        ["comment-discussion"] = "", -- f04f
        ["credit-card"] = "", -- f045
        ["dash"] = "", -- f0ca
        ["dashboard"] = "", -- f07d
        ["database"] = "", -- f096
        ["device-camera"] = "", -- f056
        ["device-camera-video"] = "", -- f057
        ["device-desktop"] = "", -- f27c
        ["device-mobile"] = "", -- f038
        ["diff"] = "", -- f04d
        ["diff-added"] = "", -- f06b
        ["diff-ignored"] = "", -- f099
        ["diff-modified"] = "", -- f06d
        ["diff-removed"] = "", -- f06c
        ["diff-renamed"] = "", -- f06e
        ["ellipsis"] = "", -- f09a
        ["eye"] = "", -- f04e
        ["file-binary"] = "", -- f094
        ["file-code"] = "", -- f010
        ["file-directory"] = "", -- f016
        ["file-media"] = "", -- f012
        ["file-pdf"] = "", -- f014
        ["file-submodule"] = "", -- f017
        ["file-symlink-directory"] = "", -- f0b1
        ["file-symlink-file"] = "", -- f0b0
        ["file-text"] = "", -- f011
        ["file-zip"] = "", -- f013
        ["flame"] = "", -- f0d2
        ["fold"] = "", -- f0cc
        ["gear"] = "", -- f02f
        ["gift"] = "", -- f042
        ["gist"] = "", -- f00e
        ["gist-secret"] = "", -- f08c
        ["git-branch"] = "", -- f020
        ["git-commit"] = "", -- f01f
        ["git-compare"] = "", -- f0ac
        ["git-merge"] = "", -- f023
        ["git-pull-request"] = "", -- f009
        ["globe"] = "", -- f0b6
        ["graph"] = "", -- f043
        ["heart"] = "♥", -- 2665
        ["history"] = "", -- f07e
        ["home"] = "", -- f08d
        ["horizontal-rule"] = "", -- f070
        ["hubot"] = "", -- f09d
        ["inbox"] = "", -- f0cf
        ["info"] = "", -- f059
        ["issue-closed"] = "", -- f028
        ["issue-opened"] = "", -- f026
        ["issue-reopened"] = "", -- f027
        ["jersey"] = "", -- f019
        ["key"] = "", -- f049
        ["keyboard"] = "", -- f00d
        ["law"] = "", -- f0d8
        ["light-bulb"] = "", -- f000
        ["link"] = "", -- f05c
        ["link-external"] = "", -- f07f
        ["list-ordered"] = "", -- f062
        ["list-unordered"] = "", -- f061
        ["location"] = "", -- f060
        ["lock"] = "", -- f06a
        ["logo-github"] = "", -- f092
        ["mail"] = "", -- f03b
        ["mail-read"] = "", -- f03c
        ["mail-reply"] = "", -- f051
        ["mark-github"] = "", -- f00a
        ["markdown"] = "", -- f0c9
        ["megaphone"] = "", -- f077
        ["mention"] = "", -- f0be
        ["milestone"] = "", -- f075
        ["mirror"] = "", -- f024
        ["mortar-board"] = "", -- f0d7
        ["mute"] = "", -- f080
        ["no-newline"] = "", -- f09c
        ["octoface"] = "", -- f008
        ["organization"] = "", -- f037
        ["package"] = "", -- f0c4
        ["paintcan"] = "", -- f0d1
        ["pencil"] = "", -- f058
        ["person"] = "", -- f018
        ["pin"] = "", -- f041
        ["plug"] = "", -- f0d4
        ["plus"] = "", -- f05d
        ["primitive-dot"] = "", -- f052
        ["primitive-square"] = "", -- f053
        ["pulse"] = "", -- f085
        ["question"] = "", -- f02c
        ["quote"] = "", -- f063
        ["radio-tower"] = "", -- f030
        ["repo"] = "", -- f001
        ["repo-clone"] = "", -- f04c
        ["repo-force-push"] = "", -- f04a
        ["repo-forked"] = "", -- f002
        ["repo-pull"] = "", -- f006
        ["repo-push"] = "", -- f005
        ["rocket"] = "", -- f033
        ["rss"] = "", -- f034
        ["ruby"] = "", -- f047
        ["screen-full"] = "", -- f066  Removed in 3.2
        ["screen-normal"] = "", -- f067  Removed in 3.2
        ["search"] = "", -- f02e
        ["server"] = "", -- f097
        ["settings"] = "", -- f07c
        ["sign-in"] = "", -- f036
        ["sign-out"] = "", -- f032
        ["squirrel"] = "", -- f0b2
        ["star"] = "", -- f02a
        ["stop"] = "", -- f08f
        ["sync"] = "", -- f087
        ["tag"] = "", -- f015
        ["telescope"] = "", -- f088
        ["terminal"] = "", -- f0c8
        ["three-bars"] = "", -- f05e
        ["thumbsdown"] = "", -- f0db
        ["thumbsup"] = "", -- f0da
        ["tools"] = "", -- f031
        ["trashcan"] = "", -- f0d0
        ["triangle-down"] = "", -- f05b
        ["triangle-left"] = "", -- f044
        ["triangle-right"] = "", -- f05a
        ["triangle-up"] = "", -- f0aa
        ["unfold"] = "", -- f039
        ["unmute"] = "", -- f0ba
        ["versions"] = "", -- f064
        ["x"] = "", -- f081
        ["zap"] = "⚡", -- 26A1
    }

    -- Aliases
    font["comment-add"] = font["comment"]
    font["eye-unwatch"] = font["eye"]
    font["eye-watch"] = font["eye"]
    font["git-branch-create"] = font["git-branch"]
    font["git-branch-delete"] = font["git-branch"]
    font["git-pull-request-abandoned"] = font["git-pull-request"]
    font["gist-private"] = font["lock"]
    font["mirror-private"] = font["lock"]
    font["git-fork-private"] = font["lock"]
    font["mirror-public"] = font["mirror"]
    font["person-add"] = font["person"]
    font["person-follow"] = font["person"]
    font["repo-create"] = font["plus"]
    font["gist-new"] = font["plus"]
    font["file-directory-create"] = font["plus"]
    font["file-add"] = font["plus"]
    font["repo-delete"] = font["repo"]
    font["gist-fork"] = font["repo-forked"]
    font["search-save"] = font["search"]
    font["log-in"] = font["sign-in"]
    font["log-out"] = font["sign-out"]
    font["star-add"] = font["star"]
    font["star-delete"] = font["star"]
    font["repo-sync"] = font["sync"]
    font["tag-remove"] = font["tag"]
    font["tag-add"] = font["tag"]
    font["remove-close"] = font["x"]


    if version == "v3.x" then
        font["beaker"] = "" -- f0dd
        font["bell"] = "" -- f0de
        font["desktop-download"] = "" -- f0dc
        font["watch"] = "" -- f0e0

        font["microscope"] = font["beaker"]
        font["clone"] = font["desktop-download"]

        -- Added in 3.1
        font["shield"] = "" -- f0e1

        -- Added in 3.2
        font["bold"] = "" -- f0e2
        font["italic"] = "" -- f0e4
        font["tasklist"] = "" -- f0e5
        font["text-size"] = "" -- f0e3

        -- Added in 3.3
        font["logo-gist"] = "" -- f0ad

        -- Added in 3.4
        font["smiley"] = "" -- f0e7
        font["verified"] = "" -- f0e6

        -- Added in 3.5
        font["unverified"] = "" -- f0e8
    elseif version == "v2.4" then
        font["alignment-align"] = "" -- f08a
        font["alignment-aligned-to"] = "" -- f08e
        font["alignment-unalign"] = "" -- f08b
        font["beer"] = "" -- f069
        font["hourglass"] = "" -- f09e
        font["jump-down"] = "" -- f072
        font["jump-left"] = "" -- f0a5
        font["jump-right"] = "" -- f0a6
        font["jump-up"] = "" -- f073
        font["microscope"] = "" -- f089
        font["move-down"] = "" -- f0a8
        font["move-left"] = "" -- f074
        font["move-right"] = "" -- f0a9
        font["move-up"] = "" -- f0a7
        font["playback-fast-forward"] = "" -- f0bd
        font["playback-pause"] = "" -- f0bb
        font["playback-play"] = "" -- f0bf
        font["playback-rewind"] = "" -- f0bc
        font["podium"] = "" -- f0af
        font["puzzle"] = "" -- f0c0
        font["split"] = "" -- f0c6
        font["steps"] = "" -- f0c7
    end

    return font
end

LIF:RegisterIconFont("octicons", octicons, "v3.x", "v2.x")
