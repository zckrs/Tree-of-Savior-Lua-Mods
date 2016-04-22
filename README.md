# Tree of Savior Lua Mods

### Features

* Experience viewer
* Map fog viewer
* Enhanced monster frames
* Monster kill tracker for journal

![Tree of Savior Experience Viewer](http://i.imgur.com/z8xXMvA.jpg)

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

# Disclaimer

IMC has said that addons are allowed. https://forum.treeofsavior.com/t/stance-on-addons/141262/24

![Addons 1](http://i.imgur.com/oJ4B99B.png)

![Addons 2](http://i.imgur.com/rxLmSoa.png)

If they change their mind, please let me know directly (via official forums so that I know it's them) and I'll delete this and stop distributing/working on it.
