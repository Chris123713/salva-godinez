# Pug Business Creator. For any questions please contact me here: here https://discord.gg/jYZuWYjfvq

# ------------------------------
# Installation
- Read through the config.lua & open.lua thoroughly and adjust everything to match your server. (VERY IMPORTANT)
- If you want to use the application creator, make sure to install this script to your server: https://github.com/baguscodestudio/bcs_questionare
- If your stashes dont work and you are QBCore then make sure to change Config.UsingNewQBCore true.
# ------------------------------


# ------------------------------
# HELPFUL NOTES.
1. Do /business in game to open the menu.
2. Do /createditems in game to view and remove any created item.
3. To remove the red or green box outlines turn Config.Debug to false. They are all on by default to help visually see what is happening.
4. To make targets for gangs you just simply make a job in the business menu the same as the gang name from the qb-core/shared/gangs.lua and the script handles the rest.
5. If you test the registers make sure your job is the job the register is set too or else it will not create the customers register.
6. If you want to make criminal crafting benches or targets that ANYONE can target then make a business called "criminal" in the menu and make the crafting bench/targets under that job.
7. If you are QBCORE you need to have the business name in your qb-core/shared/jobs.lua for it to work in the menu of the script.
8. If you are ESX you need to have the business name in your database under jobs and job_grades. You will need to know the basics of your server to do this. I am not to be depended on to do basic server things for your server. 
9. If you are ESX you need to restart your server after making a business in the business creator menu for the money from the register sales to go into the businesses society fund.
# ------------------------------

# ------------------------------
# HOW TO.
1. To add emote options for item consumption, just add emotes to Config.ItemconsumerAnimation.
2. The youtube videos show EXACTLY how to use the script in both the original video and the 2.0 video found here: https://www.youtube.com/watch?v=2OVCtCmUsf8&ab_channel=Pug and here:
# ------------------------------

# ------------------------------
Pug Business Creator: For any questions please contact me here:  https://discord.com/invite/jYZuWYjfvq

PREVIEW HERE: https://www.youtube.com/watch?v=2OVCtCmUsf8&ab_channel=Pug

Full QBCore & ESX Compatibility. (supports custom qb-core names)

This script is partially locked using escrow encryption. The only lua file escrowed is the main client.lua. The client/open.lua, client/targets.lua, client/registers.lua, server/server.lua, and server/registers.lua are all unlocked.

This completely configurable script consist of:
● Advanced useable tv that you can watch streams, movies and videos on with friends.
● Advanced useable whiteboards that you can post png's and gif's onto that are great for advertising menus and more.
● All functions are heavily optimized and synced across all players.
● Custom lang system to support multiple languages.
● Custom Ui with ability to created many features.
● 98% drag and drop resource.

● Very quickly create features in seconds for any businesses with previews such as:
● Advanced cash register system that automatically allocates a percentage of each sale to the business account, while also distributing a smaller share among all on-duty employees present at the business location.
● Zone creation for automatically clocking out employees when they exit the designated business area with that job title.
● Animation targets that you can interact with that will begin animations you set, Great for strip dancing and more.
● Pedestrian spawner that allows you to place whatever peds with animations you can find to put in the config.
● Blips with targets you can interact with to turn the blip on and off for when operation hours are inactive.
● Crafting Stations that can be used for making food items or even illegals items hidden around the world.
● Prop placement spawner that allows you to place whatever props you can find to put in the config.
● Supplies cabinets that can be used to store items and ingredients for the business.
● Personal lockers that are accessible by yourself and no one else.
● Stations to create custom items for your server. (QBCORE ONLY)
● Duty toggle target to clock on and off duty. (QBCORE ONLY)
● Boss menu target to access the boss menu. (QBCORE ONLY)
● Trashcans that delete items inside ever restart.
● Business car garage creation.
● Perfect seat placements.
● Refrigerator supplies.
● Counter trays.

2.0 UPDATE
- Created an edit system for crafting stations (highly requested).
- Created an edit system for supply stations (highly requested).
- Optimized script to update only the relevant job, not all jobs.
- Fixed issue with slow PCs removing targets/props when placing new ones (specific to ox_target).
- Display item code names in supplies and crafting menus instead of item labels.
- Added codem-inventory support.
- Added Config.DontRequireURLImages for manual image placement in inventory instead of using a web link.

- The script now supports making targets for gangs.
- Fixed alphabetical sorting of items in crafting and supplies menus.
- Created a clothing menu target option.
- Fixed issue with consuming created items clearing tasks and kicking out of cars.
- Fixed car heading accuracy for the garage feature.
- Created a new system for placing objects and peds that you can switch too. (MAKES SO SMOOTH NOW)
- Improved ped/prop removal accuracy by using their coordinates instead of aiming point. (MUCH SMOOTHER TO REMOVE THINGS NOW)
- Added text showing the business name above edited features, even if from a different business.
- Created a feature to delete a job through the menu.
- Made it so that when you make a new job it now is the job selected in the menu.
- Props can now be added to animation very easily within the config.
- Created an all new item stocking system for when business employees are off duty.
- Created the ability to set any animation to items when you consume them.
- Items can now be set to give health, armor, food, water, and remove stress all by setting there values.
- Temporary vehicles from the garage can now be put back away.
- Created an all new elevator editor.
- Made an all new advanced business application system!
- Fixed toggling a blip on an off sometimes toggling another blip you made as well.
- Made a new image uploader system for viewing business menus
- Made a new business Statistics menu option for the owner or admins to view all business account money stats and amount of employees per business
- Fixed video would keep playing if you deleted the tv prop while a video was actively playing.

Requirements/Dependencies consist of:
QBCore OR ESX (other frameworks will work but not supported)
qb-menu OR ox_lib (ps-ui or any qb-menu resource name changed will work)
qb-target OR ox_target (any qb-inventory resource name changed will work)
qb-inventory OR ox_inventory OR qs-inventory (any qb-inventory resource name changed will work)
OLD (ESX FRAMEWORKS) ARE NOT SUPPORTED (NO REFUNDS WILL BEGRANTED ON THIS SCRIPT)

5,000 lines of code
# ------------------------------