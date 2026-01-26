## Thank you for purchasing 919ADMIN PRO!

I've had so much fun developing 919ADMIN PRO! I intend on supporting it into the distant future, for as long as FiveM is around and operating.

Thank you for supporting me on my journey since 2021, when I first made 919ADMIN CLASSIC. That project has enabled me to continue bringing the FiveM community the highest quality server management resources.

## Prerequisites
1. Download `ox_lib` (https://github.com/CommunityOx/ox_lib/releases/latest) and place it into your `resources` folder.

2. Download `screencapture` (https://github.com/itschip/screencapture/releases/latest) and place it into your `resources` folder.

## Installation

1. Drop the `amzn_admin` folder (the folder this file is in) into your server's `resources` folder. **Don't drop it in any square bracketed folders like [core] or otherwise.**

2. Add `ensure amzn_admin` to your `server.cfg` file **at the bottom of your load order** (after everything else).

3. (optional) Edit `config.lua` inside the resource package to your liking - there is not much configuration to make this process easy.

4. Restart your server!

## Setup Process

###### IMPORTANT NOTE

**It is absolutely imperative that you complete this setup process with your server empty or locked.** In this pre-installed mode, anyone can begin and complete the 919ADMIN installation process, giving them a fully elevated SUPERADMIN account.

---

Once you have completed the installation process, head into your server and press the **PAGE DOWN** key. This will open the 919ADMIN PRO installation wizard, where you will be asked to confirm some very basic information and the database installation process will complete.

Follow the setup wizard to the end and once complete 919ADMIN PRO will open on its own. You will have been given a SUPERADMIN permission.

## Permission Groups & Users

In 919ADMIN PRO, permission groups are set using our intuitive graphical interface. At the bottom of the **SETTINGS** page, you will find three important pages: _Admin User Management_, _Permission Group Management_, and _Punishment List_.

To add users to 919ADMIN PRO, go into the _Admin User Management_ page and click "Add Admin" on the top right. You will be presented with a modal to select a player in your server and then you must choose a permission group. By default, there is one permission group: **SUPERADMIN**. SUPERADMIN is a permission group that always exists and can't be deleted, and just means that anyone with this group has **all permissions**.

To add permission groups to 919ADMIN PRO, go into the _Permission Group Management_ page. Here is a master list of all permission groups in 919ADMIN PRO. SuperAdmin is of course listed at the top and can't be removed. To add a new permission group, click "Add Permission Group" in the top right corner. Here, you can name your permission group, set a description, and use a graphical grid list to individually check off permissions to allow to this group. Once done, hit "Add Group" in the bottom right of the modal and you will see the permission group appear. This will now be assignable in the _Admin User Management_ page.

## Resetting your 919ADMIN PRO Install
Sometimes you want to start over, and wipe all your 919ADMIN PRO server-side data like permission groups, users, etc. You can do this by executing the command `reset919install` in your server console (txAdmin).