AutoRecharge = { name = "AutoRechargeAndRepair" }

AutoRecharge.defaults = {
	debugMessages = true,
	autoRecharge = true,
	rechargePercentage = 10,
	preferCrownGem = true,
	autoRepair = true,
	autoMerchant = true,
	repairPercentage = 25,
	useCrownRepair = false,
}

local function attemptCharge(weapon, gem, count)
	if IsItemChargeable(BAG_WORN, weapon) then
		local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, weapon)
		if (charges/maxCharges) < (AutoRecharge.savedVariables.rechargePercentage/100) then
			if gem == -1 or count == 0 then
				if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Player does not have a filled soul gem to recharge \""..GetItemName(BAG_WORN, weapon).."\"") end
				return count
			end
			
			if IsUnitDead("player") or GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH) <= 0 then
				if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Cannot recharge item \""..GetItemName(BAG_WORN, weapon).."\" while player is dead!") end
				return count
			end
			
			ChargeItemWithSoulGem(BAG_WORN, weapon, BAG_BACKPACK, gem)
			PlaySound(SOUNDS.INVENTORY_ITEM_APPLY_CHARGE)
			if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Item charged: \""..GetItemName(BAG_WORN, weapon).."\"") end
			return count - 1
		end
	end
	return count
end

local function attemptRepair(armor, kit, count)
	if DoesItemHaveDurability(BAG_WORN, armor) then
		local condition = GetItemCondition(BAG_WORN, armor)
		if condition < AutoRecharge.savedVariables.repairPercentage then
			if kit == -1 or count == 0 then
				if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Player does not have a repair kit to repair \""..GetItemName(BAG_WORN, armor).."\"") end
				return count
			end
			
			if IsUnitDead("player") or GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH) <= 0 then
				if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Cannot repair item \""..GetItemName(BAG_WORN, armor).."\" while player is dead!") end
				return count
			end
			
			RepairItemWithRepairKit(BAG_WORN, armor, BAG_BACKPACK, kit)
			PlaySound(SOUNDS.INVENTORY_ITEM_REPAIR)
			if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Item repaired: \""..GetItemName(BAG_WORN, armor).."\"") end
			return count - 1
		end
	end
	return count
end

local function delayedCombatChange(event, inCombat)
	
	local backpack = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK) 
	
	if AutoRecharge.savedVariables.autoRecharge then
		local soulGemIndex = -1
		local soulGemCount = 0
		
		if AutoRecharge.savedVariables.preferCrownGem then
			--Crown gems
			for k, v in pairs(backpack) do
				if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, v.slotIndex) and IsItemFromCrownStore(BAG_BACKPACK, v.slotIndex) then
					soulGemIndex = v.slotIndex
					soulGemCount = v.stackCount
					break
				end
			end
			
			--regular gems
			if soulGemIndex == -1 then
				for k, v in pairs(backpack) do
					if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, v.slotIndex) and IsItemFromCrownStore(BAG_BACKPACK, v.slotIndex) == false then
						soulGemIndex = v.slotIndex
						soulGemCount = v.stackCount
						break
					end
				end
			end
		else
			--regular gems
			for k, v in pairs(backpack) do
				if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, v.slotIndex) and IsItemFromCrownStore(BAG_BACKPACK, v.slotIndex) == false then
					soulGemIndex = v.slotIndex
					soulGemCount = v.stackCount
					break
				end
			end
			
			--crown gems
			if soulGemIndex == -1 then
				for k, v in pairs(backpack) do
					if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, v.slotIndex) and IsItemFromCrownStore(BAG_BACKPACK, v.slotIndex) then
						soulGemIndex = v.slotIndex
						soulGemCount = v.stackCount
						break
					end
				end
			end
		end
		
		soulGemCount = attemptCharge(EQUIP_SLOT_MAIN_HAND, soulGemIndex, soulGemCount)
		soulGemCount = attemptCharge(EQUIP_SLOT_OFF_HAND, soulGemIndex, soulGemCount)
		soulGemCount = attemptCharge(EQUIP_SLOT_BACKUP_MAIN, soulGemIndex, soulGemCount)
		soulGemCount = attemptCharge(EQUIP_SLOT_BACKUP_OFF, soulGemIndex, soulGemCount)
	end
	
	if AutoRecharge.savedVariables.autoRepair then
		local repairKitIndex = -1
		local repairKitCount = 0
		
		if AutoRecharge.savedVariables.useCrownRepair == false then
			for k, v in pairs(backpack) do
				if  IsItemRepairKit(BAG_BACKPACK, v.slotIndex) and
					IsItemNonCrownRepairKit(BAG_BACKPACK, v.slotIndex) and 
					IsItemNonGroupRepairKit(BAG_BACKPACK, v.slotIndex) then
					
					repairKitIndex = v.slotIndex
					repairKitCount = v.stackCount
					break
				end
			end
			
			repairKitCount = attemptRepair(EQUIP_SLOT_CHEST, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_FEET, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_HAND, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_HEAD, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_LEGS, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_SHOULDERS, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_WAIST, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_BACKUP_OFF, repairKitIndex, repairKitCount)
			repairKitCount = attemptRepair(EQUIP_SLOT_OFF_HAND, repairKitIndex, repairKitCount)
			
		else
			for k, v in pairs(backpack) do
				if GetItemName(BAG_BACKPACK, v.slotIndex) == "Crown Repair Kit" or
					GetItemName(BAG_BACKPACK, v.slotIndex) == "Bound Crown Repair Kit"then
					
					repairKitIndex = v.slotIndex
					break
				end
			end
			
			
			if GetItemCondition(BAG_WORN, EQUIP_SLOT_CHEST) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_FEET) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_HAND) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_HEAD) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_LEGS) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_SHOULDERS) < AutoRecharge.savedVariables.repairPercentage or
				GetItemCondition(BAG_WORN, EQUIP_SLOT_WAIST) < AutoRecharge.savedVariables.repairPercentage or
				(DoesItemHaveDurability(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) and GetItemCondition(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) < AutoRecharge.savedVariables.repairPercentage) or
				(DoesItemHaveDurability(BAG_WORN, EQUIP_SLOT_OFF_HAND) and GetItemCondition(BAG_WORN, EQUIP_SLOT_OFF_HAND) < AutoRecharge.savedVariables.repairPercentage) 
			then
					
					if inCombat == false then
						if repairKitIndex == -1 then
							if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Player does not have any crown repair kits to repair armor!") end
						else
							if IsUnitDead("player") or GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH) <= 0 then
								if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Cannot use crown repair kits while player is dead!") end
								return
							end
								
							local isSuccess = CallSecureProtected("UseItem", BAG_BACKPACK, repairKitIndex)
							
							if isSuccess == true then 
								PlaySound(SOUNDS.INVENTORY_ITEM_REPAIR)
								if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Armor repaired with crown repair kit!") end
							else
								if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("Crown Repair Failed. Player is in combat") end
							end
						end
					end
			end
			
		end
	end
end

function AutoRecharge.ChangePlayerCombatState(event, inCombat)
	--call a function that calls the above function after 2 seconds.
	--IsUnitDead is slow so I'm waiting for it.

	zo_callLater(function() 
		if event == EVENT_PLAYER_ALIVE then 
			inCombat = IsUnitInCombat("player")
		end
		delayedCombatChange(event, inCombat) 
		end, 1000)
end

function AutoRecharge.merchantRepair(eventCode)
	if AutoRecharge.savedVariables.autoMerchant and CanStoreRepair() and GetRepairAllCost() > 0 then
		local backpack = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK) 
		local equips = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_WORN)
		
		local heldMoney = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
		local cost = 0
		local itemsToRepair_Backpack = {}
		local itemsToRepair_Equips = {}
		
		for k, v in pairs(backpack) do
			if DoesItemHaveDurability(BAG_BACKPACK, v.slotIndex) and GetItemRepairCost(BAG_BACKPACK, v.slotIndex) > 0 then
				cost = cost + GetItemRepairCost(BAG_BACKPACK, v.slotIndex)
				itemsToRepair_Backpack[#itemsToRepair_Backpack+1] = v.slotIndex
			end
		end
		
		for k, v in pairs(equips) do
			if DoesItemHaveDurability(BAG_WORN, v.slotIndex) and GetItemRepairCost(BAG_WORN, v.slotIndex) > 0 then
				cost = cost + GetItemRepairCost(BAG_WORN, v.slotIndex)
				itemsToRepair_Equips[#itemsToRepair_Equips+1] = v.slotIndex
			end
		end
		
		if cost < heldMoney then
			for k, v in pairs(itemsToRepair_Backpack) do
				RepairItem(BAG_BACKPACK, v)
			end
			
			for k, v in pairs(itemsToRepair_Equips) do
				RepairItem(BAG_WORN, v)
			end
			
			if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("You spent "..cost.." gold to repair your gear.") end
		else
			if AutoRecharge.savedVariables.debugMessages then AutoRecharge.chat:Print("You couldn't afford "..cost.." gold to repair your gear.") end
		end
	end
end

function AutoRecharge.Initialize()
	AutoRecharge.savedVariables = ZO_SavedVars:NewAccountWide("ARSavedVariables", 1, nil, AutoRecharge.defaults, GetWorldName())
	
	AutoRecharge.chat = LibChatMessage("AutoRechargeAndRepair", "AR") 
	LibChatMessage:SetTagPrefixMode(1)
	
	--settings
	local settings = LibHarvensAddonSettings:AddAddon("Auto Recharge and Repair")
	local areSettingsDisabled = false
	
	local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	local rechargeSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Recharge",}
	local repairSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Repair",}
	
	
	local resetDefaults = {
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			AutoRecharge.savedVariables.debugMessages = AutoRecharge.defaults.debugMessages
			
			AutoRecharge.savedVariables.autoRecharge = AutoRecharge.defaults.autoRecharge
			AutoRecharge.savedVariables.autoRepair = AutoRecharge.defaults.autoRepair
			AutoRecharge.savedVariables.autoMerchant = AutoRecharge.defaults.autoMerchant
			
			AutoRecharge.savedVariables.rechargePercentage = AutoRecharge.defaults.rechargePercentage
			AutoRecharge.savedVariables.repairPercentage = AutoRecharge.defaults.repairPercentage
			
			AutoRecharge.savedVariables.preferCrownGem = AutoRecharge.defaults.preferCrownGem
			AutoRecharge.savedVariables.useCrownRepair = AutoRecharge.defaults.useCrownRepair
		end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle_debug = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Toggle Debug Messages", 
        tooltip = "Enabling this will create chat messages notifying you when the addon recharges or repairs on your behalf.",
        default = AutoRecharge.defaults.debugMessages,
        setFunction = function(state) 
            AutoRecharge.savedVariables.debugMessages = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.debugMessages
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle_recharge = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Toggle Auto Recharge", 
        tooltip = "Automatically recharge your weapons when you enter/exit combat",
        default = AutoRecharge.savedVariables.autoRecharge,
        setFunction = function(state) 
            AutoRecharge.savedVariables.autoRecharge = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.autoRecharge
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local slider_recharge = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Recharge Percentage",
        tooltip = "Weapons will be recharged when they drop below this percentage of charge.",
        setFunction = function(value)
			AutoRecharge.savedVariables.rechargePercentage = value
			
			 end,
        getFunction = function()
            return AutoRecharge.savedVariables.rechargePercentage
        end,
        default = AutoRecharge.defaults.rechargePercentage,
        min = 1,
        max = 100,
        step = 1,
        unit = "%", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	local useCrownGem = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Prefer Crown Gems", 
        tooltip = "Change whether the addon will search for crown soul gems or regular soul gems first.",
        default = AutoRecharge.savedVariables.preferCrownGem,
        setFunction = function(state) 
            AutoRecharge.savedVariables.preferCrownGem = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.preferCrownGem
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle_merchant = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Toggle Auto Merchant Repair", 
        tooltip = "Automatically spends gold to repair your gear when you talk to a merchant.",
        default = AutoRecharge.savedVariables.autoMerchant,
        setFunction = function(state) 
            AutoRecharge.savedVariables.autoMerchant = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.autoMerchant
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle_repair = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Toggle Auto Repair", 
        tooltip = "Automatically repairs your armor as you enter/exit combat",
        default = AutoRecharge.savedVariables.autoRepair,
        setFunction = function(state) 
            AutoRecharge.savedVariables.autoRepair = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.autoRepair
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local slider_repair = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Repair Percentage",
        tooltip = "Armor will be repaired when they drop below this percentage of durability",
        setFunction = function(value)
			AutoRecharge.savedVariables.repairPercentage = value
			
			 end,
        getFunction = function()
            return AutoRecharge.savedVariables.repairPercentage
        end,
        default = AutoRecharge.defaults.repairPercentage,
        min = 1,
        max = 100,
        step = 1,
        unit = "%", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	local useCrownRepair= {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Use Crown Repair Kits", 
        tooltip = "Toggle whether this addon will try to repair with regular repair kits or crown repair kits.\n\n"..
		"Note: Crown armor repair kit checks can only occur as you exit combat, not as you enter it.",
        default = AutoRecharge.savedVariables.useCrownRepair,
        setFunction = function(state) 
            AutoRecharge.savedVariables.useCrownRepair = state
        end,
        getFunction = function() 
            return AutoRecharge.savedVariables.useCrownRepair
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	
	settings:AddSettings({generalSection, resetDefaults, toggle_debug})
	settings:AddSettings({rechargeSection, toggle_recharge, slider_recharge, useCrownGem})
	settings:AddSettings({repairSection, toggle_merchant, toggle_repair, slider_repair, useCrownRepair})
	
	EVENT_MANAGER:RegisterForEvent(AutoRecharge.name, EVENT_PLAYER_COMBAT_STATE, AutoRecharge.ChangePlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(AutoRecharge.name, EVENT_PLAYER_ALIVE, AutoRecharge.ChangePlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(AutoRecharge.name, EVENT_OPEN_STORE, AutoRecharge.merchantRepair)
end
	
function AutoRecharge.OnAddOnLoaded(event, addonName)
	if addonName == AutoRecharge.name then
		AutoRecharge.Initialize()
		EVENT_MANAGER:UnregisterForEvent(AutoRecharge.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(AutoRecharge.name, EVENT_ADD_ON_LOADED, AutoRecharge.OnAddOnLoaded)
