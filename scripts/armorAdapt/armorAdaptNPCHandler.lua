require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
local rnadpt = armorAdapt.runArmorAdapt
local cmptlg = armorAdapt.showCompletionLog
function init()
	baseInit()
	eqpitm = npc.setItemSlot
	inflg = sb.logInfo
	adaptConfig = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	played = { 0, 0, 0, 0 }
	bodyTable = { dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
	bodyType = bodyTable[1]
	bodyHead = bodyTable[2]
	bodyChest = bodyTable[3]
	bodyLegs = bodyTable[4]
	bodyBack = bodyTable[5]
	initSpecies = npc.species()
	npcSpecies = dfltSpc
	adaptHeadType = dfltSpc
	adaptChestType = dfltSpc
	adaptLegType = dfltSpc
	adaptBackType = dfltSpc
	for _,aniSpecies in ipairs(adaptConfig.animalSpecies) do
		if npc.species() == aniSpecies then
			npcSpecies = npc.species()
			adaptHeadType = dfltNl
			adaptChestType = dfltNl
			adaptLegType = npc.species()
			adaptBackType = dfltNl
		end
	end
	for _,customSpecies in ipairs(adaptConfig.customBodySpecies) do
		if npc.species() == customSpecies then
			npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = initSpecies
		end
	end
	for _,headChestLegSpecies in ipairs(adaptConfig.customHeadChestLegSpecies) do
		if npc.species() == headChestLegSpecies then
			npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,chestLegSpecies in ipairs(adaptConfig.customChestLegSpecies) do
		if npc.species() == chestLegSpecies then
			npcSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,headLegSpecies in ipairs(adaptConfig.customHeadLegSpecies) do
		if npc.species() == headLegSpecies then
			npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = dfltSpc
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,legSpecies in ipairs(adaptConfig.customLegSpecies) do
		if npc.species() == legSpecies then
			npcSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = dfltSpc
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,chestSpecies in ipairs(adaptConfig.customChestSpecies) do
		if npc.species() == chestSpecies then
			npcSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = initSpecies
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	for _,headSpecies in ipairs(adaptConfig.customHeadSpecies) do
		if npc.species() == headSpecies then
			npcSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = dfltSpc
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	for _,standardSpecies in ipairs(adaptConfig.vanillaBodySpecies) do
		if npc.species() == standardSpecies then
			npcSpecies = dfltSpc
			adaptHeadType = dfltSpc
			adaptChestType = dfltSpc
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	if adaptConfig.showStartUp == true then
		inflg("[Armor Adapt][NPC Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][NPC Handler]: Starting equipment check for adaptable items.")
	end
	armorAdapt_storageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	changed = true
	hideBody = false
	entityType = "npc"
	storageNPCSpecies = npcSpecies
	storageAdaptHeadType = adaptHeadType
	storageAdaptChestType = adaptChestType
	storageAdaptLegType = adaptLegType
	storageAdaptBackType = adaptBackType
	storageBodyHead = dfltBdy
	storageBodyChest = dfltBdy
	storageBodyLegs = dfltBdy
	storageBodyBack = dfltBdy
	storageBodyType = dfltBdy
	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
	status.clearPersistentEffects("rentekHolidayEffects")
	status.removeEphemeralEffect("hotHolidayEvent")
end



function update(dt)
	baseUpdate(dt)
	armorAdapt_NpcArmor = armorAdapt.generateNpcArmorTable()
	if armorAdapt.compareArmorTables(armorAdapt_NpcArmor, armorAdapt_storageArmorTable) == false then
		changed = false
	else
		changed = true
		if adaptUpdate == 1 then
			status.removeEphemeralEffect("armorAdapt_resetTrigger")
			adaptUpdate = 0
		end
	end
	
	if status.uniqueStatusEffectActive("armorAdapt_resetTrigger") and adaptUpdate == 0 then
		changed = false
		adaptUpdate = 1
	end
	
	if changed == false then
		for v,armorSpecies in ipairs(adaptConfig.supportedSpecies) do
			if npcSpecies == armorSpecies then
				if played[1] == 0 and (adaptConfig.showNpcSpecies == true) then
					inflg("[Armor Adapt][NPC Handler]: Supported Species Recognized: %s", npcSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(npcSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyHead = bodyTable[2]
					bodyChest = bodyTable[3]
					bodyLegs = bodyTable[4]
					bodyBack = bodyTable[5]
					storageBodyType = bodyType
					storageBodyHead = bodyHead
					storageBodyChest = bodyChest
					storageBodyLegs = bodyLegs
					storageBodyBack = bodyBack
				if played[2] == 0 and (adaptConfig.showNpcBodyType == true) then
					inflg("[Armor Adapt][NPC Handler]: Body Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your legs type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[3] = 1
					played[2] = 1
				end
			end
		end	
		
		for _, effect in ipairs(adaptConfig.armorAdaptEffects) do
			if status.uniqueStatusEffectActive(effect) then
				bodyType = bodyType..effect
				bodyHead = bodyHead..effect
				bodyChest = bodyChest..effect
				bodyLegs = bodyLegs..effect
				bodyBack = bodyBack..effect
			end
		end
		
		for _, effectHead in ipairs(adaptConfig.armorAdaptHeadEffects) do
			if status.uniqueStatusEffectActive(effectHead) then
				bodyType = bodyType..effectHead
				bodyHead = bodyHead..effectHead
			end
		end
		
		for _, effectChest in ipairs(adaptConfig.armorAdaptChestEffects) do
			if status.uniqueStatusEffectActive(effectChest) then
				bodyType = bodyType..effectChest
				bodyChest = bodyChest..effectChest
			end
		end
		
		for _, effectLegs in ipairs(adaptConfig.armorAdaptLegEffects) do
			if status.uniqueStatusEffectActive(effectLegs) then
				bodyType = bodyType..effectLegs
				bodyLegs = bodyLegs..effectLegs
			end
		end
		
		for _, effectBack in ipairs(adaptConfig.armorAdaptBackEffects) do
			if status.uniqueStatusEffectActive(effectBack) then
				bodyType = bodyType..effectBack
				bodyBack = bodyBack..effectBack
			end
		end
		
		for _, forceEffect in ipairs(adaptConfig.armorAdaptForceEffects) do
			if status.uniqueStatusEffectActive(forceEffect) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					bodyHead = storageBodyHead
					bodyChest = storageBodyChest
					bodyLegs = storageBodyLegs
					bodyBack = storageBodyBack
				end
				bodyType = bodyType..forceEffect
				bodyHead = bodyHead..forceEffect
				bodyChest = bodyChest..forceEffect
				bodyLegs = bodyLegs..forceEffect
				bodyBack = bodyBack..forceEffect
			end
		end
		
		for _, forceEffectHead in ipairs(adaptConfig.armorAdaptHeadForceEffects) do
			if status.uniqueStatusEffectActive(forceEffectHead) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					bodyHead = storageBodyHead
				end
				bodyType = bodyType..forceEffectHead
				bodyHead = bodyHead..forceEffectHead
			end
		end
		
		for _, forceEffectChest in ipairs(adaptConfig.armorAdaptChestForceEffects) do
			if status.uniqueStatusEffectActive(forceEffectChest) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					bodyChest = storageBodyChest
				end
				bodyType = bodyType..forceEffectChest
				bodyChest = bodyChest..forceEffectChest
			end
		end
		
		for _, forceEffectLegs in ipairs(adaptConfig.armorAdaptLegForceEffects) do
			if status.uniqueStatusEffectActive(forceEffectLegs) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					bodyLegs = storageBodyLegs
				end
				bodyType = bodyType..forceEffectLegs
				bodyLegs = bodyLegs..forceEffectLegs
			end
		end
		
		for _, forceEffectBack in ipairs(adaptConfig.armorAdaptBackForceEffects) do
			if status.uniqueStatusEffectActive(forceEffectBack) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					bodyBack = storageBodyBack
				end
				bodyType = bodyType..forceEffectBack
				bodyBack = bodyBack..forceEffectBack
			end
		end
		
		for _, holidayEffect in ipairs(adaptConfig.armorAdaptHolidayEffects) do
			if status.uniqueStatusEffectActive(holidayEffect) then
				if adaptEffect == "armorAdapt_null" or adaptEffect == holidayEffect then
					npcSpecies = holidayEffect
					adaptHeadType = holidayEffect
					bodyType = dfltBdy
					bodyHead = dfltBdy
					adaptEffect = holidayEffect
				end
			end
		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				if adaptEffect == "armorAdapt_null" or adaptEffect == overEffect then
					npcSpecies = overEffect
					adaptHeadType = overEffect
					adaptChestType = overEffect
					adaptLegType = overEffect
					adaptBackType = overEffect
					bodyType = dfltBdy
					bodyHead = dfltBdy
					bodyChest = dfltBdy
					bodyLegs = dfltBdy
					bodyBack = dfltBdy
					hideBody = true
					adaptEffect = overEffect
				end
			end
		end
		
		if status.uniqueStatusEffectActive(adaptEffect) == false then
			hideBody = false
			playerSpecies = storagePlayerSpecies
			adaptHeadType = storageAdaptHeadType
			adaptChestType = storageAdaptChestType
			adaptLegType = storageAdaptLegType
			adaptBackType = storageAdaptBackType
			adaptEffect = "armorAdapt_null"
		end
		
		if played[4] == 0 and (adaptConfig.showNpcArmor == true) then
			inflg("[Armor Adapt][NPC Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", armorAdapt_NpcArmor[1], armorAdapt_NpcArmor[2], armorAdapt_NpcArmor[3], armorAdapt_NpcArmor[4], armorAdapt_NpcArmor[5], armorAdapt_NpcArmor[6], armorAdapt_NpcArmor[7], armorAdapt_NpcArmor[8])
			played[4] = 1
		end

		if armorAdapt_NpcArmor[1] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[1]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[1], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 1, adaptHeadType, bodyHead, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[1], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[1] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[1] = armorAdapt_NpcArmor[1]
			end
		else
			armorAdapt_storageArmorTable[1] = nil
		end
		if armorAdapt_NpcArmor[2] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[2]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[2], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 2, adaptHeadType, bodyHead, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[2], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[2] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[2] = armorAdapt_NpcArmor[2]
			end
		else
			armorAdapt_storageArmorTable[2] = nil
		end
		if armorAdapt_NpcArmor[3] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[3]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[3], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 3, adaptChestType, bodyChest, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[3], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[3] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[3] = armorAdapt_NpcArmor[3]
			end
		else
			armorAdapt_storageArmorTable[3] = nil
		end
		if armorAdapt_NpcArmor[4] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[4]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[4], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 4, adaptChestType, bodyChest, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[4], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[4] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[4] = armorAdapt_NpcArmor[4]
			end
		else
			armorAdapt_storageArmorTable[4] = nil
		end
		if armorAdapt_NpcArmor[5] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[5]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[5], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 5, adaptLegType, bodyLegs, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[5], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[5] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[5] = armorAdapt_NpcArmor[5]
			end
		else
			armorAdapt_storageArmorTable[5] = nil
		end
		if armorAdapt_NpcArmor[6] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[6]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[6], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 6, adaptLegType, bodyLegs, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[6], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[6] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[6] = armorAdapt_NpcArmor[6]
			end
		else
			armorAdapt_storageArmorTable[6] = nil
		end
		if armorAdapt_NpcArmor[7] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[7]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[7], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 7, adaptBackType, bodyBack, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[7], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[7] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[7] = armorAdapt_NpcArmor[7]
			end
		else
			armorAdapt_storageArmorTable[7] = nil
		end
		if armorAdapt_NpcArmor[8] ~= nil then
			armorAdapt_itemBase = armorAdapt_NpcArmor[8]
			if armorAdapt_itemBase.name == "perfectlygenericitem" then
				eqpitm(slotTable[8], nil)
			end
			armorAdapt_NpcItem = rnadpt(armorAdapt_itemBase, 8, adaptBackType, bodyBack, hideBody, entityType)
			if armorAdapt_NpcItem ~= nil then
				eqpitm(slotTable[8], armorAdapt_NpcItem)
				cmptlg(armorAdapt_NpcItem, npcSpecies, bodytype, entityType)
				armorAdapt_storageArmorTable[8] = armorAdapt_NpcItem
				played[4] = 0
			else
				armorAdapt_storageArmorTable[8] = armorAdapt_NpcArmor[8]
			end
		else
			armorAdapt_storageArmorTable[8] = nil
		end
		if armorAdapt_NpcArmor[3] ~= nil then
			if root.itemConfig(armorAdapt_NpcArmor[3]).parameters.itemTags ~= nil then
				if root.itemConfig(armorAdapt_NpcArmor[3]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				end
			end
		end
		if armorAdapt_NpcArmor[4] ~= nil then
			if root.itemConfig(armorAdapt_NpcArmor[4]).parameters.itemTags ~= nil then
				if root.itemConfig(armorAdapt_NpcArmor[4]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				end
			end
		end
	end
end