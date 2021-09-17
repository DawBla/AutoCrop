--saved variables
if not AutoCropDB then
    AutoCropDB = { 
    autocropEnabled = true,
    legacyEnabled = false,
    fishingEnabled = false,
    swimmingEnabled = false,
    gogglesEnabled = false,
    pvpEnabled = false,
    buttonEnabled = false,
    buttonScale = 1.0,
    version = "2.0",
    trinketSlot = 13,
    normalHeadID = nil,
    normalTrinketID = nil,
    normalGlovesID = nil,
    normalBootsID = nil,
    normalBeltID = nil,
    gogglesID = nil,
    ridingTrinketID = nil,
    ridingGlovesID = nil,
    ridingBootsID = nil,
    swimmingBeltID = nil,
    fishingHeadID = nil
    }
end

--trinket ids
avaliableTrinketIDs = {25653, 32863}
--goggle ids
avaliableGogglesIDs = {34354, 35182, 34847, 34353, 34356, 35184, 34355, 35185, 35181, 35183, 32480, 32474, 32472, 32476, 32461, 32494, 32478, 32475, 32479, 34357, 32495, 32473, 23762}
--fishing hat ids
avaliableFishingHeadIDs = {28760, 33820, 19972}

--manual gear swap watchers
headWatcher = false
trinketWatcher = false
feetAndHandsWatcher = false
beltWatcher = false

function AutoCropInArray(value, myArray)
  if myArray == nil then
    return
  end
  for _,i in ipairs(myArray) do
      if value == i then
          return true
      end
  end
  return false
end

function AutoCropFindBuff(spellName)
  for i = 1,40 do
    buff = UnitBuff("player", i)
    if(buff == spellName) then
      return true
    end
  end
  return false
end

function AutoCropIsFlightForm()
  local _, _, idx = UnitClass("player")
  if idx == 11 then
    local _, _, _, _, moonkin = GetTalentInfo(1, 18)
    return GetShapeshiftForm() == 5 + moonkin
  end
end

function AutoCropSaveNormalSet()
  if(AutoCropDB.autocropEnabled) then
    if(AutoCropDB.legacyEnabled) then
      local trinketID = GetInventoryItemID("player", AutoCropDB.trinketSlot)
      local bootsID = GetInventoryItemID("player", 8)
      local glovesID = GetInventoryItemID("player", 10)
      if(trinketID ~= AutoCropDB.ridingTrinketID) then
        AutoCropDB.normalTrinketID = trinketID
      end
      if(bootsID ~= AutoCropDB.ridingBootsID) then
        AutoCropDB.normalBootsID = bootsID
      end
      if(glovesID ~= AutoCropDB.ridingGlovesID) then
        AutoCropDB.normalGlovesID = glovesID
      end
    else
      local trinketID = GetInventoryItemID("player", AutoCropDB.trinketSlot)
      if(trinketID ~= AutoCropDB.ridingTrinketID) then
        AutoCropDB.normalTrinketID = trinketID
      end
    end
    if(AutoCropDB.fishingEnabled or AutoCropDB.gogglesEnabled) then
      local headID = GetInventoryItemID("player", 1)
      if(headID ~= AutoCropDB.gogglesID and headID ~= AutoCropDB.fishingHeadID) then
        AutoCropDB.normalHeadID = headID
      end
    end
    if(AutoCropDB.swimmingEnabled) then
      local beltID = GetInventoryItemID("player", 6)
      if(beltID ~= AutoCropDB.swimmingBeltID) then
        AutoCropDB.normalBeltID = beltID
      end
    end
  end
end

function AutoCropEquipNormalSet()
  if(InCombatLockdown() or UnitIsDeadOrGhost("player")) then 
    return 
  elseif(AutoCropDB.autocropEnabled) then
    EquipItemByName(AutoCropDB.normalTrinketID, AutoCropDB.trinketSlot)
    if(AutoCropDB.gogglesEnabled or AutoCropDB.fishingEnabled) then
      EquipItemByName(AutoCropDB.normalHeadID, 1)
    end
    if(AutoCropDB.legacyEnabled) then
      EquipItemByName(AutoCropDB.normalBootsID, 8)
      EquipItemByName(AutoCropDB.normalGlovesID, 10)
    end
    if(AutoCropDB.swimmingEnabled) then
      EquipItemByName(AutoCropDB.normalBeltID, 6)
    end
    ridingGearEquipped = false
  end
end

function AutoCropEquipRidingSet()
  if(InCombatLockdown() or UnitIsDeadOrGhost("player")) then 
    return 
  end
  local inInstance, instanceType = IsInInstance()
  if(inInstance and not(instanceType == "pvp" and AutoCropDB.pvpEnabled)) then
    return
  end
  if(AutoCropDB.autocropEnabled) then
    if(AutoCropDB.legacyEnabled) then
      EquipItemByName(11122, AutoCropDB.trinketSlot)
      EquipItemByName(AutoCropDB.ridingBootsID, 8)
      EquipItemByName(AutoCropDB.ridingGlovesID, 10)
    else
      if(AutoCropIsFlightForm()) then
        EquipItemByName(32481, AutoCropDB.trinketSlot)
      else
        EquipItemByName(AutoCropDB.ridingTrinketID, AutoCropDB.trinketSlot)
      end
    end
    ridingGearEquipped = true
  end
end

function AutoCropEquipGoggles(zoneName)
  if(AutoCropDB.autocropEnabled and AutoCropDB.gogglesEnabled) then
    if(IsMounted() and (zoneName == zones[1] or zoneName == zones[2] or zoneName == zones[3] or zoneName == zones[4])) then
      EquipItemByName(AutoCropDB.gogglesID, 1)
    elseif(IsMounted() and not (zoneName == zones[1] or zoneName == zones[2] or zoneName == zones[3] or zoneName == zones[4])) then
      if(AutoCropDB.fishingEnabled and IsEquippedItemType("Fishing Pole")) then
        EquipItemByName(AutoCropDB.fishingHeadID, 1)
      elseif(GetInventoryItemID("player", 1) ~= AutoCropDB.normalHeadID and not AutoCropFindBuff("Longsight")) then
        print(AutoCropFindBuff("Longsight"))
        EquipItemByName(AutoCropDB.normalHeadID, 1)
      end
    end
  end
end

function AutoCropEquipFishingHead()
  if(AutoCropDB.fishingEnabled and IsEquippedItemType("Fishing Pole")) then
    local itemID = GetInventoryItemID("player", 1)
    if(itemID ~= AutoCropDB.fishingHeadID and itemID ~= AutoCropDB.gogglesID) then
      AutoCropDB.normalHeadID = itemID
    end
    EquipItemByName(AutoCropDB.fishingHeadID, 1)
  elseif(AutoCropDB.fishingEnabled and not IsEquippedItemType("Fishing Pole")) then
    if(itemID == AutoCropDB.fishingHeadID) then
      EquipItemByName(AutoCropDB.normalHeadID, 1)
    end
  end
end

function AutoCropSearchInventory()
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 0, GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      if(link) then
        local itemID, enchantID = link:match("item:(%d+):(%d+)")
        itemID = GetContainerItemID(bag, slot)
        if(legacyEnabled) then
          if(enchantID == "930") then
            AutoCropDB.ridingGlovesID = itemID
          elseif(enchantID == "464") then
            AutoCropDB.ridingBootsID = itemID
          end
        else
          if(AutoCropInArray(itemID, avaliableTrinketIDs)) then
            AutoCropDB.ridingTrinketID = itemID
          elseif(AutoCropInArray(itemID, avaliableGogglesIDs)) then
            AutoCropDB.gogglesID = itemID
          elseif(AutoCropInArray(itemID, avaliableFishingHeadIDs)) then
            AutoCropDB.fishingHeadID = itemID
          end
        end
      end
    end
  end
  --also check if its equipped right now
  itemID = GetInventoryItemID("player", 13)
  if(AutoCropInArray(itemID, avaliableTrinketIDs)) then
    AutoCropDB.ridingTrinketID = itemID
  end
  itemID = GetInventoryItemID("player", 14)
  if(AutoCropInArray(itemID, avaliableTrinketIDs)) then
    AutoCropDB.ridingTrinketID = itemID
  end
  itemID = GetInventoryItemID("player", 1)
  if(AutoCropInArray(itemID, avaliableGogglesIDs)) then
    AutoCropDB.gogglesID = itemID
  end
  itemID = GetInventoryItemID("player", 1)
  if(AutoCropInArray(itemID, avaliableFishingHeadIDs)) then
    AutoCropDB.fishingHeadID = itemID
  end
end

function AutoCropPrint(msg)
	print("|cfffffcfcAuto|cff00ffffCrop|r: "..(msg or ""))
end

function AutoCropOnLoad()
  if AutoCropDB.autocropEnabled then
    AutoCropButton.overlay:SetColorTexture(0, 1, 0, 0.3)
  else
    AutoCropButton.overlay:SetColorTexture(1, 0, 0, 0.5)
  end
  if AutoCropDB.buttonEnabled then
    AutoCropButton:Show()
  else
    AutoCropButton:Hide()
  end
  AutoCropButton:SetScale(AutoCropDB.buttonScale or 1)
  AutoCropSearchInventory()
end

--event listeners  
local f = CreateFrame("Frame")
  f:RegisterEvent('PLAYER_LOGIN')
  f:RegisterEvent('BAG_UPDATE')
  f:RegisterEvent('ADDON_LOADED')
  f:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
  f:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE')
  f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
  f:RegisterEvent('PLAYER_REGEN_DISABLED')
  f:RegisterEvent('PLAYER_REGEN_ENABLED')
  f:RegisterEvent('PLAYER_ENTERING_WORLD')
  f:RegisterEvent('UPDATE_SHAPESHIFT_FORM')

--on addon load
f:SetScript('OnEvent', function(self, event, ...)
    
  --initialization
  if(event == "ADDON_LOADED") then
    local addon = ...
    if addon == "AutoCrop" then
      AutoCropSearchInventory()
      AutoCropOnLoad()
    end
    
    --language support
    local language = GetLocale()
    zones = {}
    if(language == "frFR") then zones = {"Vallée d'Ombrelune","Nagrand","Raz-de-Néant","Marécage de Zangar"}
      elseif(language == "deDE") then zones = {"Schattenmondtal","Nagrand","Nethersturm","Zangarmarschen"}
      elseif(language == "enGB" or language == "enUS") then zones = {"Shadowmoon Valley","Nagrand","Netherstorm","Zangarmarsh"}
      elseif(language == "esES") then zones = {"Valle Sombraluna","Nagrand","Tormenta Abisal","Marisma de Zangar"}
      elseif(language == "esMX") then zones = {"Vale da Lua Negra","Nagrand","Eternévoa","Pântano Zíngaro"}
      elseif(language == "koKR") then zones = {"어둠달 골짜기","나그란드","황천의 폭풍","장가르 습지대"}
      elseif(language == "ruRU") then zones = {"Долина Призрачной Луны","Награнд","Пустоверть","Зангартопь"}
      elseif(language == "zhCN" or language == "zhTW") then zones = {"影月谷","纳格兰","虚空风暴","赞加沼泽"}
    end
    --riding gear check
    ridingGearEquipped = false
    caughtInCombat = false
  end
  
  if(event == "BAG_UPDATE") then
    AutoCropSearchInventory()
    AutoCropEquipFishingHead()
  end
  
  if(event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM") then
    if(IsMounted() and not UnitOnTaxi("player") and (C_SummonInfo.GetSummonConfirmTimeLeft() == 0)) then
      AutoCropSaveNormalSet()
      AutoCropEquipRidingSet()
      AutoCropEquipGoggles(GetRealZoneText())
    else
      AutoCropEquipNormalSet()
      AutoCropEquipGoggles(GetRealZoneText())
    end
  end
  
  if(event == "CHAT_MSG_CHANNEL_NOTICE" or event == "ZONE_CHANGED_NEW_AREA") then
    AutoCropEquipGoggles(GetRealZoneText())
  end
  
  if(event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA") then
    local inInstance, instanceType = IsInInstance()
    if(inInstance and not(instanceType == "pvp" and AutoCropDB.pvpEnabled)) then
      AutoCropEquipNormalSet()
    end
  end
  
  if(event == "PLAYER_REGEN_DISABLED") then
    if(ridingGearEquipped) then
      caughtInCombat = true
    end
  end
  
  if(event == "PLAYER_REGEN_ENABLED") then
    if(not IsMounted() and ridingGearEquipped) then
      AutoCropEquipNormalSet()
      caughtInCombat = false
    end
  end
end)

-- slash commands
local function OnSlash(key, value, ...)
  if key and key ~= "" then
    if key == "enable" then
      if value == "toggle" or tonumber(value) then
        local enable
        if value == "toggle" then
          enable = not AutoCropDB.autocropEnabled
        else
          enable = tonumber(value) == 1 and true or false
        end
        AutoCropDB.autocropEnabled = enable
        if(AutoCropDB.autocropEnabled) then
          AutoCropPrint("AutoCrop enabled")
        else
          AutoCropPrint("AutoCrop disabled")
        end
        if(not enable) then 
          AutoCropEquipNormalSet() 
        else
          AutoCropOnLoad()
        end
      end
    elseif key == "slot" then
      if tonumber(value) then
        local enable = tonumber(value)
        if(enable == 13) then
          AutoCropDB.trinketSlot = enable
          AutoCropPrint("Trinket slot set to upper (13)")
        elseif(enable == 14) then
          AutoCropDB.trinketSlot = enable
          AutoCropPrint("Trinket slot set to lower (14)")
        else
          AutoCropPrint("Incorrect slot id. Try 13 (upper slot) or 14 (lower slot)")
        end
      else
        if(AutoCropDB.trinketSlot == 13) then
          AutoCropPrint("Trinket slot is set to upper (13)")
        elseif(AutoCropDB.trinketSlot == 14) then
          AutoCropPrint("Trinket slot is set to lower (14)")
        end
      end
    elseif key == "legacy" then
        if tonumber(value) then
          local enable = tonumber(value) == 1 and true or false
          AutoCropDB.legacyEnabled = enable
          if(AutoCropDB.legacyEnabled) then
            AutoCropPrint("Legacy mode enabled")
          else
            AutoCropPrint("Legacy mode disabled")
          end
        else
          if(AutoCropDB.legacyEnabled) then
            AutoCropPrint("Legacy mode is enabled")
          else
            AutoCropPrint("Legacy mode is disabled")
          end
        end
    elseif key == "goggles" then
      if tonumber(value) then
        local enable = tonumber(value) == 1 and true or false
        AutoCropDB.gogglesEnabled = enable
        if(AutoCropDB.gogglesEnabled) then
          AutoCropPrint("Engineering goggles enabled")
        else
          AutoCropPrint("Engineering goggles disabled")
        end
      else
        if(AutoCropDB.gogglesEnabled) then
          AutoCropPrint("Engineering goggles are enabled")
        else
          AutoCropPrint("Engineering goggles are disabled")
        end
      end
    elseif key == "pvp" then
      if tonumber(value) then
        local enable = tonumber(value) == 1 and true or false
        AutoCropDB.pvpEnabled = enable
        if(AutoCropDB.pvpEnabled) then
          AutoCropPrint("Riding gear in battlegrounds enabled")
        else
          AutoCropPrint("Riding gear in battlegrounds disabled")
        end
      else
        if(AutoCropDB.pvpEnabled) then
          AutoCropPrint("Riding gear in battlegrounds is enabled")
        else
          AutoCropPrint("Riding gear in battlegrounds is disabled")
        end
      end
    elseif key == "swimming" then
      if tonumber(value) then
        local enable = tonumber(value) == 1 and true or false
        AutoCropDB.swimmingEnabled = enable
        if(AutoCropDB.swimmingEnabled) then
          AutoCropPrint("Swimming belt enabled")
        else
          AutoCropPrint("Swimming belt disabled")
        end
      else
        if(AutoCropDB.swimmingEnabled) then
          AutoCropPrint("Swimming belt is enabled")
        else
          AutoCropPrint("Swimming belt is disabled")
        end
      end
    elseif key == "fishing" then
      if tonumber(value) then
        local enable = tonumber(value) == 1 and true or false
        AutoCropDB.fishingEnabled = enable
        if(AutoCropDB.fishingEnabled) then
          AutoCropPrint("Fishing hat is enabled")
        else
          AutoCropPrint("Fishing hat is disabled")
        end
      else
        if(AutoCropDB.fishingEnabled) then
          AutoCropPrint("Fishing hat is enabled")
        else
          AutoCropPrint("Fishing hat is disabled")
        end
      end
    elseif key == "button" then
      if tonumber(value) then
        local enable = tonumber(value) == 1 and true or false
        AutoCropDB.buttonEnabled = enable
        if(AutoCropDB.buttonEnabled) then
          AutoCropPrint("Button enabled")
        else
          AutoCropPrint("Button disabled")
        end
        AutoCropOnLoad()
      elseif value == "reset" then
        AutoCropButton:ClearAllPoints()
        AutoCropButton:SetPoint("CENTER")
        AutoCropDB.buttonScale = 1
        AutoCropOnLoad()
        AutoCropPrint("Button settings reset")
      elseif value == "scale" then
        local arg2 = ...
        if tonumber(arg2) then
          AutoCropDB.buttonScale = arg2
          AutoCropPrint("Button scale set to: "..AutoCropDB.buttonScale)
          AutoCropOnLoad()
        else
          AutoCropPrint("Button scale is set to: "..AutoCropDB.buttonScale or 1)
        end
      else
        if(AutoCropDB.buttonEnabled) then
          AutoCropPrint("Button is enabled")
        else
          AutoCropPrint("Button is disabled")
        end
      end
    elseif key == "reset" then
      AutoCropDB = nil
      collectgarbage()
      AutoCropPrint("PLEASE RELOAD UI NOW")
    end
  else
    AutoCropPrint("Slash commands:")
    AutoCropPrint("enable - toggle addon on and off. Values: 0/1/toggle ("..(AutoCropDB.autocropEnabled and "1" or "0")..")")
    AutoCropPrint("slot - toggle trinket slot you want to use Values: 13(upper)/14(lower) ("..(AutoCropDB.trinketSlot and "1" or "0")..")")
    AutoCropPrint("goggles - toggle equipping of the engineering goggles. Values: 0/1 ("..(AutoCropDB.gogglesEnabled and "1" or "0")..")")
    AutoCropPrint("pvp - toggle equipping of the riding gear in battlegrounds. Values: 0/1 ("..(AutoCropDB.pvpEnabled and "1" or "0")..")")
    AutoCropPrint("swimming - toggle equipping of the azure silk belt when swimming. Values: 0/1 ("..(AutoCropDB.swimmingEnabled and "1" or "0")..")")
    AutoCropPrint("fishing - toggle equipping of the fishing hat while holding a fishing rod. Values: 0/1 ("..(AutoCropDB.fishingEnabled and "1" or "0")..")")
    AutoCropPrint("legacy - toggle between TBC riding gear and Classic riding gear. Values: 0/1 ("..(AutoCropDB.legacyEnabled and "1" or "0")..")")
    AutoCropPrint("button - settings for the button. Values: 0/1/reset/scale ("..(AutoCropDB.buttonEnabled and "1" or "0")..")")
    AutoCropPrint("reset - reset saved settings, please reload ui with /rl command afterwards!")
    print("|cfffffcfcAuto|cff00ffffCrop|r ver."..AutoCropDB.version.." by |cff00ffffChromie|r-NethergardeKeep")
  end
end

SLASH_AUTOCROP1 = "/autocrop";
SLASH_AUTOCROP2 = "/ac";
SlashCmdList["AUTOCROP"] = function(msg)
  msg = string.lower(msg)
  msg = { string.split(" ", msg) }
  if #msg >= 1 then
    local exec = table.remove(msg, 1)
    OnSlash(exec, unpack(msg))
  end
end

AutoCropButton = CreateFrame("Button", "AutoCropButton", UIParent, "ActionButtonTemplate")
AutoCropButton.icon:SetTexture(133803)
AutoCropButton:SetPoint("CENTER")
AutoCropButton.overlay = AutoCropButton:CreateTexture(nil, "OVERLAY")
AutoCropButton.overlay:SetAllPoints(AutoCropButton)
AutoCropButton:RegisterForDrag("LeftButton")
AutoCropButton:SetMovable(true)
AutoCropButton:SetUserPlaced(true)
AutoCropButton:SetScript("OnDragStart", function() if IsAltKeyDown() then AutoCropButton:StartMoving() end end)
AutoCropButton:SetScript("OnDragStop", AutoCropButton.StopMovingOrSizing)
AutoCropButton:SetScript("OnClick", function()
  if AutoCropDB.autocropEnabled then
    AutoCropButton.overlay:SetColorTexture(1, 0, 0, 0.5)
    AutoCropDB.autocropEnabled = false
    AutoCropEquipNormalSet()
  else
    AutoCropButton.overlay:SetColorTexture(0, 1, 0, 0.3)
    AutoCropDB.autocropEnabled = true
  end
end)