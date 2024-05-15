require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/armorAdapt/armorAdaptBuilder.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
function init()
	baseInit()
	if adaptConfig.showStartUp == true then
		inflg("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
	if armorAdaptVersionNumber == nil or armorAdaptVersionNumber ~= adaptConfig.armorAdaptBuilderVersion then
		require("/scripts/armorAdapt/armorAdaptV1Util.lua")
	else
		require("/scripts/armorAdapt/armorAdaptV2Util.lua")
	end
	eqpitm = player.setEquippedItem
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	
	adaptConfig = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	played = { 0, 0, 0, 0 }
	bodyTable = { dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" 
	adaptStorageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	
	changed = true
	hideBody = false
	entityType = "player"
	statusFolder = "none"
	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
	initSpecies = player.species()
	
	armorAdapt.speciesConfig()

	bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = bodyTable[1], bodyTable[2], bodyTable[3], bodyTable[4], bodyTable[5]
	storageAdaptSpecies,storageAdaptHeadType,storageAdaptChestType,storageAdaptLegType,storageAdaptBackType = adaptSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType
	storageBodyHead,storageBodyChest,storageBodyLegs,storageBodyBack,storageBodyType = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy

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

	adaptArmor = armorAdapt.generatePlayerArmorTable()
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
		
		armorAdapt.getSpeciesBodyTable(adaptSpecies)
		armorAdapt.transformativeEffects()
		
		if played[4] == 0 and (adaptConfig.showPlayerArmor == true) then
			inflg("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptArmor[1], adaptArmor[2], adaptArmor[3], adaptArmor[4], adaptArmor[5], adaptArmor[6], adaptArmor[7], adaptArmor[8])
			played[4] = 1
		end
		
		armorAdapt.slotUpdate()
		
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

function armorAdapt_outfitErrorCheck(slotC)
	if adaptArmor[slotC] ~= nil then
		if root.itemConfig(adaptArmor[slotC]).parameters.itemTags ~= nil then
			if root.itemConfig(adaptArmor[slotC]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				player.radioMessage("armorAdaptOutfitError", 2)	
			end
		end
	end
end