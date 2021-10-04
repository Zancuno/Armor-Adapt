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
	storageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	changed = true
	hideBody = false
	entityType = "npc"
	storageNPCSpecies = npcSpecies
	storageAdaptHeadType = adaptHeadType
	storageAdaptChestType = adaptChestType
	storageAdaptLegType = adaptLegType
	storageAdaptBackType = adaptBackType
	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
end



function update(dt)
	baseUpdate(dt)
	adaptNpcArmor = armorAdapt.generateNpcArmorTable()
	if armorAdapt.compareArmorTables(adaptNpcArmor, storageArmorTable) == false then
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
				if played[2] == 0 and (adaptConfig.showNpcBodyType == true) then
					inflg("[Armor Adapt][NPC Handler]: Body Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your legs type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptConfig.showNpcSpecies == true) then
					sb.logWarn("[Armor Adapt][NPC Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", npcSpecies)
					played[3] = 1
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
		
		for _, speciesEffect in ipairs(adaptConfig.armorAdaptSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesEffect) then
				npcSpecies = npcSpecies..speciesEffect
				adaptHeadType = adaptHeadType..speciesEffect
				adaptChestType = adaptChestType..speciesEffect
				adaptLegType = adaptLegType..speciesEffect
				adaptBackType = adaptBackType..speciesEffect
				adaptEffect = speciesEffect
			end
		end
		
		for _, speciesHeadEffect in ipairs(adaptConfig.armorAdaptHeadSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesHeadEffect) then
				npcSpecies = npcSpecies..speciesHeadEffect
				adaptHeadType = adaptHeadType..speciesHeadEffect
				adaptEffect = speciesHeadEffect
			end
		end
		
		for _, speciesChestEffect in ipairs(adaptConfig.armorAdaptChestSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesChestEffect) then
				npcSpecies = npcSpecies..speciesChestEffect
				adaptChestType = adaptChestType..speciesChestEffect
				adaptEffect = speciesChestEffect
			end
		end
		
		for _, speciesLegEffect in ipairs(adaptConfig.armorAdaptLegSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesLegEffect) then
				npcSpecies = npcSpecies..speciesLegEffect
				adaptLegType = adaptLegType..speciesLegEffect
				adaptEffect = speciesLegEffect
			end
		end
		
		for _, speciesBackEffect in ipairs(adaptConfig.armorAdaptBackSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesBackEffect) then
				npcSpecies = npcSpecies..speciesBackEffect
				adaptBackType = adaptBackType..speciesBackEffect
				adaptEffect = speciesBackEffect
			end
		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
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
		
		if status.uniqueStatusEffectActive(adaptEffect) == false then
			hideBody = false
			playerSpecies = storagePlayerSpecies
			adaptHeadType = storageAdaptHeadType
			adaptChestType = storageAdaptChestType
			adaptLegType = storageAdaptLegType
			adaptBackType = storageAdaptBackType
		end
		
		if played[4] == 0 and (adaptConfig.showNpcArmor == true) then
			inflg("[Armor Adapt][NPC Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptNpcArmor[1], adaptNpcArmor[2], adaptNpcArmor[3], adaptNpcArmor[4], adaptNpcArmor[5], adaptNpcArmor[6], adaptNpcArmor[7], adaptNpcArmor[8])
			played[4] = 1
		end

		if adaptNpcArmor[1] ~= nil then
			baseArmorItem = adaptNpcArmor[1]
			adaptArmorNpcItem = rnadpt(baseArmorItem, 1, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[1], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 2, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[2], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 3, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[3], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 4, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[4], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 5, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[5], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 6, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[6], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 7, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[7], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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
			adaptArmorNpcItem = rnadpt(baseArmorItem, 8, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorNpcItem ~= nil then
				eqpitm(slotTable[8], adaptArmorNpcItem)
				cmptlg(adaptArmorNpcItem, npcSpecies, bodytype, entityType)
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