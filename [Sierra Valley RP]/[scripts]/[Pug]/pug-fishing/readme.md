# 🎣 Pug Fishing 2.0

## 💬 Support & Store
Join the support Discord: [https://discord.gg/jYZuWYjfvq]
## 🛍️ Browse my other scripts:
Shop here: [https://pug-webstore.tebex.io/]
## 📁 View the documentation here: 
documentation: [https://pugdocuments.gitbook.io/pug-development]

---

## ⚙️ Installation Instructions
1. THIS IS AN ENTIRELY NEW SCRIPT, DELETE ANYTHING TO DO WITH FISHING 1.0 IF YOU ALREADY OWNED IT!

2. Add all required item png images from:
   - `pug-fishing/(ESX-ONLY)/images` **or**  
   - `pug-fishing/(QBCORE-ONLY)/images`  
   ...into your inventory system.

3. If you are using qs-inventory then make sure to follow the qs-inventory code edit section below.

4. The only thing you may want to tweak is the **upgradable boat storage** values inside `Config.Boats`.

---

## QS-INVENTORY EDIT
1. Go to qs-inventory/config/metadata.js and paste this code in the `FormatItemInfo()` function under any one of the other `else if` statements.
```js
   } else if (itemData.name == "fishinglure" || itemData.name == "fishinglure2") {
      $(".item-info-title").html("<p>" + `${itemData.info.label || label}` + "</p>");
      $(".item-info-description").html(
            "<p><strong>Durability: </strong><span>" +
            itemData.info.uses +
            "%</span></p>"
      );
```

---

## 📌 Understanding Progression System
Start with the **base fishing rod** and earn **fishing reputation** by catching fish.

While fishing, you can find special items like `Skilled-rod` and `Pro-rod`.

Take them to your **crafting station** (`Config.CrafingRodLocation`) to upgrade your rod, as long as you meet the required rep.

Simple, rewarding, and progression-based.

This script is drag-and-drop ready and is already balanced for progression and gameplay, just the way I run it myself.

---