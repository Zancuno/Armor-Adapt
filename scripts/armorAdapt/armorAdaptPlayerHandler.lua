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
	
	--var table to avoid overriding values
	armAdt = {
		updateFlag = true,
		initSpecies = player.species(),
		entity = "Player",
		statusFolders = { "none", "none", "none", "none", "none", "none", "none", "none" },
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
	
	--get species body class settings
	armorAdapt.speciesConfig()
	armAdt.classStorage = util.mergeTable({}, armAdt.classFolders)
	
	--remove holiday event effects that may linger
	status.clearPersistentEffects("rentekHolidayEffects")
	
	--modified client check and also out of date detector for build script if modified client
	if root["assetOrigin"] == nil then
	
		inflg("[Armor Adapt] Missing image errors will unfortunately plague the log due to image checking. If you want to clean the log of these errors, I recommend using Star Extensions or Open Starbound.")
		
	elseif root["assetOrigin"] then
		if armorAdabtBuilderVersion == nil or armorAdabtBuilderVersion ~= armAdt_Config.armorAdaptBuilderVersion then
		
			player.radioMessage("armorAdaptBuilderCompatibility", 10)
			sb.logError("[Armor Adapt]: A mod named %s has an outdated build script for Armor Adapt. The steam workshop link for this mod is %s. Please advise the developer to remove the builder from their files and items. It is no longer needed and will just fill the item with unnecessary bloat. [modified client installed has allowed this message]", 
			root.assetSourcePaths(true)[root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")].friendlyName,
			root.assetSourcePaths(true)[root.assetOrigin("/armorAdapt/armorAdaptBuilder.lua")].link)
		end
	end
end

function update(dt)
	baseUpdate(dt)

	--getting equipment list
	armAdt.currentArmor = armorAdapt.generatePlayerArmorTable()
	armAdt_mismatch = true
	
	--checking outfits against a stored table for mismatch, exempting select items
	armAdt_mismatch = armorAdapt.exemptionCheck(armorAdapt.compareArmorTables(armAdt.currentArmor, armAdt.itemStorage))
	
	--checking flag conditions to reset or turn update on
	if type(armAdt_mismatch) == "table" then
		armAdt.updateFlag = false
	else
		armAdt.updateFlag = true
		if armAdt.flags[1] == 1 then
			status.removeEphemeralEffect("armorAdapt_resetTrigger")
			armAdt.flags[1] = 0
		end
	end
	
	--checking to see if transformative status effects have forced update
	if stseffact("armorAdapt_resetTrigger") and armAdt.flags[1] == 0 then
		armAdt.updateFlag = false
		armAdt_mismatch = { 1, 2, 3, 4, 5, 6, 7, 8 }
		armAdt_mismatch = armorAdapt.exemptionCheck(armAdt_mismatch)
		armAdt.flags[1] = 1
	end
	
	if armAdt.updateFlag == false then
	
		--script is alive, getting body sub type settings
		armorAdapt.getSpeciesBodyTable(armAdt.classType)
		
		armAdt.hideBody = "showBody"
		armAdt.statusFolders = { "none", "none", "none", "none", "none", "none", "none", "none" }
		armAdt.classFolders = util.mergeTable({}, armAdt.classStorage)
		
		--changing body class, body sub type, and or item settings if transformative effects are active
		armorAdapt.transformativeEffects()
		
		armorAdapt.showEquippedLog()
		
		--equipping modified items in outfit slots and or updating stored table to prevent looping
		armorAdapt.slotUpdate()
	end
end

function uninit()
	baseUnInit()	
	armorCheck = armorAdapt.generatePlayerArmorTable()
	armorAdapt.postCleanup(armorCheck)

	if armAdt_Config.showShutDown == true then
		inflg("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
	status.removeEphemeralEffect("hotHolidayEvent")
end