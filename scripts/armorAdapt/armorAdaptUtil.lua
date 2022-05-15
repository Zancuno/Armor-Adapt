armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	local adtItmMtch = root.itemDescriptorsMatch
	if
		adtItmMtch(a[1], b[1], true) and
		adtItmMtch(a[2], b[2], true) and 
		adtItmMtch(a[3], b[3], true) and
		adtItmMtch(a[4], b[4], true) and
		adtItmMtch(a[5], b[5], true) and
		adtItmMtch(a[6], b[6], true) and
		adtItmMtch(a[7], b[7], true) and
		adtItmMtch(a[8], b[8], true) then
		return true
	else
		return false
	end
end

function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, hideBody, entity)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	local adtPth = "/items/armors/armorAdapt/"
	adaptDirectivesMin = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptDirectivesMin")
	if rtCfg(baseItem).parameters.directives ~= nil and string.len(rtCfg(baseItem).parameters.directives) >= adaptDirectivesMin or rtCfg(baseItem).config.builder == "/sys/stardust/cosplay/build.lua" then
		adaptItem = baseItem
		armorAdapt.showCustomSkipLog(entity)
		return adaptItem
	elseif rtCfg(baseItem).parameters.itemTags ~= nil and rtCfg(baseItem).parameters.itemTags[2] == species and rtCfg(baseItem).parameters.itemTags[3] == bodyType then
		adaptItem = baseItem
		return adaptItem
	elseif rtCfg(baseItem).parameters.itemTags == nil or rtCfg(baseItem).parameters.itemTags[2] ~= species or rtCfg(baseItem).parameters.itemTags[3] ~= bodyType then 
		armorAdapt.showItemLog(baseItem, entity)
		local adaptItem = copy(baseItem)
		local baseName = rtCfg(baseItem).config.itemName
		if key == 1 or key == 2 then
			if species == "null" then
				adaptItem.parameters.maleFrames = "/items/armors/armorAdapt/default/null/Default/headf.png"
				adaptItem.parameters.femaleFrames = "/items/armors/armorAdapt/default/null/Default/headf.png"
				adaptItem.parameters.mask = "mask.png"
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "head", baseName }
				sb.logInfo("Head item name is %s", baseName)
				
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			else
				adaptItem.parameters.maleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/headm.png"
				adaptItem.parameters.femaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/headf.png"
				adaptItem.parameters.mask = "mask.png"
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "head", baseName }
				
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			end
		elseif key == 3 or key == 4 then
			if species == "null" then
				maleChestBody = "/items/armors/armorAdapt/default/null/Default/chestm.png"
				femaleChestBody = "/items/armors/armorAdapt/default/null/Default/chestf.png"
				frontArmMaleFrames = "/items/armors/armorAdapt/default/null/Default/fsleeve.png"
				backArmMaleFrames = "/items/armors/armorAdapt/default/null/Default/bsleeve.png"
				frontArmFemaleFrames = "/items/armors/armorAdapt/default/null/Default/fsleevef.png"
				backArmFemaleFrames = "/items/armors/armorAdapt/default/null/Default/bsleevef.png"
		
				adaptItem.parameters.maleFrames = { body = maleChestBody , frontSleeve = frontArmMaleFrames, backSleeve = backArmMaleFrames }

				adaptItem.parameters.femaleFrames = { body = femaleChestBody, frontSleeve = frontArmFemaleFrames, backSleeve = backArmFemaleFrames }
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "chest", baseName }
				
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			else
				maleChestBody = adtPth..species.."/"..baseName.."/"..bodyType.."/chestm.png"
				femaleChestBody = adtPth..species.."/"..baseName.."/"..bodyType.."/chestf.png"
				frontArmMaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/fsleeve.png"
				backArmMaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/bsleeve.png"
				frontArmFemaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/fsleevef.png"
				backArmFemaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/bsleevef.png"
		
				adaptItem.parameters.maleFrames = { body = maleChestBody , frontSleeve = frontArmMaleFrames, backSleeve = backArmMaleFrames }

				adaptItem.parameters.femaleFrames = { body = femaleChestBody, frontSleeve = frontArmFemaleFrames, backSleeve = backArmFemaleFrames }
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "chest", baseName }
				
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			end
			
		elseif key == 5 or key == 6 then
			if species == "null" then
				adaptItem.parameters.maleFrames = "/items/armors/armorAdapt/default/null/Default/pantsm.png"
				adaptItem.parameters.femaleFrames = "/items/armors/armorAdapt/default/null/Default/pantsf.png"

				if hideBody == false then
					adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants" }
				else
					adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants", "hideBody" }
				end
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			else
				adaptItem.parameters.maleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/pantsm.png"
				adaptItem.parameters.femaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/pantsf.png"

				if hideBody == false then
					adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants" }
				else
					adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants", "hideBody" }
				end
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			end
		else
			if species == "null" then
				adaptItem.parameters.maleFrames = "/items/armors/armorAdapt/default/null/Default/back.png"
				adaptItem.parameters.femaleFrames = "/items/armors/armorAdapt/default/null/Default/back.png"
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "back" }
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			else
				adaptItem.parameters.maleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/back.png"
				adaptItem.parameters.femaleFrames = adtPth..species.."/"..baseName.."/"..bodyType.."/back.png"
		
				adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, "back" }
				bldLg(baseItem, adaptItem, entity)
				return adaptItem
			end
		end
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
	if species == "standard" then
		bodyTable = { "Default", "Default", "Default", "Default", "Default" }
		return bodyTable
	elseif species == "lucario" then
		bodyTable = armorAdapt.getLucarioBodyType()
		return bodyTable
	end
end

function armorAdapt.getLucarioBodyType(bodyTable)
	portrait = world.entityPortrait(entity.id(), "full")
	backArm = portrait[1].image:lower()
	bodyTable = {}
	
	gender = not not (backArm:find("b1ffa7=00000000"))
	bodySpike = not not (backArm:find("eddfd4=ffffff") or backArm:find("eddfd4=000000"))
	pawSpike = not not (backArm:find("ffb34a=fefefe")) -- checks for paw spike, if false then none
	tail = backArm:find("42217b=00000000") and 1 -- Lucario
              or backArm:find("748db8=00000000") and 2 -- Riolu
              or backArm:find("6b5b88=00000000") and 3 -- Fluffy
              or 0 -- Unknown
	appendage = not backArm:find("c4ea3a=00000000")
	lucarioBody =
			(gender and "G" or "N") ..--GC for Gender, NC for Neutral, true/flase
			(bodySpike and "CS" or "") ..--blank string for has spike, NS for No Spike
			(pawSpike and "" or "NPS") ..--blank string for having paw spikes, NPS for No Paw Spike
			(tail == 1 and "L" or tail == 2 and "R" or "F") ..
			(appendage and "A" or "")
	bodyTable[1] = lucarioBody
	bodyTable[2] = "Default"
	bodyChest =
			(gender and "G" or "N") ..
			(bodySpike and "CS" or "") ..
			(pawSpike and "" or "NPS")
	bodyTable[3] = bodyChest
	bodyLegs = 
			(gender and "G" or "N") ..
			(tail == 1 and "L" or tail == 2 and "R" or "F") ..
			(appendage and "A" or "")
	bodyTable[4] = bodyLegs
	bodyTable[5] = "Default"
	
	return bodyTable

end

function armorAdapt.showItemLog(item, entity)
	local infLg = sb.logInfo
	local itmName = root.itemConfig(item).config.itemName
	local itmPara = root.itemConfig(item).parameters
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerSupportedItem") == true then
			infLg("[Armor Adapt][Player Handler]: The name for the suported item is %s", itmName)
			infLg("[Armor Adapt][Player Handler]: The parameters for the suported item are %s", itmPara)
		end
	elseif entity == "npc" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcSupportedItem") == true then
			infLg("[Armor Adapt][NPC Handler]: The name for the suported item is %s", itmName)
			infLg("[Armor Adapt][NPC Handler]: The parameters for the suported item are %s", itmPara)
		end
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem, entity)
	local infLg = sb.logInfo
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerBuildInfo") == true then
			infLg("[Armor Adapt][Player Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
			infLg("[Armor Adapt][Player Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
			infLg("[Armor Adapt][Player Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
			infLg("[Armor Adapt][Player Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

			infLg("[Armor Adapt][Player Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
			infLg("[Armor Adapt][Player Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
			infLg("[Armor Adapt][Player Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
			infLg("[Armor Adapt][Player Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
		end
	elseif entity == "npc" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcBuildInfo") == true then
			infLg("[Armor Adapt][NPC Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
			infLg("[Armor Adapt][NPC Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
			infLg("[Armor Adapt][NPC Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
			infLg("[Armor Adapt][NPC Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

			infLg("[Armor Adapt][NPC Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
			infLg("[Armor Adapt][NPC Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
			infLg("[Armor Adapt][NPC Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
			infLg("[Armor Adapt][NPC Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
		end
	end
end

function armorAdapt.showCompletionLog(item, species, bodytype, entity)
	local infLg = sb.logInfo
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerBuildCompletion") == true then
			infLg("[Armor Adapt][Player Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(item).config.itemName, species, bodyType)
		end
	elseif entity == "npc" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcBuildCompletion") == true then
			infLg("[Armor Adapt][NPC Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(item).config.itemName, species, bodyType)
		end
	end
end


function armorAdapt.showCustomSkipLog(entity)
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showCustomItemSkip") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Custom Directives based item detected, skipping conversion.")
		end
	end
end