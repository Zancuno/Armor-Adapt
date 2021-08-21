armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	if
		root.itemDescriptorsMatch(a[1], b[1], true) and
		root.itemDescriptorsMatch(a[2], b[2], true) and 
		root.itemDescriptorsMatch(a[3], b[3], true) and
		root.itemDescriptorsMatch(a[4], b[4], true) and
		root.itemDescriptorsMatch(a[5], b[5], true) and
		root.itemDescriptorsMatch(a[6], b[6], true) and
		root.itemDescriptorsMatch(a[7], b[7], true) and
		root.itemDescriptorsMatch(a[8], b[8], true) then
		return true
	else
		return false
	end
end

function armorAdapt.runPlayerAdapt(baseItem, key, species, bodyType, hideBody)
	adaptDirectivesMin = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptDirectivesMin")
	if root.itemConfig(baseItem).parameters.directives ~= nil and string.len(root.itemConfig(baseItem).parameters.directives) >= adaptDirectivesMin then
		adaptArmorNpcItem = baseItem
		sb.logInfo("[Armor Adapt][Player Handler]: Custom Directives based item detected, skipping conversion.")
		return adaptArmorNpcItem
	elseif root.itemConfig(baseItem).parameters.itemTags ~= nil and root.itemConfig(baseItem).parameters.itemTags[2] == species and root.itemConfig(baseItem).parameters.itemTags[3] == bodyType then
		adaptArmorPlayerItem = baseItem
		return adaptArmorPlayerItem
	elseif root.itemConfig(baseItem).parameters.itemTags == nil or root.itemConfig(baseItem).parameters.itemTags[2] ~= species or root.itemConfig(baseItem).parameters.itemTags[3] ~= bodyType then 
		armorAdapt.showPlayerItemLog(baseArmorItem)
		local adaptArmorPlayerItem = copy(baseItem)
		if key == 1 or key == 2 then
			adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerHeadItem(adaptArmorPlayerItem, species, bodyType)
			armorAdapt.showPlayerBuildLog(baseItem, adaptArmorPlayerItem)
			return adaptArmorPlayerItem
		elseif key == 3 or key == 4 then
			adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerChestItem(adaptArmorPlayerItem, species, bodyType)
			armorAdapt.showPlayerBuildLog(baseItem, adaptArmorPlayerItem)
			return adaptArmorPlayerItem
		elseif key == 5 or key == 6 then
			adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerPantsItem(adaptArmorPlayerItem, species, bodyType, hideBody)
			armorAdapt.showPlayerBuildLog(baseItem, adaptArmorPlayerItem)
			return adaptArmorPlayerItem
		else
			adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerBackItem(adaptArmorPlayerItem, species, bodyType)
			armorAdapt.showPlayerBuildLog(baseItem, adaptArmorPlayerItem)
			return adaptArmorPlayerItem
		end
	end
end

function armorAdapt.runNpcAdapt(baseItem, key, species, bodyType, hideBody)
	adaptDirectivesMin = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptDirectivesMin")
	if root.itemConfig(baseItem).parameters.directives ~= nil and string.len(root.itemConfig(baseItem).parameters.directives) >= adaptDirectivesMin then
		adaptArmorNpcItem = baseItem
		sb.logInfo("[Armor Adapt][NPC Handler]: Custom Directives based item detected, skipping conversion.")
		return adaptArmorNpcItem
	elseif root.itemConfig(baseItem).parameters.itemTags ~= nil and root.itemConfig(baseItem).parameters.itemTags[2] == species and root.itemConfig(baseItem).parameters.itemTags[3] == bodyType then
		adaptArmorNpcItem = baseItem
		return adaptArmorNpcItem
	elseif root.itemConfig(baseItem).parameters.itemTags == nil or root.itemConfig(baseItem).parameters.itemTags[2] ~= species or root.itemConfig(baseItem).parameters.itemTags[3] ~= bodyType then 
		armorAdapt.showNpcItemLog(baseArmorItem)
		local adaptArmorNpcItem = copy(baseItem)
		if key == 1 or key == 2 then
			adaptArmorNpcItem = armorAdapt.generateAdaptedNpcHeadItem(adaptArmorNpcItem, species, bodyType)
			armorAdapt.showNpcBuildLog(baseItem, adaptArmorNpcItem)
			return adaptArmorNpcItem
		elseif key == 3 or key == 4 then
			adaptArmorNpcItem = armorAdapt.generateAdaptedNpcChestItem(adaptArmorNpcItem, species, bodyType)
			armorAdapt.showNpcBuildLog(baseItem, adaptArmorNpcItem)
			return adaptArmorNpcItem
		elseif key == 5 or key == 6 then
			adaptArmorNpcItem = armorAdapt.generateAdaptedNpcPantsItem(adaptArmorNpcItem, species, bodyType, hideBody)
			armorAdapt.showNpcBuildLog(baseItem, adaptArmorNpcItem)
			return adaptArmorNpcItem
		else
			adaptArmorNpcItem = armorAdapt.generateAdaptedNpcBackItem(adaptArmorNpcItem, species, bodyType)
			armorAdapt.showNpcBuildLog(baseItem, adaptArmorNpcItem)
			return adaptArmorNpcItem
		end
	end
end

function armorAdapt.generateAdaptedPlayerHeadItem(adaptArmorPlayerItem, species, bodyType)

	adaptArmorPlayerItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/head.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	adaptArmorPlayerItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/head.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	adaptArmorPlayerItem.parameters.mask = string.format("/items/armors/armorAdapt/%s/%s/%s/mask.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	
	adaptArmorPlayerItem.parameters.itemTags = { "armorAdapted", species, bodyType, "head" }

	return adaptArmorPlayerItem
end

function armorAdapt.generateAdaptedPlayerChestItem(adaptArmorPlayerItem, species, bodyType)

	maleChestBody = string.format("/items/armors/armorAdapt/%s/%s/%s/chestm.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	femaleChestBody = string.format("/items/armors/armorAdapt/%s/%s/%s/chestf.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	frontArmFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/fsleeve.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	backArmFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/bsleeve.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	adaptArmorPlayerItem.parameters.maleFrames = { body = maleChestBody , frontSleeve = frontArmFrames, backSleeve = backArmFrames }

	adaptArmorPlayerItem.parameters.femaleFrames = { body = femaleChestBody, frontSleeve = frontArmFrames, backSleeve = backArmFrames }
	
	adaptArmorPlayerItem.parameters.itemTags = { "armorAdapted", species, bodyType, "chest" }

	return adaptArmorPlayerItem
end

function armorAdapt.generateAdaptedPlayerPantsItem(adaptArmorPlayerItem, species, bodyType, hideBody)

	adaptArmorPlayerItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/pantsm.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	adaptArmorPlayerItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/pantsf.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)

	if hideBody == false then
		adaptArmorPlayerItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants" }
	else
		adaptArmorPlayerItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants", "hideBody" }
	end

	return adaptArmorPlayerItem
end

function armorAdapt.generateAdaptedPlayerBackItem(adaptArmorPlayerItem, species, bodyType)

	adaptArmorPlayerItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/back.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	adaptArmorPlayerItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/back.png", species, root.itemConfig(adaptArmorPlayerItem).config.itemName, bodyType)
	
	adaptArmorPlayerItem.parameters.itemTags = { "armorAdapted", species, bodyType, "back" }

	return adaptArmorPlayerItem
end

function armorAdapt.generateAdaptedNpcHeadItem(adaptArmorNpcItem, species, bodyType)

	adaptArmorNpcItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/head.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	adaptArmorNpcItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/head.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	adaptArmorNpcItem.parameters.mask = string.format("/items/armors/armorAdapt/%s/%s/%s/mask.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	
	adaptArmorNpcItem.parameters.itemTags = { "armorAdapted", species, bodyType, "head" }

	return adaptArmorNpcItem
end

function armorAdapt.generateAdaptedNpcChestItem(adaptArmorNpcItem, species, bodyType)

	maleChestBody = string.format("/items/armors/armorAdapt/%s/%s/%s/chestm.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	femaleChestBody = string.format("/items/armors/armorAdapt/%s/%s/%s/chestf.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	frontArmFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/fsleeve.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	backArmFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/bsleeve.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	adaptArmorNpcItem.parameters.maleFrames = { body = maleChestBody , frontSleeve = frontArmFrames, backSleeve = backArmFrames }

	adaptArmorNpcItem.parameters.femaleFrames = { body = femaleChestBody, frontSleeve = frontArmFrames, backSleeve = backArmFrames }
	
	adaptArmorNpcItem.parameters.itemTags = { "armorAdapted", species, bodyType, "chest" }

	return adaptArmorNpcItem
end

function armorAdapt.generateAdaptedNpcPantsItem(adaptArmorNpcItem, species, bodyType, hideBody)

	adaptArmorNpcItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/pantsm.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	adaptArmorNpcItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/pantsf.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)

	if hideBody == false then
		adaptArmorNpcItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants" }
	else 
		adaptArmorNpcItem.parameters.itemTags = { "armorAdapted", species, bodyType, "pants", "hideBody" }
	end
	return adaptArmorNpcItem
end

function armorAdapt.generateAdaptedNpcBackItem(adaptArmorNpcItem, species, bodyType)

	adaptArmorNpcItem.parameters.maleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/back.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	adaptArmorNpcItem.parameters.femaleFrames = string.format("/items/armors/armorAdapt/%s/%s/%s/back.png", species, root.itemConfig(adaptArmorNpcItem).config.itemName, bodyType)
	
	adaptArmorNpcItem.parameters.itemTags = { "armorAdapted", species, bodyType, "back" }

	return adaptArmorNpcItem
end

function armorAdapt.generatePlayerArmorTable(adaptPlayerArmor)
	adaptPlayerArmor = {}
	
	adaptPlayerArmor[1] = player.equippedItem("head")
	adaptPlayerArmor[2] = player.equippedItem("headCosmetic")
	adaptPlayerArmor[3] = player.equippedItem("chest")
	adaptPlayerArmor[4] = player.equippedItem("chestCosmetic")
	adaptPlayerArmor[5] = player.equippedItem("legs")
	adaptPlayerArmor[6] = player.equippedItem("legsCosmetic")
	adaptPlayerArmor[7] = player.equippedItem("back")
	adaptPlayerArmor[8] = player.equippedItem("backCosmetic")
	return adaptPlayerArmor
end

function armorAdapt.generateNpcArmorTable(adaptNpcArmor)
	adaptNpcArmor = {}
	
	adaptNpcArmor[1] = npc.getItemSlot("head")
	adaptNpcArmor[2] = npc.getItemSlot("headCosmetic")
	adaptNpcArmor[3] = npc.getItemSlot("chest")
	adaptNpcArmor[4] = npc.getItemSlot("chestCosmetic")
	adaptNpcArmor[5] = npc.getItemSlot("legs")
	adaptNpcArmor[6] = npc.getItemSlot("legsCosmetic")
	adaptNpcArmor[7] = npc.getItemSlot("back")
	adaptNpcArmor[8] = npc.getItemSlot("backCosmetic")
	return adaptNpcArmor
end

function armorAdapt.getSpeciesBodyTable(species)
	if species == "standard" then
		bodyTable = { "Default", "standard", "None", "None", "None" }
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
	if gender and true then
		bodyShape = "Gendered"
	else
		bodyShape = "Neutral"
	end
	bodyTable[2] = bodyShape
	if bodySpike and true and pawSpike and true then
		bodyAccessory = "Fully Spiked"
	elseif bodySpike and true and pawSpike and false then
		bodyAccessory = "Chest Spike"
	elseif bodySpike and false and pawSpike and true then
		bodyAccessory = "Paw Spikes"
	else
		bodyAccessory = "Bare"
	end
	bodyTable[3] = bodyAccessory
	if tail == 1 then
		bodyAlt = "Lucario Tail"
	elseif tail == 2 then
		bodyAlt = "Riolu Tail"
	else
		bodyAlt = "fluffy Tail"
	end
	bodyTable[4] = bodyAlt
	if appendage and true then
		bodyOther = "Head Locks"
	else
		bodyOther = "None"
	end
	bodyTable[5] = bodyOther
	
	return bodyTable

end

function armorAdapt.showPlayerItemLog(item)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerSupportedItem") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: The name for the suported item is %s", root.itemConfig(item).config.itemName)
		sb.logInfo("[Armor Adapt][Player Handler]: The parameters for the suported item are %s", root.itemConfig(item).parameters)

	end
end

function armorAdapt.showPlayerBuildLog(baseItem, adaptItem)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerBuildInfo") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		sb.logInfo("[Armor Adapt][Player Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		sb.logInfo("[Armor Adapt][Player Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
		sb.logInfo("[Armor Adapt][Player Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

		sb.logInfo("[Armor Adapt][Player Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
		sb.logInfo("[Armor Adapt][Player Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
		sb.logInfo("[Armor Adapt][Player Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
		sb.logInfo("[Armor Adapt][Player Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
	end
end

function armorAdapt.showPlayerCompletionLog(item, species, bodytype)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showPlayerBuildCompletion") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(item).config.itemName, species, bodyType)
	end
end

function armorAdapt.showNpcItemLog(item)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcSupportedItem") == true then
		sb.logInfo("[Armor Adapt][NPC Handler]: The name for the suported item is %s", root.itemConfig(item).config.itemName)
		sb.logInfo("[Armor Adapt][NPC Handler]: The parameters for the suported item are %s", root.itemConfig(item).parameters)

	end
end

function armorAdapt.showNpcBuildLog(baseItem, adaptItem)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcBuildInfo") == true then
		sb.logInfo("[Armor Adapt][NPC Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		sb.logInfo("[Armor Adapt][NPC Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		sb.logInfo("[Armor Adapt][NPC Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
		sb.logInfo("[Armor Adapt][NPC Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

		sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
		sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
		sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
		sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
	end
end

function armorAdapt.showNpcCompletionLog(item, species, bodytype)
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showNpcBuildCompletion") == true then
		sb.logInfo("[Armor Adapt][NPC Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(item).config.itemName, species, bodyType)
	end
end