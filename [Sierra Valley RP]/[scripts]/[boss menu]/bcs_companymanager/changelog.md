# Changelog

- **29/01/2022**
  Add sendbill event at server side for easier billing.
  Update instruction:
  - Replace server/functions.lua
    Usage example

```lua
    -- from client
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
    -- target, description, amount
    TriggerServerEvent('bill:sendBill', GetPlayerServerId(closestPlayer), 'Billing to you bro', 5000)
```

- **01/02/2022**
  Add Create company bill and company bill listing in account menu.
  Update instruction:

  - Replace server/main.lua and Replace client/main.lua and html folder
    [youtube](https://youtu.be/95OnAHXx3EY)
  - Add Config.UI in config.lua, add ['create_company_bill'] in Locales

- **03/02/2022**
  Fix deposit and withdraw bug
  Added new option for disabling black money for companies
  Update instruction:

  - Replace server/main.lua and Replace html/assets and html/index.html
  - Add Config.EnableBlackMoney in config.lua
  - missing s after % in Locale in withdrawn_money

- **09/02/2022**
  Add configurable database name for company and billing
  Update instruction:

  - Replace server/main.lua
  - Add Config.database in Config.lua

- **22/02/2022**
  Update compability with [mugshot](https://github.com/jonassvensson4/mugshot), MugShotBase64 is now deemed as deprecated since it is not optimized for this usage.
  Update instruction:

  - Replace server/main.lua and client/functions.lua

- **30/03/2022**
  Fix pagination weird behaviour
  Fix sorting of company billing and personal billings (overdue -> paid -> unpaid)
  Update instruction:

  - Replace html/assets and html/index.html

- **26/04/2022**
  Add Salary manager
  Add example for sending billing from server side (Check server/functions.lua testbill command)
  Add option for percentage cut for employee when bill is paid
  Update instruction:

  - Replace html/assets and html/index.html
  - Config.billing and Locales replace
  - replace client and server files

- **17/06/2022**
  Add config to pay bill with desired account
  Update instruction:

  - Add Config.PayAccountWith
  - replace server/main.lua

- **23/06/2020**
  Fix company money not updating, add qtarget option
  Update instruction:

  - Replace server/classes/account.lua and server/main.lua
  - Add Config.qtarget if you want to use qtarget

- **04/07/2022**
  Add separate permissions for each actions
  Update instruction:

  - Replace client/main.lua, server/main.lua
  - Replace Config.bossmenu and Config.billing

- **13/07/2022**
  Separate discord log for every job in sv_config.lua
  Fix bug when sending billing through default esx_billing trigger
  Update instruction:

  - Replace server folder and sv_config.lua

- **31/07/2022**
  Boss hire now only list closest player
  Change discord log to be disabled by default
  Add esx_billing:payBill event
  Update instruction:

  - Replace server folder

- **16/08/2022**
  Refactor config files
  Fix esx_billing:payBill event
  Fix tax to remove and send correct amount
  Add delete for paid bills option in config
  Update earnings to be in the account of company
  Update instruction:
  - Replace server folder & Config folder
