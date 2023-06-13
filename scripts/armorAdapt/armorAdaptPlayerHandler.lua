require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/scripts/util.lua"
require "/armorAdapt/armorAdaptBuilder.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null",
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
			if speciesValue[spriteLibrary] ~= "armorAdapt" then
				armAdtSpriteLibrary = speciesValue[spriteLibrary]
			else
				armAdtSpriteLibrary = "default"
			end
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
	statusFolder = "none"
	storagePlayerSpecies,storageAdaptHeadType,storageAdaptChestType,storageAdaptLegType,storageAdaptBackType = playerSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType
	storageBodyHead,storageBodyChest,storageBodyLegs,storageBodyBack,storageBodyType = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy

	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
	status.clearPersistentEffects("rentekHolidayEffects")
	if _ENV.root[assetOrigin] ~= nil then
		if armorAdaptVersionNumber == nil or armorAdaptVersionNumber ~= adaptConfig.armorAdaptBuilderVersion then
			player.radioMessage("armorAdaptBuilderCompatibility", 10)
			sb.logError("[Armor Adapt]: A mod named %s has an outdated build script for Armor Adapt, please advise the developer to visit https://github.com/Zancuno/Armor-Adapt to get the updated file. [Star Extensions installed]", root.assetSourceMetadata(root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")).friendlyName)
		end
	end
end



function update(dt)
	baseUpdate(dt)
	
	adaptPlayerArmor = armtbl()
	mismatchCheck = cmparmtbt(adaptPlayerArmor, adaptStorageArmorTable)
	if type(mismatchCheck) == "table" then
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
		statusFolder = "none"
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
			stsTransV1Update(adaptConfig.armorAdaptEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptHeadEffects, bodyType, bodyHead, nil, nil, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptChestEffects, bodyType, nil, bodyChest, nil, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptLegEffects, bodyType, nil, nil, bodyLegs, nil, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptBackEffects, bodyType, nil, nil, nil, bodyBack, nil, nil, nil, nil, nil, false)
			stsTransV1Update(adaptConfig.armorAdaptForceEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, storageBodyType, storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack, true)
			stsTransV1Update(adaptConfig.armorAdaptHeadForceEffects, bodyType, bodyHead, nil, nil, nil, storageBodyType, storageBodyHead, nil, nil, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptChestForceEffects, bodyType, nil, bodyChest, nil, nil, storageBodyType, nil, storageBodyChest, nil, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptLegForceEffects, bodyType, nil, nil, bodyLegs, nil, storageBodyType, nil, nil, storageBodyLegs, nil, true)
			stsTransV1Update(adaptConfig.armorAdaptBackForceEffects, bodyType, nil, nil, nil, bodyBack, storageBodyType, nil, nil, nil, storageBodyBack, true)
			for _, holidayEffect in ipairs(adaptConfig.armorAdaptHolidayEffects) do
				if stseffact(holidayEffect) then
					if adaptEffect == "armorAdapt_null" or adaptEffect == holidayEffectEffect then
						playerSpecies,adaptHeadType = holidayEffect, holidayEffect
						bodyType,bodyHead = dfltBdy, dfltBdy
					
						adaptEffect = holidayEffect
					end
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
		end
		
		for transEffect, transSettings in ipairs(adaptConfig.armorAdaptTransformativeEffects) do
			if stseffact(transEffect) then
				local stackTable = { bodyHead, bodyChest, bodyLegs, bodyBack }
				if transSettings[setting] == "stack" then
					bodyType = bodyType..transEffect
					for stknum = 4, 1, -1 do
						if transSettings[stknum] == 1 then
							stackTable[stknum] = stackTable[stknum]..transEffect
						end
					end
				elseif transSettings[setting] == "override" then
					if storageBodyType ~= bodyType then
					bodyType = storageBodyType
					end
					bodyType = bodyType..transEffect
					storageStackTable = { storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack }
					for stknum = 4, 1, -1 do
						if storageBodyType ~= bodyType and transSettings[stknum] == 1 then
							stackTable[stknum] = storageStackTable[stknum]
							stackTable[stknum] = stackTable[stknum]..transEffect
						elseif transSettings[stknum] == 1 then
							stackTable[stknum] = stackTable[stknum]..transEffect
						end
					end
				elseif transSettings[setting] == "classEdit" then
					playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = transEffect, transEffect, transEffect, transEffect, transEffect
					
					adaptEffect = transEffect
				elseif transSettings[setting] == "disguise" then
					if adaptEffect == "armorAdapt_null" or adaptEffect == transEffect then
					playerSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = transEffect, transEffect, transEffect, transEffect, transEffect
					bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy

					hideBody = true
					adaptEffect = transEffect
					end
				end
				if transSettings[singleFolder] ~= nil then
					statusFolder = transSettings[singleFolder]
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
		for _, adt_mismat in ipairs(mismatchCheck) do
			slotUAdapt = {adaptHeadType, adaptHeadType, adaptChestType, adaptChestType, adaptLegType, adaptLegType, adaptBackType, adaptBackType}
			slotUBody = {bodyHead, bodyHead, bodyChest, bodyChest, bodyLegs, bodyLegs, bodyBack, bodyBack}
			armorAdapt_slotUpdate(adt_mismat)
		end
		
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
			adaptArmorPlayerItem = rnadpt(baseArmorItem, slotU, slotUAdapt[slotU], slotUBody[slotU], hideBody, entityType, armAdtSpriteLibrary, statusFolder)
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