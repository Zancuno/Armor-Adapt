require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
function init()
	baseInit()
	adaptConfig = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	played = { 0, 0, 0, 0 }
	bodyTable = { "Default", "Default", "Default", "Default", "Default" }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
	bodyType = bodyTable[1]
	bodyHead = bodyTable[2]
	bodyChest = bodyTable[3]
	bodyLegs = bodyTable[4]
	bodyBack = bodyTable[5]
	initSpecies = player.species()
	self.playerSpecies = "standard"
	adaptHeadType = "standard"
	adaptChestType = "standard"
	adaptLegType = "standard"
	adaptBackType = "standard"
	for _,standardSpecies in ipairs(adaptConfig.vanillaBodySpecies) do
		if player.species() == standardSpecies then
			self.playerSpecies = "standard"
		end
	end
	for _,headSpecies in ipairs(adaptConfig.customHeadSpecies) do
		if player.species() == headSpecies then
			self.playerSpecies = initSpecies
			adaptHeadType = initSpecies
		end
	end
	for _,chestSpecies in ipairs(adaptConfig.customChestSpecies) do
		if player.species() == chestSpecies then
			self.playerSpecies = initSpecies
			adaptChestType = initSpecies
		end
	end
	for _,legSpecies in ipairs(adaptConfig.customLegSpecies) do
		if player.species() == legSpecies then
			self.playerSpecies = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,headLegSpecies in ipairs(adaptConfig.customHeadLegSpecies) do
		if player.species() == headLegSpecies then
			self.playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,chestLegSpecies in ipairs(adaptConfig.customChestLegSpecies) do
		if player.species() == chestLegSpecies then
			self.playerSpecies = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,headChestLegSpecies in ipairs(adaptConfig.customHeadChestLegSpecies) do
		if player.species() == headChestLegSpecies then
			self.playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,customSpecies in ipairs(adaptConfig.customBodySpecies) do
		if player.species() == customSpecies then
			self.playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = initSpecies
		end
	end
	for _,aniSpecies in ipairs(adaptConfig.animalSpecies) do
		if player.species() == aniSpecies then
			self.playerSpecies = initSpecies
			adaptHeadType = "null"
			adaptChestType = "null"
			adaptLegType = initSpecies
			adaptBackType = "null"
		end
	end
		if adaptConfig.showStartUp == true then
			sb.logInfo("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
			sb.logInfo("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
		end
	storageArmorTable = { "null", "null", "null", "null", "null", "null", "null", "null" }
	changed = true
	hideBody = false
	entityType = "player"
	storagePlayerSpecies = self.playerSpecies
	storageAdaptHeadType = adaptHeadType
	storageAdaptChestType = adaptChestType
	storageAdaptLegType = adaptLegType
	storageAdaptBackType = adaptBackType
end



function update(dt)
	baseUpdate(dt)
	adaptPlayerArmor = armorAdapt.generatePlayerArmorTable()
	if armorAdapt.compareArmorTables(adaptPlayerArmor, storageArmorTable) == false then
		changed = false
	else
		changed = true
	end
	
	if changed == false or status.uniqueStatusEffectActive("armorAdapt_resetTrigger") then
		for v,armorSpecies in ipairs(adaptConfig.supportedSpecies) do
			if self.playerSpecies == armorSpecies then
				if played[1] == 0 and (adaptConfig.showPlayerSpecies == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Supported Species Recognized: %s", self.playerSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.playerSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyHead = bodyTable[2]
					bodyChest = bodyTable[3]
					bodyLegs = bodyTable[4]
					bodyBack = bodyTable[5]
				if played[2] == 0 and (adaptConfig.showPlayerBodyType == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Body Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptConfig.showPlayerSpecies == true) then
					sb.logWarn("[Armor Adapt][Player Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.playerSpecies)
					played[3] = 1
				end
			end
		end	
		
		for _, effect in ipairs(adaptConfig.armorAdaptEffects) do
			if status.uniqueStatusEffectActive(effect) then
				bodyType = string.format("%s%s", bodyType, effect)
				bodyHead = string.format("%s%s", bodyHead, effect)
				bodyChest = string.format("%s%s", bodyChest, effect)
				bodyLegs = string.format("%s%s", bodyLegs, effect)
				bodyBack = string.format("%s%s", bodyBack, effect)
			end

		end
		
		for _, speciesEffect in ipairs(adaptConfig.armorAdaptSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesEffect) then
				self.playerSpecies = string.format("%s%s", self.playerSpecies, speciesEffect)
				adaptHeadType = string.format("%s%s", adaptHeadType, speciesEffect)
				adaptChestType = string.format("%s%s", adaptChestType, speciesEffect)
				adaptLegType = string.format("%s%s", adaptLegType, speciesEffect)
				adaptBackType = string.format("%s%s", adaptBackType, speciesEffect)
			else
				self.playerSpecies = storagePlayerSpecies
				adaptHeadType = storageAdaptHeadType
				adaptChestType = storageAdaptChestType
				adaptLegType = storageAdaptLegType
				adaptBackType = storageAdaptBackType
			end

		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				self.playerSpecies = overEffect
				bodyType = "Default"
				bodyHead = "Default"
				bodyChest = "Default"
				bodyLegs = "Default"
				bodyBack = "Default"
				hideBody = true
			else
				hideBody = false
				self.playerSpecies = storagePlayerSpecies
				adaptHeadType = storageAdaptHeadType
				adaptChestType = storageAdaptChestType
				adaptLegType = storageAdaptLegType
				adaptBackType = storageAdaptBackType
			end

		end
		
		if played[4] == 0 and (adaptConfig.showPlayerArmor == true) then
			sb.logInfo("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptPlayerArmor[1], adaptPlayerArmor[2], adaptPlayerArmor[3], adaptPlayerArmor[4], adaptPlayerArmor[5], adaptPlayerArmor[6], adaptPlayerArmor[7], adaptPlayerArmor[8])
			played[4] = 1
		end

		if adaptPlayerArmor[1] ~= nil then
			baseArmorItem = adaptPlayerArmor[1]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 1, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[1], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[1] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[1] = adaptPlayerArmor[1]
			end
		else
			storageArmorTable[1] = nil
		end
		if adaptPlayerArmor[2] ~= nil then
			baseArmorItem = adaptPlayerArmor[2]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 2, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[2], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[2] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[2] = adaptPlayerArmor[2]
			end
		else
			storageArmorTable[2] = nil
		end
		if adaptPlayerArmor[3] ~= nil then
			baseArmorItem = adaptPlayerArmor[3]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 3, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[3], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[3] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[3] = adaptPlayerArmor[3]
			end
		else
			storageArmorTable[3] = nil
		end
		if adaptPlayerArmor[4] ~= nil then
			baseArmorItem = adaptPlayerArmor[4]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 4, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[4], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[4] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[4] = adaptPlayerArmor[4]
			end
		else
			storageArmorTable[4] = nil
		end
		if adaptPlayerArmor[5] ~= nil then
			baseArmorItem = adaptPlayerArmor[5]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 5, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[5], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[5] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[5] = adaptPlayerArmor[5]
			end
		else
			storageArmorTable[5] = nil
		end
		if adaptPlayerArmor[6] ~= nil then
			baseArmorItem = adaptPlayerArmor[6]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 6, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[6], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[6] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[6] = adaptPlayerArmor[6]
			end
		else
			storageArmorTable[6] = nil
		end
		if adaptPlayerArmor[7] ~= nil then
			baseArmorItem = adaptPlayerArmor[7]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 7, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[7], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[7] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[7] = adaptPlayerArmor[7]
			end
		else
			storageArmorTable[7] = nil
		end
		if adaptPlayerArmor[8] ~= nil then
			baseArmorItem = adaptPlayerArmor[8]
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, 8, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				player.setEquippedItem(slotTable[8], adaptArmorPlayerItem)
				armorAdapt.showCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType, entityType)
				storageArmorTable[8] = adaptArmorPlayerItem
				played[4] = 0
			else
				storageArmorTable[8] = adaptPlayerArmor[8]
			end
		else
			storageArmorTable[8] = nil
		end
	end
end

function uninit()
	baseUnInit()
	if adaptConfig.showShutDown == true then
		sb.logInfo("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
end