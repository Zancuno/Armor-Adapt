require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
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
	initSpecies = npc.species()
	self.npcSpecies = "standard"
	adaptHeadType = "standard"
	adaptChestType = "standard"
	adaptLegType = "standard"
	adaptBackType = "standard"
	for _,standardSpecies in ipairs(adaptConfig.vanillaBodySpecies) do
		if npc.species() == standardSpecies then
			self.npcSpecies = "standard"
		end
	end
	for _,headSpecies in ipairs(adaptConfig.customHeadSpecies) do
		if npc.species() == headSpecies then
			self.npcSpecies = initSpecies
			adaptHeadType = initSpecies
		end
	end
	for _,chestSpecies in ipairs(adaptConfig.customChestSpecies) do
		if npc.species() == chestSpecies then
			self.npcSpecies = initSpecies
			adaptChestType = initSpecies
		end
	end
	for _,legSpecies in ipairs(adaptConfig.customLegSpecies) do
		if npc.species() == legSpecies then
			self.npcSpecies = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,headLegSpecies in ipairs(adaptConfig.customHeadLegSpecies) do
		if npc.species() == headLegSpecies then
			self.npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,chestLegSpecies in ipairs(adaptConfig.customChestLegSpecies) do
		if npc.species() == chestLegSpecies then
			self.npcSpecies = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,headChestLegSpecies in ipairs(adaptConfig.customHeadChestLegSpecies) do
		if npc.species() == headChestLegSpecies then
			self.npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
		end
	end
	for _,customSpecies in ipairs(adaptConfig.customBodySpecies) do
		if npc.species() == customSpecies then
			self.npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = initSpecies
		end
	end
	for _,aniSpecies in ipairs(adaptConfig.animalSpecies) do
		if npc.species() == aniSpecies then
			self.npcSpecies = npc.species()
			adaptHeadType = "null"
			adaptChestType = "null"
			adaptLegType = npc.species()
			adaptBackType = "null"
		end
	end

		if adaptConfig.showStartUp == true then
			sb.logInfo("[Armor Adapt][NPC Handler]: Initializing Armor Adapt System")
			sb.logInfo("[Armor Adapt][NPC Handler]: Starting equipment check for adaptable items.")
		end
	storageArmorTable = { "null", "null", "null", "null", "null", "null", "null", "null" }
	changed = true
	hideBody = false
	entityType = "npc"
	storageNPCSpecies = self.npcSpecies
	storageAdaptHeadType = adaptHeadType
	storageAdaptChestType = adaptChestType
	storageAdaptLegType = adaptLegType
	storageAdaptBackType = adaptBackType
end



function update(dt)
	baseUpdate(dt)
	adaptNpcArmor = armorAdapt.generateNpcArmorTable()
	if armorAdapt.compareArmorTables(adaptNpcArmor, storageArmorTable) == false then
		changed = false
	else
		changed = true
	end
	if changed == false or status.uniqueStatusEffectActive("armorAdapt_resetTrigger") then
		for v,armorSpecies in ipairs(adaptConfig.supportedSpecies) do
			if self.npcSpecies == armorSpecies then
				if played[1] == 0 and (adaptConfig.showNpcSpecies == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Supported Species Recognized: %s", self.npcSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.npcSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyHead = bodyTable[2]
					bodyChest = bodyTable[3]
					bodyLegs = bodyTable[4]
					bodyBack = bodyTable[5]
				if played[2] == 0 and (adaptConfig.showNpcBodyType == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Body Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your legs type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptConfig.showNpcSpecies == true) then
					sb.logWarn("[Armor Adapt][NPC Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.npcSpecies)
					played[3] = 1
				end
			end
		end	
		
		for j, effect in ipairs(adaptConfig.armorAdaptEffects) do
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
				self.npcSpecies = string.format("%s%s", self.npcSpecies, speciesEffect)
				adaptHeadType = string.format("%s%s", adaptHeadType, speciesEffect)
				adaptChestType = string.format("%s%s", adaptChestType, speciesEffect)
				adaptLegType = string.format("%s%s", adaptLegType, speciesEffect)
				adaptBackType = string.format("%s%s", adaptBackType, speciesEffect)
			else
				self.npcSpecies = storageNPCSpecies
				adaptHeadType = storageAdaptHeadType
				adaptChestType = storageAdaptChestType
				adaptLegType = storageAdaptLegType
				adaptBackType = storageAdaptBackType
			end

		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				self.npcSpecies = overEffect
				bodyType = "Default"
				bodyHead = "Default"
				bodyChest = "Default"
				bodyLegs = "Default"
				bodyBack = "Default"
				hideBody = true
			else
				hideBody = false
				self.npcSpecies = storageNPCSpecies
				adaptHeadType = storageAdaptHeadType
				adaptChestType = storageAdaptChestType
				adaptLegType = storageAdaptLegType
				adaptBackType = storageAdaptBackType
			end

		end
		
		if played[4] == 0 and (adaptConfig.showNpcArmor == true) then
			sb.logInfo("[Armor Adapt][NPC Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptNpcArmor[1], adaptNpcArmor[2], adaptNpcArmor[3], adaptNpcArmor[4], adaptNpcArmor[5], adaptNpcArmor[6], adaptNpcArmor[7], adaptNpcArmor[8])
			played[4] = 1
		end



			if adaptNpcArmor[1] ~= nil then
				baseArmorItem = adaptNpcArmor[1]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 1, adaptHeadType, bodyHead, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[1], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[1] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[1] = adaptNpcArmor[1]
				end
			else
				storageArmorTable[1] = nil
			end
			if adaptNpcArmor[2] ~= nil then
				baseArmorItem = adaptNpcArmor[2]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 2, adaptHeadType, bodyHead, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[2], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[2] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[2] = adaptNpcArmor[2]
				end
			else
				storageArmorTable[2] = nil
			end
			if adaptNpcArmor[3] ~= nil then
				baseArmorItem = adaptNpcArmor[3]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 3, adaptChestType, bodyChest, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[3], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[3] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[3] = adaptNpcArmor[3]
				end
			else
				storageArmorTable[3] = nil
			end
			if adaptNpcArmor[4] ~= nil then
				baseArmorItem = adaptNpcArmor[4]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 4, adaptChestType, bodyChest, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[4], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[4] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[4] = adaptNpcArmor[4]
				end
			else
				storageArmorTable[4] = nil
			end
			if adaptNpcArmor[5] ~= nil then
				baseArmorItem = adaptNpcArmor[5]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 5, adaptLegType, bodyLegs, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[5], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[5] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[5] = adaptNpcArmor[5]
				end
			else
				storageArmorTable[5] = nil
			end
			if adaptNpcArmor[6] ~= nil then
				baseArmorItem = adaptNpcArmor[6]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 6, adaptLegType, bodyLegs, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[6], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[6] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[6] = adaptNpcArmor[6]
				end
			else
				storageArmorTable[6] = nil
			end
			if adaptNpcArmor[7] ~= nil then
				baseArmorItem = adaptNpcArmor[7]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 7, adaptBackType, bodyBack, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[7], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[7] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[7] = adaptNpcArmor[7]
				end
			else
				storageArmorTable[7] = nil
			end
			if adaptNpcArmor[8] ~= nil then
				baseArmorItem = adaptNpcArmor[8]
				adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 8, adaptBackType, bodyBack, hideBody, entityType)
				if adaptArmorNpcItem ~= nil then
					npc.setItemSlot(slotTable[8], adaptArmorNpcItem)
					armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
					storageArmorTable[8] = adaptArmorNpcItem
					played[4] = 0

				else
					storageArmorTable[8] = adaptNpcArmor[8]
				end
			else
				storageArmorTable[8] = nil
			end
	end
end