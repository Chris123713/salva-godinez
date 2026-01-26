# Pug Robbery Creator. For any questions please contact me here: here https://discord.gg/jYZuWYjfvq
# For any of my other scripts you can purchase here: https://pug-webstore.tebex.io/

Random note that i think everyone should know, go to the main fivem page and then go to settings and then click game and then click "fix ui lag" its a game changer.
# ---------------[INSTALLATION]---------------
1. MAKE SURE YOU ADD THIS ANYWHERE IN YOUR SERVER CFG OR ELSE CUSTOM DOORS WILL NOT WORK-->   setr game_enableDynamicDoorCreation "true" 
2. Make sure to remove qb-bankrobbery, qb-jewelry, and qb-storerobbery if you have it in your server.
3. Add the items from the qb-items.md or ox-items.md to your qb-core/shared/items.lua OR ox_inventory/data/items.lua
4. Add the item png's from the pug-robberycreator/SETUP-AND-INSTALL/Item-PNGs into your inventory item png folder.
5. Read the (MINI GAMES TO DOWNLOAD) section if you want to have cool minigames.
# ------------------------------


# ---------------[HELPFUL NOTES]--------------
1. This is a CREATOR SCRIPT which means EVERYTHING IS OPTIONAL. You set the script exactly how you like, nothing is required and creativity is encouraged.
2. If you have the (thermite and bag scene) animation selected and (Create explosion at target coords) checkbox selected, it will change the thermite prop to a c4 prop.
3. When editing robbery stages you can edit the name of the stage and delete the stage by hoverying over the stage tab on the left hand side.
4. If you want to change the bank truck and atm robbery police alert notifications, you can adjust them in the open.lua.
5. On the hackable door step, if you set the prop to the keypad, the minigame you choose on that step wont matter because the keypad prop has the set minigame of typing in the hidden passcode.
6. If you have any kind of police job you will be given a second option on every robbery step target to reset the step.
7. On the top right of each step you can move the step up or down.
8. If you put 'ReplacePropMini = true' varable in any of the animations in the Config.Animations table, it will delete the prop that is used in that step with that animation. It is already set on the 'grab money' and 'grab' animation.
9. You can get very creative with how you set mini games up within the config. For example of the safe cracker mini game, i have copy and pasted them with different settings to have an easy version and a hard version.
10. You can also edit the mini game config options to make 1 mini game run multiple mini games before succeeding.
11. Its a good idea to add this 'setr profile_skfx 0 # Disable Screen Kill Effects' to your server cfg to remove the blue screen kill efect when killing nps's it good for the guar killing.
12. Read the pre-setup-progression-info.md to know the pre set robbery meta.
# ------------------------------


# ---------------[QB-DOORLOCK USERS (OPTIONAL)]---------------
1. If you are using the preset robberies you will need to configure all of the door locks to the robberies because qb-doorlock does not support automatic functionailty.
2. Use ox_doorlock script instead because its free and as good of a doorlock script as you can possibly get! Download here: https://github.com/overextended/ox_doorlock/releases
2. You can add (Name = "YOUR DOOR NAME") variable to the Config.Doorlist datas and the robbery creator sript will automatically reccognize the new variable. This is to find doors easier in the menu as qb-doorlock doesnt have anything like this by default, that is why i HIGHLY reccomend using ox_doorlock because it is by far the best doorlock system you can use!!.
# ------------------------------


# ---------------[MINI GAMES TO DOWNLOAD]---------------
# (YOU NEED TO MAKE SURE THAT THESE MINI GAMES ARE ENSURED BEFORE ROBBERY CREATOR IN YOUR SERVER CFG ALSO WHEN YOU DOWNLOAD THEM MAKE SURE TO REMOVE THE -main AT THE END OF THE SCRIPT NAME IF IT HAS IT.
# (THESE ARE OPTIONAL BUT THEY ARE GOOD TO HAVE IF YOU WANT OPTIONS. THE SCRIPT IS PRE CONFIGED FOR THESE GAMES SO WHEN YOU INSTALL THEM THEY WILL AUTOMATICALLY BECOME OPTIONS WITHIN THE CREATOR MENU).
1. 8 Inspired Minigames PACK | Download: https://forum.cfx.re/t/free-standalone-fivem-minigames-nopixel-4-0-minigames/5248433 | Preview: https://forum-cfx-re.akamaized.net/optimized/5X/a/e/7/6/ae76f40104ba526e11511cd53e3c39f2f28b4216_2_418x500.png (YOU CAN CHANGE THE SETTING FOR THIS IN CONFIG)
-
2. Finger Print | Download: https://github.com/utkuali/Finger-Print-Hacking-Game | Preview: https://forum-cfx-re.akamaized.net/original/4X/6/5/c/65c86adc33bcd5fb12d67b6eef97d6f291a1c9a6.png (YOU CAN CHANGE THE SETTING FOR THIS IN CONFIG)
-
3. ultra-voltlab (MAKE SURE TO DELETE THE VERSION AT THE END OF THE FILE NAME IF YOU DOWNLOAD IT) | Download: https://github.com/ultrahacx/ultra-voltlab/releases/tag/1.1.2 | Preview: https://forum-cfx-re.akamaized.net/optimized/4X/4/b/d/4bd9fa64e853c7bbeecef701fe45f5a7b7cfa9e3_2_517x290.png
-
4. boii_minigames | Download: https://github.com/boiidevelopment/boii_minigames | https://www.youtube.com/watch?v=LgTMKqg4d8w
-
5. Original safe cracking (REMOVE THE TaskPlayAnim AT LINE 217 in its client) | Download: https://github.com/VHall1/pd-safe?tab=readme-ov-file
-
6. ps-ui Minigame pack | Download: https://github.com/Project-Sloth/ps-ui
-
7. ran-minigames pack | Download: https://github.com/RanDXDev/ran-minigames
# ------------------------------


# ---------------[UNDERSTANDING HOW STICKY NOTES AND PASSCODES WORK | VERY IMPORTANT TO READ]---------------
Key Points:
Purpose: The sticky note passcode step is used to provide the code required for the digital keypad. Placement within the sequence is crucial for proper functionality.

Step Placement:
For a sticky note passcode to be removed and reset after the code is correctly entered, place it within three steps above or below the digital keypad step.
If you often use the "Complete previous step to access this one" checkbox, note that once the code is entered, the sticky note step deletes the sticky note prop and resets after its cooldown.

Trigger Dependencies:
These specific steps require a preceding step to activate them.
If a hackable door (triggered by the keypad) is followed immediately by a sticky note passcode step, then by a guards step, then the guards stage won't trigger. This is because the guards and ending robbery stages need an activating step to set them off.
To ensure everything functions as expected, make sure these steps are set up in a sequence where the keypad step is within range of the sticky note, and any steps requiring triggers have them correctly placed just before.
# ------------------------------
