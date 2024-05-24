function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, armAdt_entity, adtlibrary, statusFolder, framesOverride)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	baseName = baseItem.config.itemName
	if statusFolder ~= "none" then
		baseName = armAdt.statusFolder
	end
	nullCheck = "false"
	if species == "null" then
		nullCheck = "true"
	end
	itemTagTable = baseItem.parameters.armorAdapt_tags
	bodyClassCheck = baseItem.parameters.armorAdapt_tags.bodyClass
	bodySubTypeCheck = baseItem.parameters.armorAdapt_tags.subType
	if itemTagTable ~= nil and bodyClassCheck == species and bodySubTypeCheck == bodyType then
		adaptItem = baseItem
		return adaptItem
	elseif itemTagTable == nil or bodyClassCheck ~= species or bodySubTypeCheck ~= bodyType then 
		armorAdapt.showItemLog(baseItem, armAdt_entity)
		local adaptItem = copy(baseItem)
		adaptItem.parameters.armorAdapt_tags = {}
		adaptItem.parameters.armorAdapt_tags["library"] = adtlibrary
		adaptItem.parameters.armorAdapt_tags["hideBool"] = armAdt_hideBody
		adaptItem.parameters.armorAdapt_tags["bodyClass"] = species
		adaptItem.parameters.armorAdapt_tags["subType"] = bodyType
		adaptItem.parameters.armorAdapt_tags["nullCheck"] = nullCheck
		adaptItem.parameters.armorAdapt_tags["itemFolder"] = baseName

		bldLg(baseItem, adaptItem, armAdt_entity)
		return adaptItem
	end
end

function armorAdapt.speciesConfig()
	armAdtSpriteLibrary = "default"
	
	if pcall(root.assetJson("/species/"..armAdt.initSpecies..".species")["armorAdapt_settings"] ~= nil) then
		speciesSettings = root.assetJson("/species/"..armAdt.initSpecies..".species:ArmorAdapt_settings")
		armAdt.classType = armAdt.initSpecies
		armAdt.classFolders[1] = speciesSettings.headFolder
		armAdt.classFolders[2] = speciesSettings.headFolder
		armAdt.classFolders[3] = speciesSettings.chestFolder
		armAdt.classFolders[4] = speciesSettings.chestFolder
		armAdt.classFolders[5] = speciesSettings.legFolder
		armAdt.classFolders[6] = speciesSettings.legFolder
		armAdt.classFolders[7] = speciesSettings.backFolder
		armAdt.classFolders[8] = speciesSettings.backFolder
		if speciesSettings.spriteLibrary ~= "default" then
			armAdtSpriteLibrary = speciesSettings.spriteLibrary
		end
		if speciesSettings.outfitFrames ~= nil then
			frameOverrideFolder = speciesSettings.outfitFrames
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
	local itmPara = root.itemConfig(item).parameters.armorAdapt_tags
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

		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Adapted item tags are %s", adaptItem.parameters.armorAdapt_tags)
	end
end