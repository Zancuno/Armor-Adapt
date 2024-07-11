require "/scripts/util.lua"
require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/armorAdapt/armorAdaptBuilder.lua"

--hooking functons of other scripts sharing _ENV
local baseInit = init or function() end
local baseUpdate = update or function() end
local baseUnInit = uninit or function() end

function init()
	baseInit()
	armAdt_Config = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	
	--minimum length of directives to cause skipping
	armAdt_MinDrtv = armAdt_Config.adaptDirectivesMin
	
	--function shortening for scripts
	eqpitm = player.setEquippedItem
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	
	dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
	
	if armAdt_Config.showStartUp == true then
		inflg("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
	
	--build script version check, loads appropriate functions for the version on builder
	if armorAdabtBuilderVersion == nil or armorAdabtBuilderVersion ~= armAdt_Config.armorAdaptBuilderVersion then
		require("/scripts/armorAdapt/armorAdaptV1Util.lua")
	else
		require("/scripts/armorAdapt/armorAdaptV2Util.lua")
	end
	
	--var table to avoid overriding values
	armAdt = {
		firstUpdate = true,
		updateFlag = true,
		initSpecies = player.species(),
		entity = "Player",
		statusFolders = { "none", "none", "none", "none", "none", "none", "none", "none" },
		spriteLibrary = "default",
		frameOverrideFolder = "none",
		subTypeScript = "none",
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
	
	--get species body class settings
	armorAdapt.speciesConfig()
	armAdt.classStorage = util.mergeTable({}, armAdt.classFolders)
	
	--remove holiday event effects that may linger
	status.clearPersistentEffects("rentekHolidayEffects")
	
	--modified client check and also out of date detector for build script if modified client
	if _ENV.root["assetOrigin"] == nil then
	
		inflg("[Armor Adapt] Missing image errors will unfortunately plague the log due to image checking. If you want to clean the log of these errors, I recommend using Star Extensions or Open Starbound.")
		
	elseif _ENV.root["assetOrigin"] ~= nil then
		if armorAdabtBuilderVersion == nil or armorAdabtBuilderVersion ~= armAdt_Config.armorAdaptBuilderVersion then
		
			player.radioMessage("armorAdaptBuilderCompatibility", 10)
			sb.logError("[Armor Adapt]: A mod named %s has an outdated build script for Armor Adapt. The steam workshop link for this mod is %s. Please advise the developer to visit https://github.com/Zancuno/Armor-Adapt to get the updated file. [modified client installed has allowed this message]", 
			root.assetSourcePaths(true)[root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")].friendlyName,
			root.assetSourcePaths(true)[root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")].link)
		end
	end
end

function update(dt)
	baseUpdate(dt)

	armAdt.currentArmor = armorAdapt.generatePlayerArmorTable()
	armAdt_mismatch = true
	armAdt_mismatch = armorAdapt.exemptionCheck(armorAdapt.compareArmorTables(armAdt.currentArmor, armAdt.itemStorage))
	if type(armAdt_mismatch) == "table" then
		armAdt.updateFlag = false
	else
		armAdt.updateFlag = true
		if armAdt.flags[1] == 1 then
			status.removeEphemeralEffect("armorAdapt_resetTrigger")
			armAdt.flags[1] = 0
		end
	end
	
	if status.uniqueStatusEffectActive("armorAdapt_resetTrigger") and armAdt.flags[1] == 0 then
		armAdt.updateFlag = false
		armAdt_mismatch = { 1, 2, 3, 4, 5, 6, 7, 8 }
		armAdt_mismatch = armorAdapt.exemptionCheck(armAdt_mismatch)
		armAdt.flags[1] = 1
	end
	
	if armAdt.updateFlag == false then
		armorAdapt.getSpeciesBodyTable(armAdt.classType)
		
		armAdt.hideBody = "showBody"
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
		if armAdt.currentArmor[slotC].parameters.itemTags ~= nil then
			if armAdt.currentArmor[slotC].parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
				player.radioMessage("armorAdaptOutfitError", 2)	
			end
		end
	end
end