armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	local adtItmMtch = root.itemDescriptorsMatch
	local rouletteTable = { "1", "1", "1", "1", "1", "1", "1", "1" }
	local mismatchTable = {}
	for k = 1, #rouletteTable do
		if not adtItmMtch(a[k], b[k], true) then
			mismatchTable[k] = k
		end
	end

	if not next(mismatchTable) then
		return true
	else
		return mismatchTable	
	end
	sb.logInfo("mismatchTable is %s", mismatchTable)
end

function armorAdapt.slotUpdate()
	for adt_misnum = 8, 1, -1 do
		slotUAdapt = {adaptHeadType, adaptHeadType, adaptChestType, adaptChestType, adaptLegType, adaptLegType, adaptBackType, adaptBackType}
		slotUBody = {bodyHead, bodyHead, bodyChest, bodyChest, bodyLegs, bodyLegs, bodyBack, bodyBack}
		if mismatchCheck[adt_misnum] == adt_misnum then
			if adaptArmor[adt_misnum] ~= nil then
				armorAdapt_itemBase = adaptArmor[adt_misnum]
				if armorAdapt_itemBase.name == "perfectlygenericitem" then
					eqpitm(slotTable[adt_misnum], nil)
				end
					adaptArmorItem = armorAdapt.runArmorAdapt(armorAdapt_itemBase, adt_misnum, slotUAdapt[adt_misnum], slotUBody[adt_misnum], hideBody, entityType, armAdtSpriteLibrary, statusFolder, frameOverrideFolder)
				if adaptArmorItem ~= nil then
					eqpitm(slotTable[adt_misnum], adaptArmorItem)
					armorAdapt.showCompletionLog(adaptArmorItem, playerSpecies, bodyType, entityType)
					adaptStorageArmorTable[adt_misnum] = adaptArmorItem
					played[4] = 0
				else
					adaptStorageArmorTable[adt_misnum] = adaptArmor[adt_misnum]
				end
			else
				adaptStorageArmorTable[adt_misnum] = nil
			end
		end
	end
end

function armorAdapt.runArmorAdapt(baseItem, key, species, bodyType, hideBody, entity, adtlibrary, statusFolder, framesOverride)
	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	local adtPth = "/path"
	if adtlibrary == "default" then
		adtPth = "/items/armors/armorAdapt/"
	else
		adtPth = "/items/armors/"..adtlibrary.."/"
	end
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
	baseName = rtCfg(baseItem).config.itemName
	if statusFolder ~= "none" then
		baseName = statusFolder
	end
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
		tagCheck = false
	if rtCfg(baseItem).config.armorAdapt_tags ~= nil then
		tagCheck = true
		itemTagTable = rtCfg(baseItem).parameters.armorAdapt_tags
		bodyClassCheck = rtCfg(baseItem).parameters.armorAdapt_tags.bodyClass
		bodySubTypeCheck = rtCfg(baseItem).parameters.armorAdapt_tags.subType
	else
		itemTagTable = rtCfg(baseItem).parameters.itemTags
		bodyClassCheck = rtCfg(baseItem).parameters.itemTags[2]
		bodySubTypeCheck = rtCfg(baseItem).parameters.itemTags[3]
	end
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
		if tagCheck == true then
			adaptItem.parameters.armorAdapt_tags = {}
			if adaptItem.parameters.itemTags ~= nil and adaptItem.parameters.itemTags[1] == "armorAdapted" then
				adaptItem.parameters.itemTags = {}
			end
		end
		if keyTable[key][3] == "chest" then
			if tagCheck == true then
				--[[if adaptItem.parameters.storageBaseLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.chest.base.male = adaptItem.parameters.storageBaseLayers.chest.male
					
					adaptItem.parameters.armorAdapt_layers.farm.base.male = adaptItem.parameters.storageBaseLayers.farm.male
					
					adaptItem.parameters.armorAdapt_layers.barm.base.male = adaptItem.parameters.storageBaseLayers.barm.male
				end
				if adaptItem.parameters.storageOverlayLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.chest.overlay.female = adaptItem.parameters.storageOverlayLayers.chest.female
					
					adaptItem.parameters.armorAdapt_layers.farm.overlay.female = adaptItem.parameters.storageOverlayLayers.farm.female
					
					adaptItem.parameters.armorAdapt_layers.Overlay.overlay.female = adaptItem.parameters.storageBaseLayers.barm.female
				end]]--
				--[[if framesOverride ~= true then
					if pcall(root.assetJson(framesOverride.."/"..keyTable[key][1]..".frames")) then
						adaptItem.parameters.armorAdapt_layers.chest.female.frameOverride = framesOverride.."/"..keyTable[key][2]..".png"
					end
					if pcall(root.assetJson(framesOverride.."/"..keyTable[key][2]..".frames")) then
						adaptItem.parameters.armorAdapt_layers.chest.male.frameOverride = framesOverride.."/"..keyTable[key][3]..".png"
					end
					if pcall(root.assetJson(framesOverride.."/fsleeve.frames")) then
						adaptItem.parameters.armorAdapt_layers.farm.male.frameOverride = framesOverride.."/fsleeve.png"
					end
					if pcall(root.assetJson(framesOverride.."/bsleeve.frames")) then
						adaptItem.parameters.armorAdapt_layers.farm.male.frameOverride = framesOverride.."/bsleeve.png"
					end
					if pcall(root.assetJson(framesOverride.."/fsleevef.frames")) then
						adaptItem.parameters.armorAdapt_layers.farm.female.frameOverride = framesOverride.."/fsleevef.png"
					end
					if pcall(root.assetJson(framesOverride.."/bsleevef.frames")) then
						adaptItem.parameters.armorAdapt_layers.farm.female.frameOverride = framesOverride.."/bsleevef.png"
					end
				end]]--
			else		
				adaptItem.parameters.femaleFrames = { body = adtPth..midPath..keyTable[key][1]..".png", frontSleeve = adtPth..midPath.."fsleevef.png", backSleeve = adtPth..midPath.."bsleevef.png" }
				adaptItem.parameters.maleFrames = { body = adtPth..midPath..keyTable[key][2]..".png", frontSleeve = adtPth..midPath.."fsleeve.png", backSleeve = adtPth..midPath.."bsleeve.png" }
			end
		else
			if tagCheck == true then
				--[[if adaptItem.parameters.storageBaseLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.base = adaptItem.parameters.storageBaseLayers
				end
				if adaptItem.parameters.storageOverlayLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.overlay = adaptItem.parameters.storageOverlayLayers
				end
				if framesOverride == true then
					if pcall(root.assetJson(framesOverride.."/"..keyTable[key][2]..".frames")) then
						adaptItem.parameters.armorAdapt_layers.female.frameOverride = framesOverride.."/".. keyTable[key][2]..".png"
					end
					if pcall(root.assetJson(framesOverride.."/"..keyTable[key][3]..".frames")) then
						adaptItem.parameters.armorAdapt_layers.male.frameOverride = framesOverride.."/".. keyTable[key][3]..".png"
					end
				end]]--
			else
				adaptItem.parameters.maleFrames = adtPth..midPath..keyTable[key][3]..".png"
				adaptItem.parameters.femaleFrames = adtPth..midPath..keyTable[key][2]..".png"
			end
		end

		if keyTable[key][3] == "mask" then
			if tagCheck == true then
				--[[if adaptItem.parameters.storageMaskBaseLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.mask.base = adaptItem.parameters.storageMaskBaseLayers
				end
				if adaptItem.parameters.storageMaskOverlayLayers ~= nil and spriteOverride ~= true then
					adaptItem.parameters.armorAdapt_layers.mask.overlay = adaptItem.parameters.storageMaskOverlayLayers
				end]]--
			end
		end

		if hideBody == false then
			hideBool = "hideBody"
		else
			hideBool = "showBody"
		end
		
		if tagCheck == true then
			adaptItem.parameters.armorAdapt_tags["library"] = adtlibrary
			adaptItem.parameters.armorAdapt_tags["hideBool"] = hideBool
			adaptItem.parameters.armorAdapt_tags["bodyClass"] = species
			adaptItem.parameters.armorAdapt_tags["subType"] = bodyType
			adaptItem.parameters.armorAdapt_tags["nullCheck"] = nullCheck
			adaptItem.parameters.armorAdapt_tags["itemFolder"] = rtCfg(baseItem).config.itemName
		else
			adaptItem.parameters.itemTags = { "armorAdapted", species, bodyType, keyTable[key][1], baseName, hideBool, adtlibrary }
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
	--[[armorAdapt.v1SpeciesFill(adaptConfig.animalSpecies, initSpecies, dfltNl, dfltNl, initSpecies, dfltNl)
	armorAdapt.v1SpeciesFill(adaptConfig.customBodySpecies, initSpecies, initSpecies, initSpecies, initSpecies, initSpecies)
	armorAdapt.v1SpeciesFill(adaptConfig.customHeadChestLegSpecies, initSpecies, initSpecies, initSpecies, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.customChestLegSpecies, initSpecies, dfltSpc, initSpecies, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.customHeadLegSpecies, initSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.customLegSpecies, initSpecies, dfltSpc, dfltSpc, initSpecies, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.customChestSpecies, initSpecies, dfltSpc, initSpecies, dfltSpc, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.customHeadSpecies, initSpecies, initSpecies, dfltSpc, dfltSpc, dfltSpc)
	armorAdapt.v1SpeciesFill(adaptConfig.vanillaBodySpecies, dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc)]]--
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
	local itmPara = root.itemConfig(item).parameters
	if root.itemConfig(item).config.armorAdapt_tags ~= nil
		then itmPara = root.itemConfig(item).parameters.armorAdapt_tags
	end
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
	local bodyList = {bodyType, bodyHead, bodyChest, bodyLegs, bodyBack}
	local bodyListStorage = {strg1, strg2, strg3, strg4, strg5}
	for _, effVal in ipairs(effCfg) do
		if status.uniqueStatusEffectActive(effVal) then
			for listRun = 5, 1, -1 do
				bodyType = bodyType..effVal
				if bodyList[listRun] ~= nil then
					if forceBool == true then
						bodyList[listRun] = bodyListStorage[listRun]
					end
					bodyList[listRun] = bodyList[listRun]..effVal
				end
			end
		end
	end
	bodyType, bodyHead, bodyChest, bodyLegs, bodyBack = bodyList[1], bodyList[2], bodyList[3], bodyList[4], bodyList[5]
end

function armorAdapt.v1SpeciesFill(specTable, spec1, spec2, spec3, spec4, spec5)
	if type(specTable) == "table" then
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
end