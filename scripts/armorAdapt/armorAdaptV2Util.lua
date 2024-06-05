function armorAdapt.runArmorAdapt(baseItem, key, bodyClass, subType, adtlibrary)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	baseName = baseItem.name
	
	if armAdt.statusFolders[key] ~= "none" then
		baseName = armAdt.statusFolders[key]
	end
	nullCheck = "false"
	if bodyClass == "null" then
		nullCheck = "true"
	end
	if baseItem.parameters.armorAdapt_tags == nil then
		baseItem.parameters.armorAdapt_tags = { }
		baseItem.parameters.armorAdapt_tags["bodyClass"] = "none"
		baseItem.parameters.armorAdapt_tags["subType"] = "none"
	end
	itemTagTable = baseItem.parameters.armorAdapt_tags
	bodyClassCheck = baseItem.parameters.armorAdapt_tags.bodyClass
	bodySubTypeCheck = baseItem.parameters.armorAdapt_tags.subType
	
	if baseItem.parameters.itemTags ~= nil and baseItem.parameters.itemTags[1] == "armorAdapted" then
		baseItem.parameters.itemTags = nil
	end
	
	if (key == 3 and baseItem.parameters.maleFrames ~= nil) or (key == 4 and baseItem.parameters.maleFrames ~= nil) then
		if string.find(baseItem.parameters.maleFrames.body, "armorAdapt") then
			baseItem.parameters.maleFrames = nil
			baseItem.parameters.femaleFrames = nil
		end
	elseif baseItem.parameters.maleFrames ~= nil then
		if string.find(baseItem.parameters.maleFrames, "armorAdapt") then
			baseItem.parameters.maleFrames = nil
			baseItem.parameters.femaleFrames = nil
		end
	end
	
	if armAdt.firstUpdate == false and itemTagTable ~= nil and bodyClassCheck == bodyClass and bodySubTypeCheck == subType then
		adaptItem = baseItem
		return adaptItem
	elseif armAdt.firstUpdate == true or armAdt.firstUpdate == true or itemTagTable == nil or bodyClassCheck ~= bodyClass or bodySubTypeCheck ~= subType then 
		armorAdapt.showItemLog(baseItem)
		local adaptItem = copy(baseItem)
		adaptItem.parameters.armorAdapt_tags = { }
		adaptItem.parameters.armorAdapt_tags["library"] = adtlibrary
		adaptItem.parameters.armorAdapt_tags["frameOverride"] = armAdt.frameOverrideFolder
		adaptItem.parameters.armorAdapt_tags["hideBool"] = armAdt.hideBody
		adaptItem.parameters.armorAdapt_tags["bodyClass"] = bodyClass
		adaptItem.parameters.armorAdapt_tags["subType"] = subType
		adaptItem.parameters.armorAdapt_tags["nullCheck"] = nullCheck
		adaptItem.parameters.armorAdapt_tags["itemFolder"] = baseName
		bldLg(baseItem, adaptItem)
		return adaptItem
	end
	
end

function armorAdapt.speciesConfig()
	armAdtSpriteLibrary = "default"
	
	if root.assetJson("/species/"..armAdt.initSpecies..".species")["armorAdapt_settings"] ~= nil then
		speciesSettings = root.assetJson("/species/"..armAdt.initSpecies..".species:armorAdapt_settings")
		armAdt.classType = armAdt.initSpecies
		armAdt.classFolders[1] = speciesSettings.headFolder
		armAdt.classFolders[2] = speciesSettings.headFolder
		armAdt.classFolders[3] = speciesSettings.chestFolder
		armAdt.classFolders[4] = speciesSettings.chestFolder
		armAdt.classFolders[5] = speciesSettings.legFolder
		armAdt.classFolders[6] = speciesSettings.legFolder
		armAdt.classFolders[7] = speciesSettings.backFolder
		armAdt.classFolders[8] = speciesSettings.backFolder
		if speciesSettings.subTypeScript ~= nil then
			armAdt.subTypeScript = speciesSettings.subTypeScript
		end
		if speciesSettings.spriteLibrary ~= nil then
			armAdt.spriteLibrary = speciesSettings.spriteLibrary
		end
		if speciesSettings.outfitFrames ~= nil then
			armAdt.frameOverrideFolder = speciesSettings.outfitFrames
		end
	else
		armAdt.classType = dfltSpc
		armAdt.classFolders[1] = dfltSpc
		armAdt.classFolders[2] = dfltSpc
		armAdt.classFolders[3] = dfltSpc
		armAdt.classFolders[4] = dfltSpc
		armAdt.classFolders[5] = dfltSpc
		armAdt.classFolders[6] = dfltSpc
		armAdt.classFolders[7] = dfltSpc
		armAdt.classFolders[8] = dfltSpc
	end
	
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
			armAdt.classType = v1Species[spcEntry][1]
			armAdt.classFolders[1] = v1Species[spcEntry][2]
			armAdt.classFolders[2] = v1Species[spcEntry][2]
			armAdt.classFolders[3] = v1Species[spcEntry][3]
			armAdt.classFolders[4] = v1Species[spcEntry][3]
			armAdt.classFolders[5] = v1Species[spcEntry][4]
			armAdt.classFolders[6] = v1Species[spcEntry][4]
			armAdt.classFolders[7] = v1Species[spcEntry][5]
			armAdt.classFolders[8] = v1Species[spcEntry][5]
		end	
	end
end

function armorAdapt.getSpeciesBodyTable(speciesCheck)
	if armAdt.flags[2] == 0 and (armAdt_Config.showPlayerSpecies == true) then
		inflg("[Armor Adapt][Player Handler]: Species Recognized: %s", speciesCheck)
		armAdt.flags[2] = 1
	end
	if armAdt.subTypeScript ~= "none" then
		require(armAdt.subTypeScript)
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
	elseif armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck] ~= nil then
		require(armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck])
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
	else 
		armAdt.subTypeFolders = { "Default", "Default", "Default", "Default", "Default", "Default", "Default", "Default" }
	end
		armAdt.subTypeStorage = util.mergeTable({}, armAdt.subTypeFolders)
	if armAdt.flags[3] == 0 and (armAdt_Config["show"..armAdt.entity.."BodyType"] == true) then
		inflg("[Armor Adapt]["..armAdt.entity.." Handler]: Sub Type Recognized: Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", armAdt.subTypeFolders[1], armAdt.subTypeFolders[3], armAdt.subTypeFolders[5], armAdt.subTypeFolders[7])
		armAdt.flags[3] = 1
	end
end

function armorAdapt.showItemLog(item)
	local infLg = sb.logInfo
	if armAdt_Config["show"..armAdt.entity.."SupportedItem"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The name for the suported item is %s", item.name)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The parameters for the suported item are %s", item.parameters.armorAdapt_tags)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The config for the supported item is %s", root.itemConfig(item).config)
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem)
	local infLg = sb.logInfo
	if armAdt_Config["show"..armAdt.entity.."BuildInfo"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The tags of the base item are %s", root.itemConfig(baseItem).config.itemTags)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)

		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item tags are %s", adaptItem.parameters.armorAdapt_tags)
	end
end