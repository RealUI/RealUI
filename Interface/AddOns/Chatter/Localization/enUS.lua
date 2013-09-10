-- This file is script-generated and should not be manually edited.
-- Localizers may copy this file to edit as necessary.
local addon, private = ...
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(addon, "enUS", true)
if not L then return end

-- ./Chatter.lua
L["Chatter"] = true
L["Standalone Config"] = true
L["Open a standalone config window. You might consider installing |cffffff00BetterBlizzOptions|r to make the Blizzard UI options panel resizable."] = true
L["Configure"] = true
L["Modules"] = true
L["Settings"] = true
L["Enable "] = true
L["Module"] = true
L["Enabled"] = true
L["Disabled"] = true
L["Chatter Settings"] = true
L["Welcome to Chatter! Type /chatter to configure."] = true
L["Profiles"] = true

-- ./Modules/AllResize
L["Allows you to use the edge for resizing, instead of just the lower right corner."] = true
L["All Edge resizing"] = true

-- ./Modules/AltNames.lua
L["Alt Linking"] = true
L["Use PlayerNames coloring"] = true
L["Use custom color"] = true
L["Use channel color"] = true
L["Use guildnotes"] = true
L["Look in guildnotes for character names, unless a note is set manually"] = true
L["Alt note fallback"] = true
L["If no name can be found for an 'alt' rank character, use entire note"] = true
L["Name color"] = true
L["Set the coloring mode for alt names"] = true
L["Custom color"] = true
L["Select the custom color to use for alt names"] = true
L["Left Bracket"] = true
L["Character to use for the left bracket"] = true
L["Right Bracket"] = true
L["Character to use for the right bracket"] = true
L["Who is %s's main?"] = true
L["Set Main"] = true
L["Enables you to right-click a person's name in chat and set a note on them to be displayed in chat, such as their main character's name. Can also scan guild notes for character names to display, if no note has been manually set."] = true
L["Output"] = true
L["Guild Notes"] = true
L["Guild note prefix"] = true
L["Enter the starting character for guild note delimiters, or leave blank for none."] = true
L["Guild note suffix"] = true
L["Enter the ending character for guild note delimiters, or leave blank for none."] = true
L["Alt Ranks"] = true
L["Use notes as main character names for this rank."] = true

--./Modules/AutoPopup.lua
L["Automatic Whisper Windows"] = true

-- ./Modules/AutoLogChat.lua
L["Chat Autolog"] = true
L["Automatically turns on chat logging."] = true

--./Modules/Bnet.lua
L["RealID Polish"] = true
L["Show Toast Icons"] = true
L["Show toast icons in the chat frames"] = true
L["Toast X offset"] = true
L["Move the Toast X offset to ChatFrame1"] = true
L["Toast Y offset"] = true
L["Move the Toast Y offset, relative to ChatFrame1"] = true
L["Test"] = true

-- ./Modules/Buttons.lua
L["Disable Buttons"] = true
L["Show bottom when scrolled"] = true
L["Show bottom button when scrolled up"] = true
L["Hides the buttons attached to the chat frame"] = true

-- ./Modules/ChannelColors.lua
L["Channel Colors"] = true
L["Keeps your channel colors by name rather than by number."] = true
L["Other Channels"] = true
L["Say"] = true
L["Yell"] = true
L["Guild"] = true
L["Officer"] = true
L["Party"] = true
L["Party Leader"] = true
L["Raid"] = true
L["Raid Leader"] = true
L["Raid Warning"] = true
L["Battleground"] = true
L["Battleground Leader"] = true
L["Whisper"] = true
L["Select a color for this channel"] = true
L["Instance Leader"] = true
L["Instance"] = true
-- ./Modules/ChannelNames.lua
L["Channel Names"] = true
L["$$EMPTY$$"] = true
L["LookingForGroup"] = true
L["Custom Channels"] = true
L["Add space after channels"] = true
L["Replace this channel name with..."] = true
L["To (|Hplayer.-|h):"] = true
L["(|Hplayer.-|h) whispers:"] = true
L["Enables you to replace channel names with your own names. You can use '%s' to force an empty string."] = true
L["To (|HBNplayer.-|h):"] = true
L["To <Away>(|HBNplayer.-|h):"] = true
L["To <Busy>(|HBNplayer.-|h):"] = true
L["(|HBNplayer.-|h): whispers:"] = true
L["Dungeon Guide"] = true
-- ./Modules/ChatFading.lua
L["Disable Fading"] = true
L["Makes old text disappear rather than fade out"] = true

-- ./Modules/ChatFont.lua
L["Chat Font"] = true
L["Font"] = true
L["Font size"] = true
L["Font Outline"] = true
L["Font outlining"] = true
L["Chat Frame "] = true
L["Enables you to set a custom font and font size for your chat frames"] = true

-- ./Modules/ChatFrameBorders.lua
L["Borders/Background"] = true
L["Enable"] = true
L["Enable borders on this frame"] = true
L["Combat Log Fix"] = true
L["Resize this border to fit the new combat log"] = true
L["Background texture"] = true
L["Border texture"] = true
L["Background color"] = true
L["Border color"] = true
L["Background Inset"] = true
L["Tile Size"] = true
L["Edge Size"] = true
L["Gives you finer control over the chat frame's background and border colors"] = true

-- ./Modules/ChatLink.Lua
L["Chat Link"] = true
L["Lets you link items, enchants, spells, talents, achievements and quests in custom channels."] = true

-- ./Module/chatPosition.lua
L["Disable server side storage of chat frame position and size."] = true
L["Server Positioning"] = true
L["Disable Server Positioning"] = true

-- ./Modules/ChatScroll.lua
L["Mousewheel Scroll"] = true
L["Scroll lines"] = true
L["How many lines to scroll per mouse wheel click"] = true
L["Lets you use the mousewheel to page up and down chat."] = true

-- ./Modules/ChatTabs.lua
L["Chat Tabs"] = true
L["Button Height"] = true
L["Button's height, and text offset from the frame"] = true
L["Hide Tabs"] = true
L["Hides chat frame tabs"] = true
L["Enable Tab Flashing"] = true
L["Enables the Tab to flash when you miss a message"] = true
L["Tab Alpha"] = true
L["Sets the alpha value for your chat tabs"] = true

-- ./Modules/ClickInvite.lua
L["Invite Links"] = true
L["Add Word"] = true
L["Add word to your invite trigger list"] = true
L["Remove Word"] = true
L["Remove a word from your invite trigger list"] = true
L["Remove this word from your trigger list?"] = true
L["Alt-click name to invite"] = true
L["Lets you alt-click player names to invite them to your party."] = true
L["invite"] = true
L["inv"] = true
L["Gives you more flexibility in how you invite people to your group."] = true

-- ./Modules/CopyChat.lua
L["Copy Chat"] = true
L["Copy Text"] = true
L["Lets you copy text out of your chat frames."] = true
L["Copy text from this frame."] = true
L["Show copy icon"] = true
L["Toggle the copy icon on the chat frame."] = true

-- ./Modules/DelayGMOTD.lua
-- no localization

-- ./Modules/EditBox.lua
L["Edit Box Polish"] = true
L["Top"] = true
L["Bottom"] = true
L["Free-floating"] = true
L["Free-floating, Locked"] = true
L["Attach to..."] = true
L["Attach edit box to..."] = true
L["Color border by channel"] = true
L["Sets the frame's border color to the color of your currently active channel"] = true
L["Use Alt key for cursor movement"] = true
L["Requires the Alt key to be held down to move the cursor in chat"] = true
L["Select the font to use for the edit box"] = true
L["Height"] = true
L["Select the height of the edit box"] = true
L["Lets you customize the position and look of the edit box"] = true

-- ./Modules/EditBoxHistory.lua
L["Edit Box History"] = true
L["Remembers the history of the editbox across sessions."] = true

-- ./Modules/GroupSay.lua
L["Group Say (/gr)"] = true
L["Provides a /gr slash command to let you speak in your group (raid, party, or battleground) automatically."] = true

-- ./Modules/Highlight.lua
L["Highlights"] = true
L["Options"] = true
L["Use sound"] = true
L["Play a soundfile when one of your keywords is said."] = true
L["Show SCT message"] = true
L["Show highlights in your SCT mod"] = true
L["Reroute whole message to SCT"] = true
L["Reroute whole message to SCT instead of just displaying 'who said keyword in channel'"] = true
L["Sound File"] = true
L["Sound file to play"] = true
L["Add word to your highlight list"] = true
L["Remove a word from your highlight list"] = true
L["Remove this word from your highlights?"] = true
L["Custom Channel Sounds"] = true
L["Play a sound when a message is received in this channel"] = true
L["[%s] %s: %s"] = true
L["%s said '%s' in %s"] = true
L["Alerts you when someone says a keyword or speaks in a specified channel."] = true
L["RealID Whisper"] = true
L["RealID Conversation"] = true

-- ./Modules/Justify.lua
L["Text Justification"] = true
L["Enable text justification"] = true
L["Left"] = true
L["Right"] = true
L["Center"] = true
L["Lets you set the justification of text in your chat frames."] = true

-- ./Modules/LinkHover.lua
L["Link Hover"] = true
L["Makes link tooltips show when you hover them in chat."] = true

-- ./Modules/MacroLink.lua
L["Macro Link"] = true
L["Allows you to link items by ID in chat or macros by using item:1234 syntax."] = true

-- ./Modules/PlayerNames.lua
L["Player Names"] = true
L["Class"] = true
L["Name"] = true
L["None"] = true
L["Druid"] = true
L["Mage"] = true
L["Paladin"] = true
L["Priest"] = true
L["Rogue"] = true
L["Hunter"] = true
L["Shaman"] = true
L["Warlock"] = true
L["Warrior"] = true
L["Death Knight"] = true
L["Provides options to color player names, add player levels, and add tab completion of player names."] = true
L["Save Data"] = true
L["Save data between sessions. Will increase memory usage"] = true
L["Save class data from guild between sessions."] = true
L["Group"] = true
L["Save class data from groups between sessions."] = true
L["Friends"] = true
L["Save class data from friends between sessions."] = true
L["Target/Mouseover"] = true
L["Save class data from target/mouseover between sessions."] = true
L["Who"] = true
L["Save class data from /who queries between sessions."] = true
L["Save all /who data"] = true
L["Will save all data for large /who queries"] = true
L["Reset Data"] = true
L["Destroys all your saved class/level data"] = true
L["Are you sure you want to delete all your saved class/level data?"] = true
L["Separator"] = true
L["Character to use between the name and level"] = true
L["Use Tab Complete"] = true
L["Use tab key to automatically complete character names."] = true
L["Color self in messages"] = true
L["Color own charname in messages."] = true
L["Emphasize self in messages"] = true
L["Add surrounding brackets to own charname in messages."] = true
L["Level Options"] = true
L["Include level"] = true
L["Include the player's level"] = true
L["Exclude max levels"] = true
L["Exclude level display for max level characters"] = true
L["Color level by difficulty"] = true
L["Color Player Names By..."] = true
L["Select a method for coloring player names"] = true
L["Strip RealID brackets"] = true
L["No RealNames"] = true
L["Show toon names instead of real names"] = true
L["RealID Brackets"] = true

-- ./Modules/Scrollback.lua
L["Scrollback"] = true
L["Enable Scrollback length modification"] = true
L["Lets you set the scrollback length of your chat frames."] = true

-- ./Modules/SplitText.lua
L["Message Split"] = true
L["Allows you to type messages longer than normal, and splits message that are too long."] = true

-- ./Modules/StickyChannels.lua
L["Sticky Channels"] = true
L["Emote"] = true
L["Custom channels"] = true
L["Make %s sticky"] = true
L["Makes channels you select sticky."] = true

-- ./Modules/Telltarget.lua
L["Tell Target (/tt)"] = true
L["Enables the /tt command to send a tell to your target."] = true

-- ./Modules/Timestamps.lua
L["Timestamps"] = true
L["HH:MM:SS AM (12-hour)"] = true
L["HH:MM (12-hour)"] = true
L["HH:MM:SS (24-hour)"] = true
L["HH:MM (24-hour)"] = true
L["MM:SS"] = true
L["Timestamp format"] = true
L["Custom format (advanced)"] = true
L["Enter a custom time format. See http://www.lua.org/pil/22.1.html for a list of valid formatting symbols."] = true
L["Timestamp color"] = true
L["Color timestamps the same as the channel they appear in."] = true
L["Per chat frame settings"] = true
L["Choose which chat frames display timestamps"] = true
L["Adds timestamps to chat."] = true

-- ./Modules/TinyChat.lua
L["Tiny Chat"] = true
L["Allows you to make the chat frames much smaller than usual."] = true

-- ./Modules/UrlCopy.lua
L["URL Copy"] = true
L["Parse Mumble links"] = true
L["Automatically inject your character's name into Mumble links, so you connect with your username prefilled."] = true
L["Parse Teamspeak 3 links"] = true
L["Automatically inject your character's name into Teamspeak 3 links, so you connect with your username prefilled."] = true
L["Lets you copy URLs out of chat."] = true

-- ./Tests/urlMatch.lua
-- no localization

