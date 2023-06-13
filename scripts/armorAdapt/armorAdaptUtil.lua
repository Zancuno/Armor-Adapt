armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	local adtItmMtch = root.itemDescriptorsMatch
	local rouletteTable = { "1", "1", "1", "1", "1", "1", "1", "1" }
	local mismatchTable = {}
	for k,v in pairs(rouletteTable) do
		if not adtItmMtch(a[k], b[k], true) then
			mismatchTable[k] = k
		end
	end

	if mismatchTable == {} then
		return true
	else
		return mismatchTable	
	end
end

function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, hideBody, entity, adtlibrary, statusFolder)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	local adtPth = "/path"
	if adtlibrary == "default" then
		adtPth = "/items/armors/armorAdapt/"
	else
		adtPth = "/items/armors/"..adtlibrary.."/"
	end
	local keyTable = {
		{"head", "headf", "headm", false, true},
		{"head", "headf", "headm", false, true},
		{"chest", "chestf", "chestm", true, false},
		{"chest", "chestf", "chestm", true, false},
		{"pants", "pantsf", "pantsm", false, false},
		{"pants", "pantsf", "pantsm", false, false},
		{"back", "back", "back", false, false},
		{"back", "back", "back", false, false}
	}
	local baseName = rtCfg(baseItem).config.itemName
	if statusFolder ~= "none"
		baseName = statusFolder
	end
	if species == "null" then
		midPath = "/default/null/Default/"
	else
		midPath = species.."/"..baseName.."/"..bodyType.."/"
	end
	if rtCfg(baseItem).config[armorAdapt_tags] ~= nil then
		tagCheck = true
	end
	adaptDirectivesMin = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptDirectivesMin")
	if rtCfg(baseItem).parameters.directives ~= nil and string.len(rtCfg(baseItem).parameters.directives) >= adaptDirectivesMin or rtCfg(baseItem).config.builder == "/sys/stardust/cosplay/build.lua" then
		adaptItem = baseItem
		armorAdapt.showCustomSkipLog(entity)
		return adaptItem
	elseif (rtCfg(baseItem).parameters.itemTags ~= nil and rtCfg(baseItem).parameters.itemTags[2] == species and rtCfg(baseItem).parameters.itemTags[3] == bodyType) or (tagCheck == true and  rtCfg(baseItem).parameters.armorAdapt_tags.bodyClass == species and rtCfg(baseItem).parameters.armorAdapt_tags.subType == bodyType) then
		adaptItem = baseItem
		return adaptItem
	elseif (rtCfg(baseItem).parameters.itemTags == nil or rtCfg(baseItem).parameters.itemTags[2] ~= species or rtCfg(baseItem).parameters.itemTags[3] ~= bodyType) or (tagCheck == true and  rtCfg(baseItem).parameters.armorAdapt_tags.bodyClass ~= species or rtCfg(baseItem).parameters.armorAdapt_tags.subType ~= bodyType) then 
		armorAdapt.showItemLog(baseItem, entity)
		local adaptItem = copy(baseItem)
		
		if keyTable[key][4] == true then
			if tagCheck == true then
				adaptItem.parameters.armorAdapt_tags.maleFrames = { body = adtPth..midPath..keyTable[key][3]..".png", frontSleeve = adtPth..midPath.."/fsleeve.png", backSleeve = adtPth..midPath.."/bsleeve.png" }
				
				adaptItem.parameters.armorAdapt_tags.femaleFrames = { body = adtPth..midPath..keyTable[key][2]..".png", frontSleeve = adtPth..midPath.."/fsleevef.png", backSleeve = adtPth..midPath.."/bsleevef.png" }
			elseif
				adaptItem.parameters.maleFrames = { body = adtPth..midPath..keyTable[key][3]..".png", frontSleeve = adtPth..midPath.."/fsleeve.png", backSleeve = adtPth..midPath.."/bsleeve.png" }
						
				adaptItem.parameters.femaleFrames = { body = adtPth..midPath..keyTable[key][2]..".png", frontSleeve = adtPth..midPath.."/fsleevef.png", backSleeve = adtPth..midPath.."/bsleevef.png" }
			end
		else
			if tagCheck == true then
				adaptItem.parameters.armorAdapt_tags.maleFrames = adtPth..midPath..keyTable[key][3]..".png"
				adaptItem.parameters.armorAdapt_tags.femaleFrames = adtPth..midPath..keyTable[key][2]..".png"
			else
				adaptItem.parameters.maleFrames = adtPth..midPath..keyTable[key][3]..".png"
				adaptItem.parameters.femaleFrames = adtPth..midPath..keyTable[key][2]..".png"
			end
		end

		if keyTable[key][5] == true then
			if tagCheck == true then
				adaptItem.parameters.armorAdapt_tags.mask = adtPth..midPath.."mask.png"
			else
				adaptItem.parameters.mask = "mask.png"
			end
		end

		if hideBody == false then
			if tagCheck == true then
				adaptItem.parameters.armorAdapt_tags[library] = adtlibrary
				adaptItem.parameters.armorAdapt_tags[hideBool] = "showBody"
				adaptItem.parameters.armorAdapt_tags[bodyClass] = species
				adaptItem.parameters.armorAdapt_tags[subType] = bodyType
			else
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, keyTable[key][1], baseName, "showBody", adtlibrary }
			end
		else
			if tagCheck == true then
				adaptItem.parameters.armorAdapt_tags[library] = adtlibrary
				adaptItem.parameters.armorAdapt_tags[hideBool] = "hideBody"
				adaptItem.parameters.armorAdapt_tags[bodyClass] = species
				adaptItem.parameters.armorAdapt_tags[subType] = bodyType
			else
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, keyTable[key][1], baseName, "hideBody", adtlibrary }
			end
		end
		bldLg(baseItem, adaptItem, entity)
		return adaptItem
	end
end

function armorAdapt.generatePlayerArmorTable(adaptPlayerArmor)
	adaptPlayerArmor = {}
	local plrItm = player.equippedItem
	adaptPlayerArmor[1] = plrItm("head")
	adaptPlayerArmor[2] = plrItm("headCosmetic")
	adaptPlayerArmor[3] = plrItm("chest")
	adaptPlayerArmor[4] = plrItm("chestCosmetic")
	adaptPlayerArmor[5] = plrItm("legs")
	adaptPlayerArmor[6] = plrItm("legsCosmetic")
	adaptPlayerArmor[7] = plrItm("back")
	adaptPlayerArmor[8] = plrItm("backCosmetic")
	return adaptPlayerArmor
end

function armorAdapt.generateNpcArmorTable(adaptNpcArmor)
	adaptNpcArmor = {}
	local npcItm = npc.getItemSlot
	adaptNpcArmor[1] = npcItm("head")
	adaptNpcArmor[2] = npcItm("headCosmetic")
	adaptNpcArmor[3] = npcItm("chest")
	adaptNpcArmor[4] = npcItm("chestCosmetic")
	adaptNpcArmor[5] = npcItm("legs")
	adaptNpcArmor[6] = npcItm("legsCosmetic")
	adaptNpcArmor[7] = npcItm("back")
	adaptNpcArmor[8] = npcItm("backCosmetic")
	return adaptNpcArmor
end

function armorAdapt.getSpeciesBodyTable(species)
	for listSpecies, speciesScript in ipairs(root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptSpeciesSubTypeScripts")) do
		if species == "standard" then
			bodyTable = { "Default", "Default", "Default", "Default", "Default" }
			return bodyTable
		elseif species == "lucario" then
			bodyTable = armorAdapt.getLucarioBodyType()
			return bodyTable
		elseif species == listSpecies then
			require(speciesScript)
			bodyTable = armorAdapt.speciesBodyTable()
			return bodyTable
		end
	end
end

function armorAdapt.getLucarioBodyType(bodyTable)
	portrait = world.entityPortrait(entity.id(), "full")
	backArm = portrait[1].image:lower()
	bodyTable = {}
	
	gender = not not (backArm:find("b1ffa7=00000000"))
	bodySpike = not not (backArm:find("eddfd4=ffffff") or backArm:find("eddfd4=000000"))
	pawSpike = not not (backArm:find("ffb34a=ffffff")) -- checks for paw spike, if false then none
	tail = backArm:find("42217b=00000000") and 1 -- Lucario
              or backArm:find("748db8=00000000") and 2 -- Riolu
              or backArm:find("6b5b88=00000000") and 3 -- Fluffy
              or 0 -- Unknown
	appendage = not backArm:find("c4ea3a=00000000")
	lucarioBody =
			(gender and "G" or "N")..(bodySpike and "CS" or "")..(pawSpike and "" or "NPS")..(tail == 1 and "L" or tail == 2 and "R" or "F")..(appendage and "A" or "")
	bodyTable[1] = lucarioBody
	bodyTable[2] = "Default"
	bodyChest = (gender and "G" or "N")..(bodySpike and "CS" or "")..(pawSpike and "" or "NPS")
	bodyTable[3] = bodyChest
	bodyLegs = (gender and "G" or "N")..(tail == 1 and "L" or tail == 2 and "R" or "F")..(appendage and "A" or "")
	bodyTable[4] = bodyLegs
	bodyTable[5] = "Default"
	
	return bodyTable
end

function armorAdapt.showItemLog(item, entity)
	local infLg = sb.logInfo
	local itmName = root.itemConfig(item).config.itemName
	local itmPara = root.itemConfig(item).parameters
	local entityTable = {}
	if entity == "player" then
		entityTable = {"Player", "Player"}
	elseif entity == "npc" then
		entityTable = {"NPC", "Npc"}
	end
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..entityTable[2].."SupportedItem") == true then
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The name for the suported item is %s", itmName)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The parameters for the suported item are %s", itmPara)
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem, entity)
	local infLg = sb.logInfo
	local entityTable = {}
	if entity == "player" then
		entityTable = {"Player", "Player"}
	elseif entity == "npc" then
		entityTable = {"NPC", "Npc"}
	end
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..entityTable[2].."BuildInfo") == true then
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
	end
end

function armorAdapt.showCompletionLog(item, species, bodytype, entity)
	local infLg = sb.logInfo
	local entityTable = {}
	if entity == "player" then
		entityTable = {"Player", "Player"}
	elseif entity == "npc" then
		entityTable = {"NPC", "Npc"}
	end
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..entityTable[2].."BuildCompletion") == true then
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Item %s has sucessfully been adapted to the species %s and the sub type %s", root.itemConfig(item).config.itemName, species, bodyType)
	end
end


function armorAdapt.showCustomSkipLog(entity)
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showCustomItemSkip") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Custom Directives based item detected, skipping conversion.")
		end
	end
end

function armorAdapt.v1EffectUpdate(effCfg, bodyType, bodyHead, bodyChest, bodyLegs, bodyBack, strg1, strg2, strg3, strg4, strg5, forceBool)
	local bodyList = {bodyHead, bodyChest, bodyLegs, bodyBack}
	local bodyListStorage{strg2, strg3, strg4, strg5}
	for _, effVal in ipairs(effCfg) do
		if status.uniqueStatusEffectActive(effVal) then
			for listRun = 4, 1, -1 do
				if forceBool == true and strg1 ~= bodyType then
					bodyType = strg1
				end
				bodyType = bodyType..effVal
				if bodyList[listRun] ~= nil then
					if forceBool == true and strg1 ~= bodyType then
						bodyList[listRun] = bodyListStorage[listRun]
					end
					bodyList[listRun] = bodyList[listRun]..effVal
				end
			end
		end
	end
end

function armorAdapt.v1SpeciesFill(specTable, spec1, spec2, spec3, spec4, spec5)
	for _,specValue in ipairs(specTable) do
		if player.species() == specValue then
			playerSpecies = spec1
			adaptHeadType = spec2
			adaptChestType = spec3
			adaptLegType = spec4
			adaptBackType = spec5
		end
	end
end