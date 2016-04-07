# Tree-of-Savior-Experience-Viewer-Lua-Mod

A Tree of Savior native lua experience viewer.

![Tree of Savior Experience Viewer](http://i.imgur.com/FFCYumq.jpg)

# Download

[Get the latest release here](https://github.com/Excrulon/Tree-of-Savior-Experience-Viewer-Lua-Mod/releases)

# Installation

1. Extract the zip to your Tree of Savior directory (C:\Program Files (x86)\Steam\steamapps\common\TreeOfSavior for me). Say yes to overwrite any files. expviewer.lua should be in the root directory and SumAni.ipf should be in the data.

2. Start game and login to character.

3. Press Start on the UI window.

4. Move window to the desired position and press "R" to save the position. If you move it without pressing "R" afterwards, it will move back to where it was.

5. Play!

# Uninstall

Delete expviewer.lua and data\SumAni.ipf. The patcher will redownload SumAni.ipf.

# Usage

Small "R" (Reset) button resets your session data.

Pressing "R" (Reset) will also save the frame's location for your current session.  If you move it without pressing "R" afterwards, it will move back to where it was.

To configure which columns are visible, open expviewer.lua with any text editor once you have installed it to the right place. You will see these settings at the top of the file:

```
settings = {
	showCurrentRequiredExperience = true;
	showCurrentPercent = true;
	showLastGainedExperience = true;
	showKillsTilNextLevel = true;
	showExperiencePerHour = true;
	showTimeTilLevel = true;
	enableMapViewer = true;
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
	enableMapViewer = true;
};
```

# Disclaimer

IMC has said that addons are allowed. https://forum.treeofsavior.com/t/stance-on-addons/141262/24

![Addons 1](http://i.imgur.com/oJ4B99B.png)

![Addons 2](http://i.imgur.com/rxLmSoa.png)

If they change their mind, please let me know directly (via official forums so that I know it's them) and I'll delete this and stop distributing/working on it.
