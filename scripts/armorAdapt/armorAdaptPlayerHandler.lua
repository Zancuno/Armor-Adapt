require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
local rnadpt = armorAdapt.runArmorAdapt
local cmptlg = armorAdapt.showCompletionLog
function init()
	baseInit()
	eqpitm = player.setEquippedItem
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
	initSpecies = player.species()
	playerSpecies = dfltSpc
	adaptHeadType = dfltSpc
	adaptChestType = dfltSpc
	adaptLegType = dfltSpc
	adaptBackType = dfltSpc
	for _,aniSpecies in ipairs(adaptConfig.animalSpecies) do
		if player.species() == aniSpecies then
			playerSpecies = initSpecies
			adaptHeadType = dfltNl
			adaptChestType = dfltNl
			adaptLegType = initSpecies
			adaptBackType = dfltNl
		end
	end
	for _,customSpecies in ipairs(adaptConfig.customBodySpecies) do
		if player.species() == customSpecies then
			playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = initSpecies
		end
	end
	for _,headChestLegSpecies in ipairs(adaptConfig.customHeadChestLegSpecies) do
		if player.species() == headChestLegSpecies then
			playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,chestLegSpecies in ipairs(adaptConfig.customChestLegSpecies) do
		if player.species() == chestLegSpecies then
			playerSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = initSpecies
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,headLegSpecies in ipairs(adaptConfig.customHeadLegSpecies) do
		if player.species() == headLegSpecies then
			playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = dfltSpc
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,legSpecies in ipairs(adaptConfig.customLegSpecies) do
		if player.species() == legSpecies then
			playerSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = dfltSpc
			adaptLegType = initSpecies
			adaptBackType = dfltSpc
		end
	end
	for _,chestSpecies in ipairs(adaptConfig.customChestSpecies) do
		if player.species() == chestSpecies then
			playerSpecies = initSpecies
			adaptHeadType = dfltSpc
			adaptChestType = initSpecies
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	for _,headSpecies in ipairs(adaptConfig.customHeadSpecies) do
		if player.species() == headSpecies then
			playerSpecies = initSpecies
			adaptHeadType = initSpecies
			adaptChestType = dfltSpc
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	for _,standardSpecies in ipairs(adaptConfig.vanillaBodySpecies) do
		if player.species() == standardSpecies then
			playerSpecies = dfltSpc
			adaptHeadType = dfltSpc
			adaptChestType = dfltSpc
			adaptLegType = dfltSpc
			adaptBackType = dfltSpc
		end
	end
	if adaptConfig.showStartUp == true then
		inflg("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
	storageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	changed = true
	hideBody = false
	entityType = "player"
	storagePlayerSpecies = playerSpecies
	storageAdaptHeadType = adaptHeadType
	storageAdaptChestType = adaptChestType
	storageAdaptLegType = adaptLegType
	storageAdaptBackType = adaptBackType
	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
end



function update(dt)
	baseUpdate(dt)
	adaptPlayerArmor = armorAdapt.generatePlayerArmorTable()
	if armorAdapt.compareArmorTables(adaptPlayerArmor, storageArmorTable) == false then
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
			if playerSpecies == armorSpecies then
				if played[1] == 0 and (adaptConfig.showPlayerSpecies == true) then
					inflg("[Armor Adapt][Player Handler]: Supported Species Recognized: %s", playerSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(playerSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyHead = bodyTable[2]
					bodyChest = bodyTable[3]
					bodyLegs = bodyTable[4]
					bodyBack = bodyTable[5]
				if played[2] == 0 and (adaptConfig.showPlayerBodyType == true) then
					inflg("[Armor Adapt][Player Handler]: Body Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptConfig.showPlayerSpecies == true) then
					sb.logWarn("[Armor Adapt][Player Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", playerSpecies)
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
				playerSpecies = playerSpecies..speciesEffect
				adaptHeadType = adaptHeadType..speciesEffect
				adaptChestType = adaptChestType..speciesEffect
				adaptLegType = adaptLegType..speciesEffect
				adaptBackType = adaptBackType..speciesEffect
				adaptEffect = speciesEffect
			end
		end
		
		for _, speciesHeadEffect in ipairs(adaptConfig.armorAdaptHeadSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesHeadEffect) then
				playerSpecies = playerSpecies..speciesHeadEffect
				adaptHeadType = adaptHeadType..speciesHeadEffect
				adaptEffect = speciesHeadEffect
			end
		end
		
		for _, speciesChestEffect in ipairs(adaptConfig.armorAdaptChestSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesChestEffect) then
				playerSpecies = playerSpecies..speciesChestEffect
				adaptChestType = adaptChestType..speciesChestEffect
				adaptEffect = speciesChestEffect
			end
		end
		
		for _, speciesLegEffect in ipairs(adaptConfig.armorAdaptLegSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesLegEffect) then
				playerSpecies = playerSpecies..speciesLegEffect
				adaptLegType = adaptLegType..speciesLegEffect
				adaptEffect = speciesLegEffect
			end
		end
		
		for _, speciesBackEffect in ipairs(adaptConfig.armorAdaptBackSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesBackEffect) then
				playerSpecies = playerSpecies..speciesBackEffect
				adaptBackType = adaptBackType..speciesBackEffect
				adaptEffect = speciesBackEffect
			end
		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				playerSpecies = overEffect
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
		
		if played[4] == 0 and (adaptConfig.showPlayerArmor == true) then
			inflg("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptPlayerArmor[1], adaptPlayerArmor[2], adaptPlayerArmor[3], adaptPlayerArmor[4], adaptPlayerArmor[5], adaptPlayerArmor[6], adaptPlayerArmor[7], adaptPlayerArmor[8])
			played[4] = 1
		end

		if adaptPlayerArmor[1] ~= nil then
			baseArmorItem = adaptPlayerArmor[1]
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 1, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[1], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 2, adaptHeadType, bodyHead, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[2], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 3, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[3], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 4, adaptChestType, bodyChest, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[4], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 5, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[5], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 6, adaptLegType, bodyLegs, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[6], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 7, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[7], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, 8, adaptBackType, bodyBack, hideBody, entityType)
			if adaptArmorPlayerItem ~= nil then
				eqpitm(slotTable[8], adaptArmorPlayerItem)
				cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
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
		inflg("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
end