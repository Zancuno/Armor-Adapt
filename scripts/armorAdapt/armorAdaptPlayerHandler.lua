require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/scripts/util.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
local rnadpt = armorAdapt.runArmorAdapt
local cmptlg = armorAdapt.showCompletionLog
local armtbl = armorAdapt.generatePlayerArmorTable
local cmparmtbt = armorAdapt.compareArmorTables
local stsTransV1Update = armorAdapt.v1EffectUpdate
local spsFill = armorAdapt.v1SpeciesFill
function init()
	baseInit()
	eqpitm = player.setEquippedItem
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	adaptConfig = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	played = { 0, 0, 0, 0 }
	bodyTable = { dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
	bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = bodyTable[1], bodyTable[2], bodyTable[3], bodyTable[4], bodyTable[5]
	
	initSpecies = player.species()
	
	playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc
	
	spsFill(aniSpecies, adaptConfig.animalSpecies, initSpecies, dfltNl, dfltNl, initSpecies, dfltNl)
	spsFill(customSpecies, adaptConfig.customBodySpecies, initSpecies, initSpecies, initSpecies, initSpecies, initSpecies)
	spsFill(headChestLegSpecies, adaptConfig.customHeadChestLegSpecies, initSpecies, initSpecies, initSpecies, initSpecies, dfltSpc)
	spsFill(chestLegSpecies, adaptConfig.customChestLegSpecies, initSpecies, dfltSpc, initSpecies, initSpecies, dfltSpc)
	spsFill(headLegSpecies, adaptConfig.customHeadLegSpecies, initSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc)
	spsFill(legSpecies, adaptConfig.customLegSpecies, initSpecies, dfltSpc, dfltSpc, initSpecies, dfltSpc)
	spsFill(chestSpecies, adaptConfig.customChestSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc, dfltSpc)
	spsFill(headSpecies, adaptConfig.customHeadSpecies, initSpecies, initSpecies, dfltSpc, dfltSpc, dfltSpc)
	spsFill(standardSpecies, adaptConfig.vanillaBodySpecies, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc)
	
	for speciesIndex, speciesValue in ipairs(adaptConfig.adaptSpeciesSettings) do
		if player.species() == speciesIndex then
			playerSpecies = speciesIndex
			adaptHeadType = speciesValue[head]
			adaptChestType = speciesValue[chest]
			adaptLegType = speciesValue[pants]
			adaptBackType = speciesValue[back]
		end
	end

	if adaptConfig.showStartUp == true then
		inflg("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
	adaptStorageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	changed = true
	hideBody = false
	entityType = "player"
	storagePlayerSpecies,storageAdaptHeadType,storageAdaptChestType,storageAdaptLegType,storageAdaptBackType = playerSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType
	storageBodyHead,storageBodyChest,storageBodyLegs,storageBodyBack,storageBodyType = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy

	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
	status.clearPersistentEffects("rentekHolidayEffects")
end



function update(dt)
	baseUpdate(dt)
	
	adaptPlayerArmor = armtbl()
	if cmparmtbt(adaptPlayerArmor, adaptStorageArmorTable) == false then
		changed = false
	else
		changed = true
		if adaptUpdate == 1 then
			status.removeEphemeralEffect("armorAdapt_resetTrigger")
			adaptUpdate = 0
		end
	end
	
	if stseffact("armorAdapt_resetTrigger") and adaptUpdate == 0 then
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
					bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = bodyTable[1], bodyTable[2], bodyTable[3], bodyTable[4], bodyTable[5]

					storageBodyType,storageBodyHead,storageBodyChest,storageBodyLegs,storageBodyBack = bodyType, bodyHead, bodyChest, bodyLegs, bodyBack

				if played[2] == 0 and (adaptConfig.showPlayerBodyType == true) then
					inflg("[Armor Adapt][Player Handler]: Sub Type Recognized: Your sub body type is %s, Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
					played[2] = 1
				end
			end
		end	
		
		if adaptConfig.allowLegacyTransformativeEffects == true then
			stsTransV1Update(effect, adaptConfig.armorAdaptEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptHeadEffects, bodyType, bodyHead, nil, nil, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptChestEffects, bodyType, nil, bodyChest, nil, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptLegEffects, bodyType, nil, nil, bodyLegs, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptBackEffects, bodyType, nil, nil, nil, bodyBack, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptForceEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, storageBodyType, storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack, true)
			stsTransV1Update(adaptConfig.armorAdaptHeadForceEffects, bodyType, bodyHead, nil, nil, nil, storageBodyType, storageBodyHead, nil, nil, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptChestForceEffects, bodyType, nil, bodyChest, nil, nil, storageBodyType, nil, storageBodyChest, nil, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptLegForceEffects, bodyType, nil, nil, bodyLegs, nil, storageBodyType, nil, nil, storageBodyLegs, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptBackForceEffects, bodyType, nil, nil, nil, bodyBack, storageBodyType, nil, nil, nil, storageBodyBack, true)
		end
		
		for transEffect, transSettings in ipairs(adaptConfig.armorAdaptTransformativeEffects) do
			if stseffact(transEffect) then
				bodyType = bodyType..transEffect
				if transSettings[head] == 1 then
					bodyHead = bodyHead..transEffect
				end
				if transSettings[chest] == 1 then
					bodyChest = bodyChest..transEffect
				end
				if transSettings[legs] == 1 then
					bodyLegs = bodyLegs..transEffect
				end
				if transSettings[back] == 1 then
					bodyBack = bodyBack..transEffect
				end
			end
		end
		
		for transForEffect, transForSettings in ipairs(adaptConfig.armorAdaptTransForceEffects) do
			if stseffact(transForEffect) then
				if storageBodyType ~= bodyType then
					bodyType = storageBodyType
				end
				bodyType = bodyType..transForEffect
				if storageBodyType ~= bodyType and transSettings[head] == 1 then
					bodyHead = storageBodyHead
					bodyHead = bodyHead..transForEffect
				elseif transSettings[head] == 1 then
					bodyHead = bodyHead..transForEffect
				end
				if storageBodyType ~= bodyType and transSettings[chest] == 1 then
					bodyChest = storageBodyChest
					bodyChest = bodyChest..transForEffect
				elseif transSettings[chest] == 1 then
					bodyChest = bodyChest..transForEffect
				end
				if storageBodyType ~= bodyType and transSettings[legs] == 1 then
					bodyLegs = storageBodyLegs
					bodyLegs = bodyLegs..transForEffect
				elseif transSettings[legs] == 1 then
					bodyLegs = bodyLegs..transForEffect
				end
				if storageBodyType ~= bodyType and transSettings[back] == 1 then
					bodyBack = storageBodyBack
					bodyBack = bodyBack..transForEffect
				elseif transSettings[back] == 1 then
					bodyBack = bodyBack..transForEffect
				end
			end
		end
			
		for _, holidayEffect in ipairs(adaptConfig.armorAdaptHolidayEffects) do
			if stseffact(holidayEffect) then
				if adaptEffect == "armorAdapt_null" or adaptEffect == holidayEffectEffect then
					playerSpecies,adaptHeadType = holidayEffect, holidayEffect
					bodyType,bodyHead = dfltBdy, dfltBdy
					
					adaptEffect = holidayEffect
				end
			end
		end
		
		for speciesEffect, specEffSpecies in ipairs(adaptConfig.armorAdaptSpeciesEffects) do
			if stseffact(speciesEffect) then
				playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = specEffSpecies, specEffSpecies, specEffSpecies, specEffSpecies, specEffSpecies
				
				adaptEffect = overEffect
			end
		end
		
		for _, overEffect in ipairs(adaptConfig.armorAdaptOverrideEffects) do
			if stseffact(overEffect) then
				if adaptEffect == "armorAdapt_null" or adaptEffect == overEffect then
					playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = overEffect, overEffect, overEffect, overEffect, overEffect
					bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy

					hideBody = true
					adaptEffect = overEffect
				end
			end
		end
		
		if stseffact(adaptEffect) == false then
			playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = storagePlayerSpecies, storageAdaptHeadType, storageAdaptChestType, storageAdaptLegType, storageAdaptBackType
			
			hideBody = false
			adaptEffect = "armorAdapt_null"
		end
		
		if played[4] == 0 and (adaptConfig.showPlayerArmor == true) then
			inflg("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptPlayerArmor[1], adaptPlayerArmor[2], adaptPlayerArmor[3], adaptPlayerArmor[4], adaptPlayerArmor[5], adaptPlayerArmor[6], adaptPlayerArmor[7], adaptPlayerArmor[8])
			played[4] = 1
		end

		armorAdapt_slotUpdate(1)
		armorAdapt_slotUpdate(2)
		armorAdapt_slotUpdate(3)
		armorAdapt_slotUpdate(4)
		armorAdapt_slotUpdate(5)
		armorAdapt_slotUpdate(6)
		armorAdapt_slotUpdate(7)
		armorAdapt_slotUpdate(8)
		
		armorAdapt_outfitErrorCheck(3)
		armorAdapt_outfitErrorCheck(4)
	end
end

function uninit()
	baseUnInit()
	if adaptConfig.showShutDown == true then
		inflg("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
	status.removeEphemeralEffect("hotHolidayEvent")
end

function armorAdapt_slotUpdate(slotU)
	if adaptPlayerArmor[slotU] ~= nil then
		baseArmorItem = adaptPlayerArmor[slotU]
		if baseArmorItem.name == "perfectlygenericitem" then
			eqpitm(slotTable[slotU], nil)
		end
			adaptArmorPlayerItem = rnadpt(baseArmorItem, slotU, adaptBackType, bodyBack, hideBody, entityType)
		if adaptArmorPlayerItem ~= nil then
			eqpitm(slotTable[slotU], adaptArmorPlayerItem)
			cmptlg(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
			adaptStorageArmorTable[slotU] = adaptArmorPlayerItem
			played[4] = 0
		else
			adaptStorageArmorTable[slotU] = adaptPlayerArmor[slot]
		end
	else
		adaptStorageArmorTable[slotU] = nil
	end
end

function armorAdapt_outfitErrorCheck(slotC)
	if adaptPlayerArmor[slotC] ~= nil then
		if root.itemConfig(adaptPlayerArmor[slotC]).parameters.itemTags ~= nil then
			if root.itemConfig(adaptPlayerArmor[slotC]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				player.radioMessage("armorAdaptOutfitError", 2)	
			end
		end
	end
end