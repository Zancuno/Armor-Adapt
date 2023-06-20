require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/armorAdapt/armorAdaptBuilder.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
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
	
	armorAdapt.v1SpeciesFill(aniSpecies, adaptConfig.animalSpecies, initSpecies, dfltNl, dfltNl, initSpecies, dfltNl)
	armorAdapt.v1SpeciesFill(customSpecies, adaptConfig.customBodySpecies, initSpecies, initSpecies, initSpecies, initSpecies, initSpecies)
	armorAdapt.v1SpeciesFill(headChestLegSpecies, adaptConfig.customHeadChestLegSpecies, initSpecies, initSpecies, initSpecies, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(chestLegSpecies, adaptConfig.customChestLegSpecies, initSpecies, dfltSpc, initSpecies, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(headLegSpecies, adaptConfig.customHeadLegSpecies, initSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(legSpecies, adaptConfig.customLegSpecies, initSpecies, dfltSpc, dfltSpc, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(chestSpecies, adaptConfig.customChestSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc, dfltSpc)
	armorAdapt.v1SpeciesFill(headSpecies, adaptConfig.customHeadSpecies, initSpecies, initSpecies, dfltSpc, dfltSpc, dfltSpc)
	armorAdapt.v1SpeciesFill(standardSpecies, adaptConfig.vanillaBodySpecies, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc)
	
	if type(adaptConfig.adaptSpeciesSettings[initSpecies]) == "table" then
		playerSpecies = initSpecies
		adaptHeadType = adaptConfig.adaptSpeciesSettings[initSpecies]["head"]
		adaptChestType = adaptConfig.adaptSpeciesSettings[initSpecies]["chest"]
		adaptLegType = adaptConfig.adaptSpeciesSettings[initSpecies]["pants"]
		adaptBackType = adaptConfig.adaptSpeciesSettings[initSpecies]["back"]
		if adaptConfig.adaptSpeciesSettings[initSpecies]["spriteLibrary"] ~= "default" then
			armAdtSpriteLibrary = adaptConfig.adaptSpeciesSettings[initSpecies]["spriteLibrary"]
		else
			armAdtSpriteLibrary = "default"
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
	if _ENV.root["assetOrigin"] ~= nil then
		if armorAdaptVersionNumber == nil or armorAdaptVersionNumber ~= adaptConfig.armorAdaptBuilderVersion then
			player.radioMessage("armorAdaptBuilderCompatibility", 10)
			sb.logError("[Armor Adapt]: A mod named %s has an outdated build script for Armor Adapt, please advise the developer to visit https://github.com/Zancuno/Armor-Adapt to get the updated file. [Star Extensions installed]", root.assetSourceMetadata(root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")).friendlyName)
		end
	end
end



function update(dt)
	baseUpdate(dt)
	
	adaptPlayerArmor = armorAdapt.generatePlayerArmorTable()
	mismatchCheck = true
	mismatchCheck = armorAdapt.compareArmorTables(adaptPlayerArmor, adaptStorageArmorTable)
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
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, nil, nil, nil, nil, nil, false)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptHeadEffects, bodyType, bodyHead, nil, nil, nil, nil, nil, nil, nil, nil, false)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptChestEffects, bodyType, nil, bodyChest, nil, nil, nil, nil, nil, nil, nil, false)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptLegEffects, bodyType, nil, nil, bodyLegs, nil, nil, nil, nil, nil, nil, false)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptBackEffects, bodyType, nil, nil, nil, bodyBack, nil, nil, nil, nil, nil, false)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptForceEffects, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, storageBodyType, storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack, true)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptHeadForceEffects, bodyType, bodyHead, nil, nil, nil, storageBodyType, storageBodyHead, nil, nil, nil, true)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptChestForceEffects, bodyType, nil, bodyChest, nil, nil, storageBodyType, nil, storageBodyChest, nil, nil, true)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptLegForceEffects, bodyType, nil, nil, bodyLegs, nil, storageBodyType, nil, nil, storageBodyLegs, nil, true)
			armorAdapt.v1EffectUpdate(adaptConfig.armorAdaptBackForceEffects, bodyType, nil, nil, nil, bodyBack, storageBodyType, nil, nil, nil, storageBodyBack, true)
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
		
		for transEffect, transSettings in pairs(adaptConfig.armorAdaptTransformativeEffects) do
			if stseffact(transSettings["effectName"]) then
				local stackTable = { bodyType, bodyHead, bodyChest, bodyLegs, bodyBack }
				local storageStackTable = {storageBodyType, storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack }
				local stack2Table = {playerSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType}
				local disguiseStop = false
				if transSettings["singleFolder"] ~= nil then
					statusFolder = transSettings["singleFolder"]
				end
				for stknum = 5, 1, -1 do
					if transSettings[stknum] == 1 then
						if transSettings["setting"] == "override" then
							stackTable[stknum] = storageStackTable[stknum]
						end
						if transSettings["setting"] == "override" or transSettings["setting"] == "stack" then
							stackTable[stknum] = stackTable[stknum]..transSettings["modifier"]
						elseif (transSettings["setting"] == "classEdit" or transSettings["setting"] == "disguise") and (adaptEffect == transSettings["effectName"] or adaptEffect == "armorAdapt_null" )then
							stack2Table[stknum] = transSettings["modifier"]
							adaptEffect = transSettings["effectName"]
							if transSettings["setting"] == "disguise" then
								stackTable[stknum] = dfltBdy
								hideBody = true
								disguiseStop = true
							end
						end
					end
				end
				bodyType, bodyHead, bodyChest, bodyLegs, bodyBack = stackTable[1], stackTable[2], stackTable[3], stackTable[4], stackTable[5]
				playerSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType = stack2Table[1], stack2Table[2], stack2Table[3], stack2Table[4], stack2Table[5]
			end
			if disguiseStop == true then
				break
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
		for adt_misnum = 8, 1, -1 do
			slotUAdapt = {adaptHeadType, adaptHeadType, adaptChestType, adaptChestType, adaptLegType, adaptLegType, adaptBackType, adaptBackType}
			slotUBody = {bodyHead, bodyHead, bodyChest, bodyChest, bodyLegs, bodyLegs, bodyBack, bodyBack}
			if mismatchCheck[adt_misnum] == adt_misnum then
				armorAdapt_slotUpdate(adt_misnum)
			end
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
			adaptArmorPlayerItem = armorAdapt.runArmorAdapt(baseArmorItem, slotU, slotUAdapt[slotU], slotUBody[slotU], hideBody, entityType, armAdtSpriteLibrary, statusFolder)
		if adaptArmorPlayerItem ~= nil then
			eqpitm(slotTable[slotU], adaptArmorPlayerItem)
			armorAdapt.showCompletionLog(adaptArmorPlayerItem, playerSpecies, bodyType, entityType)
			adaptStorageArmorTable[slotU] = adaptArmorPlayerItem
			played[4] = 0
		else
			adaptStorageArmorTable[slotU] = adaptPlayerArmor[slotU]
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