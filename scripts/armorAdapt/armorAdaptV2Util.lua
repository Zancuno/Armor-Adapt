function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, hideBody, entity, adtlibrary, statusFolder, framesOverride)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	baseName = rtCfg(baseItem).config.itemName
	if statusFolder ~= "none" then
		baseName = statusFolder
	end
	nullCheck = "false"
	if species == "null" then
		nullCheck = "true"
	end
	itemTagTable = rtCfg(baseItem).parameters.armorAdapt_tags
	bodyClassCheck = rtCfg(baseItem).parameters.armorAdapt_tags.bodyClass
	bodySubTypeCheck = rtCfg(baseItem).parameters.armorAdapt_tags.subType
	adaptDirectivesMin = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptDirectivesMin")
	if rtCfg(baseItem).parameters.directives ~= nil and string.len(rtCfg(baseItem).parameters.directives) >= adaptDirectivesMin or rtCfg(baseItem).config.builder == "/sys/stardust/cosplay/build.lua" then
		adaptItem = baseItem
		armorAdapt.showCustomSkipLog(entity)
		return adaptItem
	elseif itemTagTable ~= nil and bodyClassCheck == species and bodySubTypeCheck == bodyType then
		adaptItem = baseItem
		return adaptItem
	elseif itemTagTable == nil or bodyClassCheck ~= species or bodySubTypeCheck ~= bodyType then 
		armorAdapt.showItemLog(baseItem, entity)
		local adaptItem = copy(baseItem)
		adaptItem.parameters.armorAdapt_tags = {}
		if hideBody == false then
			hideBool = "hideBody"
		else
			hideBool = "showBody"
		end
		adaptItem.parameters.armorAdapt_tags["library"] = adtlibrary
		adaptItem.parameters.armorAdapt_tags["hideBool"] = hideBool
		adaptItem.parameters.armorAdapt_tags["bodyClass"] = species
		adaptItem.parameters.armorAdapt_tags["subType"] = bodyType
		adaptItem.parameters.armorAdapt_tags["nullCheck"] = nullCheck
		adaptItem.parameters.armorAdapt_tags["itemFolder"] = baseName

		bldLg(baseItem, adaptItem, entity)
		return adaptItem
	end
end

function armorAdapt.speciesConfig()
	adaptSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc
	armAdtSpriteLibrary = "default"
	
	if pcall(root.assetJson("/species/"..initSpecies..".species")["armorAdapt_settings"] ~= nil) then
		speciesSettings = root.assetJson("/species/"..initSpecies..".species:ArmorAdapt_settings")
		adaptSpecies = initSpecies
		armorSpecies = initSpecies
		adaptHeadType = speciesSettings.headFolder
		adaptChestType = speciesSettings.chestFolder
		adaptLegType = speciesSettings.legFolder
		adaptBackType = speciesSettings.backFolder
		if speciesSettings.spriteLibrary ~= "default" then
			armAdtSpriteLibrary = speciesSettings.spriteLibrary
		end
		if speciesSettings.outfitFrames ~= nil then
			frameOverrideFolder = speciesSettings.outfitFrames
		end
	else
		adaptSpecies = dfltSpc
		armorSpecies = dfltSpc
		adaptHeadType = dfltSpc
		adaptChestType = dfltSpc
		adaptLegType = dfltSpc
		adaptBackType = dfltSpc
	end
	
	v1Species = { 
		animalSpecies = {initSpecies, dfltNl, dfltNl, initSpecies, dfltNl},
		customBodySpecies = {initSpecies, initSpecies, initSpecies, initSpecies, initSpecies},
		customHeadChestLegSpecies = {initSpecies, initSpecies, initSpecies, initSpecies, dfltSpc},
		customChestLegSpecies= {initSpecies, dfltSpc, initSpecies, initSpecies, dfltSpc},
		customHeadLegSpecies = {initSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc},
		customLegSpecies = {initSpecies, dfltSpc, dfltSpc, initSpecies, dfltSpc},
		customChestSpecies= {initSpecies, dfltSpc, initSpecies, dfltSpc, dfltSpc},
		customHeadSpecies = {initSpecies, initSpecies, dfltSpc, dfltSpc, dfltSpc},
		vanillaBodySpecies = {dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc}
	}
	for _, spcEntry in ipairs(v1Species) do
		if adaptConfig[spcEntry][initSpecies] then
			adaptSpecies = v1Species[spcEntry][1]
			adaptHeadType = v1Species[spcEntry][2]
			adaptChestType = v1Species[spcEntry][3]
			adaptLegType = v1Species[spcEntry][4]
			adaptBackType = v1Species[spcEntry][5]
		end	
	end
end

function armorAdapt.getSpeciesBodyTable(speciesCheck)
	if speciesCheck == armorSpecies or speciesCheck == adaptConfig.supportedSpecies[speciesCheck] then
		if played[1] == 0 and (adaptConfig.showPlayerSpecies == true) then
			inflg("[Armor Adapt][Player Handler]: Supported Species Recognized: %s", speciesCheck)
			played[1] = 1
		end
		local scriptList = root.assetJson("/scripts/armorAdapt/armorAdapt.config:adaptSpeciesSubTypeScripts")
		if scriptList[speciesCheck] ~= nil then
			speciesScript = scriptList[speciesCheck]
			require(speciesScript)
			bodyTable = armorAdapt.speciesBodyTable()
		else 
			bodyTable = { "Default", "Default", "Default", "Default", "Default" }
		end
			bodyType,bodyHead,bodyChest,bodyLegs,bodyBack = bodyTable[1], bodyTable[2], bodyTable[3], bodyTable[4], bodyTable[5]

			storageBodyType,storageBodyHead,storageBodyChest,storageBodyLegs,storageBodyBack = bodyType, bodyHead, bodyChest, bodyLegs, bodyBack
		if entityType == "player" then
			if played[2] == 0 and (adaptConfig.showPlayerBodyType == true) then
				inflg("[Armor Adapt][Player Handler]: Sub Type Recognized: Your sub body type is %s, Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
				played[2] = 1
			end
		else
			if played[2] == 0 and (adaptConfig.showNpcBodyType == true) then
				inflg("[Armor Adapt][NPC Handler]: Sub Type Recognized: Your main body type is %s, Your head type is %s, your chest type is %s, your legs type is %s, and your back type is %s", bodyType, bodyHead, bodyChest, bodyLegs, bodyBack)
				played[2] = 1
			end
		end
	end
end

function armorAdapt.showItemLog(item, entity)
	local infLg = sb.logInfo
	local itmName = root.itemConfig(item).config.itemName
	local itmPara = root.itemConfig(item).parameters.armorAdapt_tags
	local entityTable = {}
	if entity == "player" then
		entityTable = {"Player", "Player"}
	elseif entity == "npc" then
		entityTable = {"NPC", "Npc"}
	end
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..entityTable[2].."SupportedItem") == true then
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The name for the suported item is %s", itmName)
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: The parameters for the suported item are %s", itmPara)
		inflg("[Armor Adapt]["..entityTable[1].." Handler]: The config for the supported item is %s", root.itemConfig(item).config)
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

		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Adapted item tags are %s", adaptItem.parameters.armorAdapt_tags)
	end
end