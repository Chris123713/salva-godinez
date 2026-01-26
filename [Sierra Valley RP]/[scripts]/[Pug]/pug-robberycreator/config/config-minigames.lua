-- utk_fingerprint Minigame | Download: https://github.com/utkuali/Finger-Print-Hacking-Game
if GetResourceState('utk_fingerprint') == 'started' and GetResourceState('utk_hackdependency') == 'started' then
    Config.MiniGames["fingerprint"] = {
        label = "Finger Print",
        Game = function()
            -- levels: how many levels you want. Max is 4, Min is 1
            -- lifes: how many life player has, Max is 6, Min is 1
            -- time: how much time player has in minutes, Max is 9, min is 1 (I highly recommend to set it between 3-1)
            local result = promise.new()  -- levels, lifes, time
            TriggerEvent("utk_fingerprint:Start", 4, 6, 2, function(outcome, reason)
                result:resolve(outcome)
            end)
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3utk_fingerprint ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end

-- ultra-voltlab Minigame  | (MAKE SURE TO DELETE THE VERSION AT THE END OF THE FILE NAME IF YOU DOWNLOAD IT) | Download: https://github.com/ultrahacx/ultra-voltlab/releases/tag/1.1.2
if GetResourceState('ultra-voltlab') == 'started' then
    Config.MiniGames["ultra-voltlab"] = {
        label = "Volt Lab",
        Game = function()
            local result = promise.new() 
            TriggerEvent('ultra-voltlab', 50    , function(status,reason)
            -- time: Time in seconds which player has. Min is 10, Max is 60
            -- result: Reason is the reason of result. Result is an integer code which represents result.
            -- 	   0: Hack failed by player
            -- 	   1: Hack successful
            -- 	   2: Time ran out and hack failed
            -- 	  -1: Error occured i.e. passed input or contents in config is wrong
                local Success
                if status == 1 then
                    Success = true
                end
                result:resolve(Success)
            end)
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3ultra-voltlab ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end

-- 8 Inspired Minigames PACK | Download: https://forum.cfx.re/t/free-standalone-fivem-minigames-nopixel-4-0-minigames/5248433
if GetResourceState('bd-minigames') == 'started' then
    Config.MiniGames["inspired-lockpick"] = {
        label = "Inspired Lockpick",
        Game = function()
            local result = promise.new()
                            -- THIS IS MATH RANDOM FOR HOW MANY CIRCLES YOU NEED TO COMPLETE  (MIN IS 2, MAX IS 5)
            local success = exports['bd-minigames']:Lockpick(2, 5)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["inspired-chopping"] = {
        label = "Inspired Chopping",
        Game = function()
            local result = promise.new()

            local success = exports['bd-minigames']:Chopping(12, 30)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["inspired-pincracker"] = {
        label = "Inspired Pin Cracker",
        Game = function()
            local result = promise.new()

            local success = exports['bd-minigames']:PinCracker(3, 20)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["inspired-roofrunning"] = {
        label = "Inspired Roof Running",
        Game = function()
            local result = promise.new()

            local success = exports['bd-minigames']:RoofRunning(3, 3, 30)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["inspired-thermite"] = {
        label = "Inspired Thermite",
        Game = function()
            local result = promise.new()

            local success = exports['bd-minigames']:Thermite(15, 7, 7, 30)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["inspired-terminal"] = {
        label = "Inspired Terminal",
        Game = function()
            local result = promise.new()

            local success = exports['bd-minigames']:Terminal(4, 2, 10, 30, 4)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3bd-minigames ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end

-- Original Safe Crack Minigame | Download: https://github.com/VHall1/pd-safe?tab=readme-ov-file
if GetResourceState('pd-safe') == 'started' then
    Config.MiniGames["safe-cracker"] = {
        label = "Safe Cracker",
        Game = function()
            local result = promise.new()
            local success = exports["pd-safe"]:createSafe({math.random(0,99),math.random(0,99),math.random(0,99),math.random(0,99)})

            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
    Config.MiniGames["safe-cracker-easy"] = {
        label = "Safe Cracker Easy",
        Game = function()
            local result = promise.new()
            local success = exports["pd-safe"]:createSafe({math.random(0,99)})

            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3pd-safe ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end
-- ran-minigames pack | Download: https://github.com/RanDXDev/ran-minigames
if GetResourceState('ran-minigames') == 'started' then
    Config.MiniGames["memorycard"] = {
        label = "Memory Card",
        Game = function()
            local result = promise.new()
                                                ---time is optional, time is in seconds
            local success = exports['ran-minigames']:MemoryCard(120)
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
    Config.MiniGames["minesweep"] = {
        label = "Mine Sweep",
        Game = function()
            local result = promise.new()
            --[[
                money, bomb, bombfail are required.
                money: number; (Maximum money amount to get)
                bomb: number; (How much bomb the minigame has)
                bombfail: number; (How much bomb limit we get to force cash out)
                position?: "left" | "right" | "center"
            ]]
            local success = exports['ran-minigames']:MineSweep(12000, 12, 3, "center")
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
    Config.MiniGames["openterminal"] = {
        label = "Open Terminal",
        Game = function()
            local result = promise.new()
            --[[
                money, bomb, bombfail are required.
                money: number; (Maximum money amount to get)
                bomb: number; (How much bomb the minigame has)
                bombfail: number; (How much bomb limit we get to force cash out)
                position?: "left" | "right" | "center"
            ]]
            local success = exports['ran-minigames']:OpenTerminal()
            result:resolve(success)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3ran-minigames ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end

if GetResourceState('boii_minigames') == 'started' then
    Config.MiniGames["anagram_game"] = {
        label = "Anagram Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:anagram({
                style = 'default', -- Style template
                loading_time = 5000, -- Total time to complete loading sequence in (ms)
                difficulty = 10, -- Game difficulty refer to `const word_lists` in `html/scripts/anagram/anagram.js`
                guesses = 5, -- Amount of guesses until fail
                timer = 30000 -- Time allowed for guessing in (ms)
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["button_mash_game"] = {
        label = "Button Mash Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:button_mash({
                style = 'default', -- Style template
                difficulty = 10 -- Difficulty; increasing the difficulty decreases the amount the notch increments on each keypress making the game harder to complete
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["chip_hack_game"] = {
        label = "Chip Hack Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:chip_hack({
                style = 'default', -- Style template
                loading_time = 8000, -- Total time to complete loading sequence in (ms)
                chips = 2, -- Amount of chips required to find
                timer = 20000 -- Total allowed game time in (ms)
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["hangman_game"] = {
        label = "Hangman Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:hangman({
                style = 'default', -- Style template
                loading_time = 5000, -- Total time to complete loading sequence in (ms)
                difficulty = 4, -- Game difficulty refer to `const hangman_word_lists` in `html/scripts/hangman/hangman.js`
                guesses = 5, -- Amount of guesses until fail
                timer = 30000 -- Time allowed for guessing in (ms)
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["key_drop_game"] = {
        label = "Key Drop Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:key_drop({
                style = 'default', -- Style template
                score_limit = 5, -- Amount of keys needed for success
                miss_limit = 3, -- Amount of keys allowed to miss before fail
                fall_delay = 2000, -- Time taken for keys to fall from top to bottom in (ms)
                new_letter_delay = 1000 -- Time taken to drop a new key in (ms)
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["pincode_game"] = {
        label = "Pincode Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:pincode({
                style = 'default', -- Style template
                difficulty = 4, -- Difficuly; increasing the value increases the amount of numbers in the pincode; level 1 = 4 number, level 2 = 5 numbers and so on // The ui will comfortably fit 10 numbers (level 6) this should be more than enough
                guesses = 5 -- Amount of guesses allowed before fail
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["safe_crack_game"] = {
        label = "Safe Crack Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:safe_crack({
                style = 'default', -- Style template
                difficulty = 5 -- Difficuly; This increases the amount of lock a player needs to unlock this scuffs out a little above 6 locks I would suggest to use levels 1 - 5 only.
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["skill_bar_game"] = {
        label = "Skill Bar Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:skill_bar({
                style = 'default', -- Style template
                icon = 'fa-solid fa-paw', -- Any font-awesome icon; will use template icon if none is provided
                orientation = 2, -- Orientation of the bar; 1 = horizontal centre, 2 = vertical right.
                area_size = 20, -- Size of the target area in %
                perfect_area_size = 5, -- Size of the perfect area in %
                speed = 0.5, -- Speed the target area moves
                moving_icon = true, -- Toggle icon movement; true = icon will move randomly, false = icon will stay in a static position
                icon_speed = 3, -- Speed to move the icon if icon movement enabled; this value is / 100 in the javascript side true value is 0.03
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["skill_circle_game"] = {
        label = "Skill Circle Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:skill_circle({
                style = 'default', -- Style template
                icon = 'fa-solid fa-paw', -- Any font-awesome icon; will use template icon if none is provided
                area_size = 4, -- Size of the target area in Math.PI / "value"
                speed = 0.02, -- Speed the target area moves
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["wire_cut_game"] = {
        label = "Wire Cut Game",
        Game = function()
            local result = promise.new()

            exports['boii_minigames']:wire_cut({
                style = 'default', -- Style template
                timer = 60000 -- Time allowed to complete game in (ms)
            }, function(success)
                result:resolve(success)
            end)
            
            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3boii_minigames ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end

-- ps-ui Minigame pack |  Download: https://github.com/Project-Sloth/ps-ui
if GetResourceState('ps-ui') == 'started' then
    Config.MiniGames["maze"] = {
        label = "Maze Game",
        Game = function()
            local result = promise.new()

            exports['ps-ui']:Maze(function(success)
                result:resolve(success)
            end, 20) -- Hack Time Limit
            
            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["circlelock"] = {
        label = "Circle Lock",
        Game = function()
            local result = promise.new()

            exports['ps-ui']:Circle(function(success)
                result:resolve(success)
            end, 1, 20) -- NumberOfCircles, MS

            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["var"] = {
        label = "Var Hack",
        Game = function()
            local result = promise.new()

            exports['ps-ui']:VarHack(function(success)
                result:resolve(success)
            end, 2, 3) -- Number of Blocks, Time (seconds)

            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["thermite"] = {
        label = "Thermite Hack",
        Game = function()
            local result = promise.new()

            exports['ps-ui']:Thermite(function(success)
                result:resolve(success)
            end, 10, 5, 3) -- Time, Gridsize (5, 6, 7, 8, 9, 10), IncorrectBlocks

            local won = Citizen.Await(result)
            return won
        end,
    }

    Config.MiniGames["scrambler"] = {
        label = "Scrambler Hack",
        Game = function()
            local result = promise.new()

            exports['ps-ui']:Scrambler(function(success)
                result:resolve(success)
            end, "numeric", 30, 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )

            local won = Citizen.Await(result)
            return won
        end,
    }
else
    print("^3ps-ui ^2is not started. Make sure that the -main text is removed at the end of the minigame file and it is ensured before robbery creator if you have this minigame installed.")
end