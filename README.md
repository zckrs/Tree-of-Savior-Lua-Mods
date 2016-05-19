# If your load addon button gets stuck on the screen, your zip program probably removed or corrupted the unicode character in the ipf filename. Make sure the experience card calculator ipf is named this after extracting:

#### ☃expcardcalculator.ipf

This is just due to the patcher not checking for unicode characters in filenames when it deletes every other file not on their list. Hopefully I can find another way to load stuff so we don't even need to deal with this workaround anymore. May just go back to packing stuff in SumAni.ipf or something.

# Tree of Savior Lua Mods

### Features

* Experience viewer
* Map fog viewer
* Enhanced monster frames
* Monster kill tracker for journal
* Guildmates - Displays character level and character name in a tooltip. Adds party request and friend request to the context menu.
* Zoomy - Allows you to zoom in/out by holding LEFTALT+PLUS or LEFTALT+MINUS.

![Tree of Savior Experience Viewer](http://i.imgur.com/z8xXMvA.jpg)

![Zoomy](http://i.imgur.com/brIjyQ4.jpg)

# Download

[Get the latest release here](https://github.com/Excrulon/Tree-of-Savior-Lua-Mods/releases)

# Installation

 Extract the zip to your Tree of Savior directory (C:\Program Files (x86)\Steam\steamapps\common\TreeOfSavior for me). Say yes to overwrite any files. An addons folder should be in the root directory and SumAni.ipf should be in the data folder. Your directories should look something like this:

![File Structure](http://i.imgur.com/wme1kOc.png)

Start game and login to character.

Press the "Load Addons" button. It should disappear.

![Load Addons](http://i.imgur.com/8ujqiMq.jpg)

Play!
 
![Play!](http://i.imgur.com/z8xXMvA.jpg)

Be sure to press the "R" button at the topright of the experience viewer window in order to save its position after moving it. It will move back if you don't.

# Uninstall

Delete the addons folder and data\SumAni.ipf. The patcher will redownload SumAni.ipf.

# Usage

To configure which columns are visible on the expviewer, open addons/expviewer/expviewer.lua with any text editor once you have installed it to the right place. You will see these settings at the top of the file:

```
settings = {
	showCurrentRequiredExperience = true;
	showCurrentPercent = true;
	showLastGainedExperience = true;
	showKillsTilNextLevel = true;
	showExperiencePerHour = true;
	showTimeTilLevel = true;
};
```

Set the values to either true or false depending on what you want.

Here's an example that only displays current/required experience, kills til next level, and experience/hour with map viewer enabled:

```
settings = {
	showCurrentRequiredExperience = true;
	showCurrentPercent = false;
	showLastGainedExperience = false;
	showKillsTilNextLevel = true;
	showExperiencePerHour = true;
	showTimeTilLevel = false;
};
```

To remove an addon, delete or comment out the dofile line in addons/addonloader.lua.

# Roadmap

* Phase out addon loader and convert all current addons to ipfs only. All addons going forward will be ipfs only.
* Refresh experience viewer. Remove dependencies on hooks as none of them are needed at all. Clean up the look with a new skin and fix up the formatting. Add context menu for all options such as showing and hiding any column.
* Move system menu button to generic utility file. Create popup menu like the system menu functions today. Any addon can call into this to add a button. Will allow things like toggling expviewer and opening settings for each addon.
* Finish and release developer console. This will have some utility methods and override print so anything using print() will pipe to this window as some form of stdout.
* Create draggable window for monster tracker that keeps track of all monster kills on current map and shows their reward.

# Disclaimer

IMC has said that addons are allowed. https://forum.treeofsavior.com/t/stance-on-addons/141262/24

Yes, all addons that aren't hacks/exploits. Not just expviewer. Not just map fog viewer.

![Addons 1](http://i.imgur.com/oJ4B99B.png)

![Addons 2](http://i.imgur.com/rxLmSoa.png)

If they change their mind, please let me know directly (via official forums so that I know it's them) and I'll delete this and stop distributing/working on it.
