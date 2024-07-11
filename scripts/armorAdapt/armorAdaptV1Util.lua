function armorAdapt.runArmorAdapt(baseItem, key, bodyClass, subType, adtlibrary)
	--param build for items to be passed to the builder, legacy version. Returns to script that equips item
	
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	adtPth = "/items/armors/armorAdapt/"
	
	--table of outfit slot settings
	local keyTable = {
		{"headf", "headm", "head"},
		{"headf", "headm", "head"},
		{"chestf", "chestm", "chest"},
		{"chestf", "chestm", "chest"},
		{"pantsf", "pantsm", "pants"},
		{"pantsf", "pantsm", "pants"},
		{"back", "back", "back"},
		{"back", "back", "back"}
	}
	baseName = baseItem.name
	nullCheck = "false"
	
	--checking for animal species or species without limbs to assrt blank images, building path snippet accordingly
	if bodyClass == "null" then
		midPath = "default/null/Default/"
		nullCheck = "true"
	else
		midPath = bodyClass.."/"..baseName.."/"..subType.."/"
	end
	
	--checking if item tags exists prior, creates to not cause script abort
	if not next(baseItem.parameters) or baseItem.parameters.itemTags == nil then
		baseItem.parameters.itemTags = {}
	end
		itemTagTable = baseItem.parameters.itemTags
		bodyClassCheck = baseItem.parameters.itemTags[2]
		bodySubTypeCheck = baseItem.parameters.itemTags[3]
		
	--param building, will force fresh param build if first run
	if armAdt.firstUpdate == false and itemTagTable ~= nil and bodyClassCheck == bodyClass and bodySubTypeCheck == subType then
		adaptItem = baseItem
		return adaptItem
	elseif armAdt.firstUpdate == true or itemTagTable == nil or bodyClassCheck ~= bodyClass or bodySubTypeCheck ~= subType then
		armorAdapt.showItemLog(baseItem)
		local adaptItem = copy(baseItem)
		
		--legacy, constructing paths to feed into legacy builder
		if keyTable[key][3] == "chest" then	
				adaptItem.parameters.femaleFrames = { body = adtPth..midPath..keyTable[key][1]..".png", frontSleeve = adtPth..midPath.."fsleevef.png", backSleeve = adtPth..midPath.."bsleevef.png" }
				adaptItem.parameters.maleFrames = { body = adtPth..midPath..keyTable[key][2]..".png", frontSleeve = adtPth..midPath.."fsleeve.png", backSleeve = adtPth..midPath.."bsleeve.png" }
		else
				adaptItem.parameters.maleFrames = adtPth..midPath..keyTable[key][2]..".png"
				adaptItem.parameters.femaleFrames = adtPth..midPath..keyTable[key][1]..".png"
		end
			adaptItem.parameters.itemTags = { "armorAdapted", bodyClass, subType, keyTable[key][3], baseName, armAdt.hideBody, adtlibrary }
		
		bldLg(baseItem, adaptItem)
		return adaptItem
	end
end

function armorAdapt.speciesConfig()
	--building species body class settings, lacking species file check due to legacy
	
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
	--checks if a species has a script to build body sub type settings or provide defaults. Lacks ability to check species file due to legacy.

	if armAdt.flags[2] == 0 and (armAdt_Config.showPlayerSpecies == true) then
		inflg("[Armor Adapt][Player Handler]: Species Recognized: %s", speciesCheck)
		armAdt.flags[2] = 1
	end
	
	--runs script from armorAdapt.config if species has listed it
	if armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck] ~= nil then
		require(armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck])
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
	else 
		armAdt.subTypeFolders = { "Default", "Default", "Default", "Default", "Default", "Default", "Default", "Default" }
	end
	
	--store a backup of settings
	armAdt.subTypeStorage = util.mergeTable({}, armAdt.subTypeFolders)
	
	if armAdt.flags[3] == 0 and (armAdt_Config["show"..armAdt.entity.."BodyType"] == true) then
		inflg("[Armor Adapt]["..armAdt.entity.." Handler]: Sub Type Recognized: Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", armAdt.subTypeFolders[1], armAdt.subTypeFolders[3], armAdt.subTypeFolders[5], armAdt.subTypeFolders[7])
		armAdt.flags[3] = 1
	end
end

function armorAdapt.showItemLog(item)
	local infLg = sb.logInfo
	local itmName = item.name
	local itmPara = item.parameters
	if armAdt_Config["show"..armAdt.entity.."SupportedItem"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The name for the suported item is %s", itmName)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The parameters for the suported item are %s", itmPara)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The config for the supported item is %s", root.itemConfig(item).config)
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem)
	local infLg = sb.logInfo
	if armAdt_Config["show"..armAdt.entity.."BuildInfo"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The mask of the base item is %s", root.itemConfig(baseItem).config.mask)

		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item tags are %s", adaptItem.parameters.itemTags)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item male frames are %s", 	adaptItem.parameters.maleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item female frames are %s", adaptItem.parameters.femaleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item mask is %s", adaptItem.parameters.mask)
	end
end