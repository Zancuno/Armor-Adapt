require "/scripts/util.lua"
require "/scripts/armorAdapt/armorAdaptUtil.lua"
require "/armorAdapt/armorAdaptBuilder.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
function init()
	baseInit()
	armAdt_Config = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	armAdt_MinDrtv = armAdt_Config.adaptDirectivesMin
	eqpitm = npc.setItemSlot
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
	if armAdt_Config.showStartUp == true then
		inflg("[Armor Adapt][Npc Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][Npc Handler]: Starting equipment check for adaptable items.")
	end
	if armorAdaptVersionNumber == nil or armorAdaptVersionNumber ~= armAdt_Config.armorAdaptBuilderVersion then
		require("/scripts/armorAdapt/armorAdaptV1Util.lua")
	else
		require("/scripts/armorAdapt/armorAdaptV2Util.lua")
	end
	armAdt = {
		firstUpdate = true,
		updateFlag = true,
		initSpecies = npc.species(),
		entity = "Npc",
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
	status.removeEphemeralEffect("hotHolidayEvent")
end



function update(dt)
	baseUpdate(dt)
	
	armAdt.currentArmor = armorAdapt.generateNpcArmorTable()
	armAdt_mismatch = true
	armAdt_mismatch = armorAdapt.exemptionCheck(armorAdapt.compareArmorTables(armAdt.currentArmor, armAdt.itemStorage))
	if type(armAdt_mismatch) == "table" then
		armAdt.updateFlag = false
	else
		armAdt.updateFlag = true
		if armAdt.flags[1] then
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
		
		if armAdt.flags[4] == 0 and (armAdt_Config.showNpcArmor == true) then
			inflg("[Armor Adapt][Npc Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", armAdt.currentArmor[1], armAdt.currentArmor[2], armAdt.currentArmor[3], armAdt.currentArmor[4], armAdt.currentArmor[5], armAdt.currentArmor[6], armAdt.currentArmor[7], armAdt.currentArmor[8])
			armAdt.flags[4] = 1
		end

		armorAdapt.slotUpdate()
		armAdt.firstUpdate = false
		armorAdapt_outfitErrorCheck(3)
		armorAdapt_outfitErrorCheck(4)
	end
end

function armorAdapt_outfitErrorCheck(slotC)
	if armAdt.currentArmor[slotC] ~= nil then
		if root.itemConfig(armAdt.currentArmor[slotC]).parameters.itemTags ~= nil then
			if root.itemConfig(armAdt.currentArmor[slotC]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
			end
		end
	end
end