require "/scripts/util.lua"
require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/armorAdapt/armorAdaptBuilder.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end
function init()
	baseInit()
	armAdt_Config = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	armAdt_MinDrtv = armAdt_Config.adaptDirectivesMin
	eqpitm = player.setEquippedItem
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
	if armAdt_Config.showStartUp == true then
		inflg("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
	if armorAdabtBuilderVersion == nil or armorAdabtBuilderVersion ~= armAdt_Config.armorAdaptBuilderVersion then
		require("/scripts/armorAdapt/armorAdaptV1Util.lua")
	else
		require("/scripts/armorAdapt/armorAdaptV2Util.lua")
	end
	armAdt = {
		firstUpdate = true,
		updateFlag = true,
		initSpecies = player.species(),
		entity = "Player",
		statusFolder = "none",
		spriteLibrary = "default",
		frameOverrideFolder = "none",
		hideBody = "showBody",
		flags = { 0, 0, 0, 0 },
		slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" },
		classType = dfltSpc,
		classFolders = { dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc },
		classStorage = {},
		subTypeFolders = { dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy },
		subTypeStorage = {},
		currentArmor = {},
		itemStorage = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }	
	}
	armorAdapt.speciesConfig()
	armAdt.classStorage = util.mergeTable({}, armAdt.classFolders)

	status.clearPersistentEffects("rentekHolidayEffects")
	if _ENV.root["assetOrigin"] ~= nil then
		if armorAdabtBuilderVersion == nil or armorAdabtBuilderVersion ~= armAdt_Config.armorAdaptBuilderVersion then
			player.radioMessage("armorAdaptBuilderCompatibility", 10)
			sb.logError("[Armor Adapt]: A mod named %s has an outdated build script for Armor Adapt, please advise the developer to visit https://github.com/Zancuno/Armor-Adapt to get the updated file. [Star Extensions installed]", root.assetSourceMetadata(root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")).friendlyName)
		end
	end
end

function update(dt)
	baseUpdate(dt)

	armAdt.currentArmor = armorAdapt.generatePlayerArmorTable()
	armAdt_mismatch = true
	armAdt_mismatch = armorAdapt.exemptionCheck(armorAdapt.compareArmorTables(armAdt.currentArmor, armAdt.itemStorage))
	--sb.logInfo("mismatchTable edit is %s", armAdt_mismatch)
	if type(armAdt_mismatch) == "table" then
		armAdt.updateFlag = false
	else
		armAdt.updateFlag = true
		if armAdt.flags[1] == 1 then
			status.removeEphemeralEffect("armorAdapt_resetTrigger")
			armAdt.flags[1] = 0
		end
	end
	
	if stseffact("armorAdapt_resetTrigger") and armAdt.flags[1] == 0 then
		armAdt.updateFlag = false
		armAdt.flags[1] = 1
	end
	
	if armAdt.updateFlag == false then
		armorAdapt.getSpeciesBodyTable(armAdt.classType)
		
		armAdt.statusFolder = "none"
		armAdt.classFolders = util.mergeTable({}, armAdt.classStorage)
		armAdt.subTypeFolders = util.mergeTable({}, armAdt.subTypeStorage)
		
		armorAdapt.transformativeEffects()
		
		if armAdt.flags[4] == 0 and (armAdt_Config.showPlayerArmor == true) then
			inflg("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", armAdt.currentArmor[1], armAdt.currentArmor[2], armAdt.currentArmor[3], armAdt.currentArmor[4], armAdt.currentArmor[5], armAdt.currentArmor[6], armAdt.currentArmor[7], armAdt.currentArmor[8])
			armAdt.flags[4] = 1
		end
		
		armorAdapt.slotUpdate()
		armAdt.firstUpdate = false
		armorAdapt_outfitErrorCheck(3)
		armorAdapt_outfitErrorCheck(4)
	end
end

function uninit()
	baseUnInit()
	if armAdt_Config.showShutDown == true then
		inflg("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
	status.removeEphemeralEffect("hotHolidayEvent")
end

function armorAdapt_outfitErrorCheck(slotC)
	if armAdt.currentArmor[slotC] ~= nil then
		if rarmAdt.currentArmor[slotC].parameters.itemTags ~= nil then
			if armAdt.currentArmor[slotC].parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				player.radioMessage("armorAdaptOutfitError", 2)	
			end
		end
	end
end