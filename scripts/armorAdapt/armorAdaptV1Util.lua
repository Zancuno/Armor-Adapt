function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, armAdt_entity, adtlibrary, statusFolder, framesOverride)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	adtPth = "/items/armors/armorAdapt/"
	local keyTable = {
		{"headf", "headm", "mask"},
		{"headf", "headm", "mask"},
		{"chestf", "chestm", "chest"},
		{"chestf", "chestm", "chest"},
		{"pantsf", "pantsm"},
		{"pantsf", "pantsm"},
		{"back", "back"},
		{"back", "back"}
	}
	baseName = baseItem.config.itemName
	nullCheck = "false"
	if species == "null" then
		midPath = "/default/null/Default/"
		nullCheck = "true"
	else
		midPath = species.."/"..baseName.."/"..bodyType.."/"
	end
	if not next(baseItem.parameters) then
		baseItem.parameters.itemTags = {}
	end
		itemTagTable = baseItem.parameters.itemTags
		bodyClassCheck = baseItem.parameters.itemTags[2]
		bodySubTypeCheck = baseItem.parameters.itemTags[3]
	if itemTagTable ~= nil and bodyClassCheck == species and bodySubTypeCheck == bodyType then
		adaptItem = baseItem
		return adaptItem
	elseif itemTagTable == nil or bodyClassCheck ~= species or bodySubTypeCheck ~= bodyType then 
		armorAdapt.showItemLog(baseItem)
		local adaptItem = copy(baseItem)
		if keyTable[key][3] == "chest" then	
				adaptItem.parameters.femaleFrames = { body = adtPth..midPath..keyTable[key][1]..".png", frontSleeve = adtPth..midPath.."fsleevef.png", backSleeve = adtPth..midPath.."bsleevef.png" }
				adaptItem.parameters.maleFrames = { body = adtPth..midPath..keyTable[key][2]..".png", frontSleeve = adtPth..midPath.."fsleeve.png", backSleeve = adtPth..midPath.."bsleeve.png" }
		else
				adaptItem.parameters.maleFrames = adtPth..midPath..keyTable[key][3]..".png"
				adaptItem.parameters.femaleFrames = adtPth..midPath..keyTable[key][2]..".png"
		end
			adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, keyTable[key][1], baseName, armAdt_hideBody, adtlibrary }

		bldLg(baseItem, adaptItem)
		return adaptItem
	end
end

function armorAdapt.speciesConfig()
	v1Species = { 
		animalSpecies = {armAdt.initSpecies, dfltNl, dfltNl, armAdt.initSpecies, dfltNl},
		customBodySpecies = {armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies},
		customHeadChestLegSpecies = {armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, dfltSpc},
		customChestLegSpecies= {armAdt.initSpecies, dfltSpc, armAdt.initSpecies, armAdt.initSpecies, dfltSpc},
		customHeadLegSpecies = {armAdt.initSpecies, armAdt.initSpecies, dfltSpc, armAdt.initSpecies, dfltSpc},
		customLegSpecies = {armAdt.initSpecies, dfltSpc, dfltSpc, armAdt.initSpecies, dfltSpc},
		customChestSpecies= {armAdt.initSpecies, dfltSpc, armAdt.initSpecies, dfltSpc, dfltSpc},
		customHeadSpecies = {armAdt.initSpecies, armAdt.initSpecies, dfltSpc, dfltSpc, dfltSpc},
		vanillaBodySpecies = {dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc}
	}
	for _, spcEntry in ipairs(v1Species) do
		if armAdt_Config[spcEntry][armAdt.initSpecies] then
			classType = v1Species[spcEntry][1]
			classFolders[1] = v1Species[spcEntry][2]
			classFolders[2] = v1Species[spcEntry][2]
			classFolders[3] = v1Species[spcEntry][3]
			classFolders[4] = v1Species[spcEntry][3]
			classFolders[5] = v1Species[spcEntry][4]
			classFolders[6] = v1Species[spcEntry][4]
			classFolders[7] = v1Species[spcEntry][5]
			classFolders[8] = v1Species[spcEntry][5]
		end	
	end
end

function armorAdapt.getSpeciesBodyTable(speciesCheck)
	if armAdt.flags[2] == 0 and (armAdt_Config.showPlayerSpecies == true) then
		inflg("[Armor Adapt][Player Handler]: Species Recognized: %s", speciesCheck)
		armAdt.flags[2] = 1
	end
	if armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck] ~= nil then
		require(armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck])
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
	else 
		armAdt.subTypeFolders = { "Default", "Default", "Default", "Default", "Default", "Default", "Default", "Default" }
	end
		armAdt.subTypeStorage = util.mergeTable({}, armAdt.subTypeFolders)
	if armAdt.flags[3] == 0 and (armAdt_Config["show"..armAdt_entity.."BodyType"] == true) then
		inflg("[Armor Adapt]["..armAdt_entity.." Handler]: Sub Type Recognized: Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", armAdt.subTypeFolders[1], armAdt.subTypeFolders[3], armAdt.subTypeFolders[5], armAdt.subTypeFolders[7])
		armAdt.flags[3] = 1
	end
end

function armorAdapt.showItemLog(item)
	local infLg = sb.logInfo
	local itmName = root.itemConfig(item).config.itemName
	local itmPara = root.itemConfig(item).parameters
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt_entity.."SupportedItem") == true then
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The name for the suported item is %s", itmName)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The parameters for the suported item are %s", itmPara)
		inflg("[Armor Adapt]["..armAdt_entity.." Handler]: The config for the supported item is %s", root.itemConfig(item).config)
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem)
	local infLg = sb.logInfo
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt_entity.."BuildInfo") == true then
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
	end
end