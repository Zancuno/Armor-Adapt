require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
function init()
	baseInit()
	adaptSpecies = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	adaptDebug = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	adaptEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptEffects")
	adaptSpeciesEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptSpeciesEffects")
	adaptOverrideEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptOverrideEffects")
	played = { 0, 0, 0, 0 }
	bodyTable = { "Default", "Standard", "None", "None", "None" }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
	bodyType = bodyTable[1]
	bodyShape = bodyTable[2]
	bodyAccessory = bodyTable[3]
	bodyAlt = bodyTable[4]
	bodyOther = bodyTable[5]
	for _,standardSpecies in ipairs(adaptSpecies.vanillaBodySpecies) do
		if npc.species() == standardSpecies then
			self.npcSpecies = "standard"
		end
	end
	for _,customSpecies in ipairs(adaptSpecies.customBodySpecies) do
		if npc.species() == customSpecies then
			self.npcSpecies = npc.species()
		else
			self.npcSpecies = "standard"
		end
	end
	equippedArmorTimer = 10
	adaptLoopTimer = 10
		if adaptDebug.showStartUp == true then
			sb.logInfo("[Armor Adapt][NPC Handler]: Initializing Armor Adapt System")
			sb.logInfo("[Armor Adapt][NPC Handler]: Starting equipment check for adaptable items.")
		end
	storageArmorTable = { "null", "null", "null", "null", "null", "null", "null", "null" }
	changed = true
	hideBody = false
	entityType = "npc"
	storageNPCSpecies = self.npcSpecies
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
		for v,armorSpecies in ipairs(adaptSpecies.supportedSpecies) do
			if self.npcSpecies == armorSpecies then
				if played[1] == 0 and (adaptDebug.showNpcSpecies == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Supported Species Recognized: %s", self.npcSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.npcSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyShape = bodyTable[2]
					bodyAccessory = bodyTable[3]
					bodyAlt = bodyTable[4]
					bodyOther = bodyTable[5]
				if played[2] == 0 and (adaptDebug.showNpcBodyType == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Body Type Recognized: Your main body type is %s, Your body shape is %s, your body accessory is %s, if you have an alternate feature it is %s, and any other feature if present is %s", bodyType, bodyShape, bodyAccessory, bodyAlt, bodyOther)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptDebug.showNpcSpecies == true) then
					sb.logWarn("[Armor Adapt][NPC Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.npcSpecies)
					played[3] = 1
				end
			end
		end	
		
		for j, effect in ipairs(adaptEffects) do
			if status.uniqueStatusEffectActive(effect) then
				bodyType = string.format("%s%s", bodyType, effect)
			end

		end
		
		for _, speciesEffect in ipairs(adaptSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesEffect) then
				self.npcSpecies = string.format("%s%s", self.npcSpecies, speciesEffect)
			else
				self.npcSpecies = storageNPCSpecies
			end

		end
		
		for _, overEffect in ipairs(adaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				self.npcSpecies = overEffect
				bodyType = "Default"
				hideBody = true
			else
				hideBody = false
				self.npcSpecies = storageNPCSpecies
			end

		end
		
		if played[4] == 0 and (adaptDebug.showNpcArmor == true) then
			sb.logInfo("[Armor Adapt][NPC Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptNpcArmor[1], adaptNpcArmor[2], adaptNpcArmor[3], adaptNpcArmor[4], adaptNpcArmor[5], adaptNpcArmor[6], adaptNpcArmor[7], adaptNpcArmor[8])
			played[4] = 1
		end
		for k,slot in ipairs(slotTable) do
			equippedArmorTimer = equippedArmorTimer - dt
			if equippedArmorTimer <= 0 then
				if adaptNpcArmor[1] ~= nil then
					baseArmorItem = adaptNpcArmor[1]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 1, self.npcSpecies, bodyType, hideBody)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[1], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[1] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[1] = adaptNpcArmor[1]
					end
				else
					storageArmorTable[1] = nil
				end
				if adaptNpcArmor[2] ~= nil then
					baseArmorItem = adaptNpcArmor[2]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 2, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[2], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[2] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[2] = adaptNpcArmor[2]
					end
				else
					storageArmorTable[2] = nil
				end
				if adaptNpcArmor[3] ~= nil then
					baseArmorItem = adaptNpcArmor[3]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 3, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[3], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[3] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[3] = adaptNpcArmor[3]
					end
				else
					storageArmorTable[3] = nil
				end
				if adaptNpcArmor[4] ~= nil then
					baseArmorItem = adaptNpcArmor[4]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 4, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[4], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[4] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[4] = adaptNpcArmor[4]
					end
				else
					storageArmorTable[4] = nil
				end
				if adaptNpcArmor[5] ~= nil then
					baseArmorItem = adaptNpcArmor[5]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 5, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[5], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[5] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[5] = adaptNpcArmor[5]
					end
				else
					storageArmorTable[5] = nil
				end
				if adaptNpcArmor[6] ~= nil then
					baseArmorItem = adaptNpcArmor[6]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 6, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[6], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[6] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[6] = adaptNpcArmor[6]
					end
				else
					storageArmorTable[6] = nil
				end
				if adaptNpcArmor[7] ~= nil then
					baseArmorItem = adaptNpcArmor[7]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 7, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[7], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[7] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[7] = adaptNpcArmor[7]
					end
				else
					storageArmorTable[7] = nil
				end
				if adaptNpcArmor[8] ~= nil then
					baseArmorItem = adaptNpcArmor[8]
					adaptArmorNpcItem = armorAdapt.runArmorAdapt(baseArmorItem, 8, self.npcSpecies, bodyType, hideBody, entityType)
					if adaptArmorNpcItem ~= nil then
						npc.setItemSlot(slotTable[8], adaptArmorNpcItem)
						armorAdapt.showCompletionLog(adaptArmorNpcItem, self.npcSpecies, bodytype, entityType)
						storageArmorTable[8] = adaptArmorNpcItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[8] = adaptNpcArmor[8]
					end
				else
					storageArmorTable[8] = nil
				end
				equippedArmorTimer = 10
			end
		end
	end
end