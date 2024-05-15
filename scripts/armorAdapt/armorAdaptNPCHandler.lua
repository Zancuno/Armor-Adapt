require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
local dfltSpc,dfltBdy,dfltNl = "standard", "Default", "null"
function init()
	baseInit()
	if adaptConfig.showStartUp == true then
		inflg("[Armor Adapt][NPC Handler]: Initializing Armor Adapt System")
		inflg("[Armor Adapt][NPC Handler]: Starting equipment check for adaptable items.")
	end
	if armorAdaptVersionNumber == nil or armorAdaptVersionNumber ~= adaptConfig.armorAdaptBuilderVersion then
		require("/scripts/armorAdapt/armorAdaptV1Util.lua")
	else
		require("/scripts/armorAdapt/armorAdaptV2Util.lua")
	end
	eqpitm = npc.setItemSlot
	inflg = sb.logInfo
	stseffact = status.uniqueStatusEffectActive
	
	adaptConfig = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
	played = { 0, 0, 0, 0 }
	bodyTable = { dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy }
	slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
	adaptStorageArmorTable = { dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl, dfltNl }
	
	changed = true
	hideBody = false
	entityType = "npc"
	statusFolder = "none"
	adaptUpdate = 0
	adaptEffect = "armorAdapt_null"
	initSpecies = npc.species()
	
	armorAdapt.speciesConfig()
	
	bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = bodyTable[1], bodyTable[2], bodyTable[3], bodyTable[4], bodyTable[5]
	storageAdaptSpecies, storageAdaptHeadType, storageAdaptChestType, storageAdaptLegType, storageAdaptBackType = adaptSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType
	storageBodyHead,storageBodyChest, storageBodyLegs, storageBodyBack, storageBodyType = dfltBdy, dfltBdy, dfltBdy, dfltBdy, dfltBdy
	
	status.clearPersistentEffects("rentekHolidayEffects")
	status.removeEphemeralEffect("hotHolidayEvent")
end



function update(dt)
	baseUpdate(dt)
	
	armorArmor = armorAdapt.generateNpcArmorTable()
	mismatchCheck = true
	mismatchCheck = armorAdapt.compareArmorTables(armorAdapt_NpcArmor, armorAdapt_storageArmorTable)
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
		
		if played[4] == 0 and (adaptConfig.showNpcArmor == true) then
			inflg("[Armor Adapt][NPC Handler]: The NPC currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", armorAdapt_NpcArmor[1], armorAdapt_NpcArmor[2], armorAdapt_NpcArmor[3], armorAdapt_NpcArmor[4], armorAdapt_NpcArmor[5], armorAdapt_NpcArmor[6], armorAdapt_NpcArmor[7], armorAdapt_NpcArmor[8])
			played[4] = 1
		end

		armorAdapt.slotUpdate()
		
		armorAdapt_outfitErrorCheck(3)
		armorAdapt_outfitErrorCheck(4)
	end
end

function armorAdapt_outfitErrorCheck(slotC)
	if armorAdapt_NpcArmor[slotC] ~= nil then
		if root.itemConfig(armorAdapt_NpcArmor[slotC]).parameters.itemTags ~= nil then
			if root.itemConfig(armorAdapt_NpcArmor[slotC]).parameters.itemTags[5] == nil then
				status.addEphemeralEffect("armorAdapt_resetBody")
			end
		end
	end
end