armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	config2 = config
	config = util.mergeTable({ }, config)
	if config2.category:find("head") then
		itemSlot = "head"
	elseif config2.category:find("chest") then
		itemSlot = "chest"
	elseif config2.category:find("leg") then
		itemSlot = "pants"
	else
		itemSlot = "back"
	end
	config.armorAdapy_layers = {}
	if parameters.armorAdapt_layers == nil or not next(parameters.armorAdapt_Layers) then
		parameters.armorAdapt_layers = {}
		if itemSlot == "chest" then
			parameters.armorAdapt_layers.chest = {}
			parameters.armorAdapt_layers.barm = {}
			parameters.armorAdapt_layers.farm = {}
		end
		if itemSlot == "head" then
			parameters.armorAdapt_layers.mask = {}
		end
	end
	if itemSlot == "chest" then
		config.armorAdapt_tags = {maleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestm.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleeve.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleeve.png"}, femaleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestf.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleevef.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleevef.png"}, maskFrames = "/items/armors/armorAdapt/default/null/Default/mask.png", library = "null", hideBool = "null", bodyClass = "null", subType = "null" }
		if parameters.armorAdapt_tags == nil or not next(parameters.armorAdapt_tags) then
			parameters.armorAdapt_tags = {maleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestm.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleeve.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleeve.png"}, femaleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestf.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleevef.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleevef.png"}, maskFrames = "/items/armors/armorAdapt/default/null/Default/mask.png", library = "null", hideBool = "null", bodyClass = "null", subType = "null"}
		end
	else
		config.armorAdapt_tags = {maleFrames = "/items/armors/armorAdapt/default/null/Default/pantsm.png", femaleFrames = "/items/armors/armorAdapt/default/null/Default/pantsf.png", maskFrames = "/items/armors/armorAdapt/default/null/Default/mask.png", library = "null", hideBool = "null", bodyClass = "null", subType = "null" }
		if parameters.armorAdapt_tags == nil or not next(parameters.armorAdapt_tags) then
			parameters.armorAdapt_tags = {maleFrames = "/items/armors/armorAdapt/default/null/Default/pantsm.png", femaleFrames = "/items/armors/armorAdapt/default/null/Default/pantsf.png", maskFrames = "/items/armors/armorAdapt/default/null/Default/mask.png", library = "null", hideBool = "null", bodyClass = "null", subType = "null"}
		end
	end
	if parameters.armorAdapt_tags ~= nil then
		maleFrames = parameters.armorAdapt_tags.maleFrames
		femaleFrames = parameters.armorAdapt_tags.femaleFrames
		maskFrames = parameters.armorAdapt_tags.maskFrames
		library = parameters.armorAdapt_tags.library
		hideBool = parameters.armorAdapt_tags.hideBool
		bodyClass = parameters.armorAdapt_tags.bodyClass
		subType = parameters.armorAdapt_tags.subType
		
	elseif parameters.itemTags ~= nil and parameters.itemTags[4] ~= nil then
		maleFrames = parameters.maleFrames
		femaleFrames = parameters.femaleFrames
		library = parameters.itemTags[7]
		hideBool = parameters.itemTags[6]
		bodyClass = parameters.itemTags[2]
		subType = parameters.itemTags[3]
		if parameters.mask ~= nil then
			maskFrames = "/items/armors/armorAdapt/"..bodyClass.."/"..parameters.itemTags[5].."/"..subType.."/mask.png"
		end
	end
	if config[armorAdapt_intendedBody] ~= nil and config.armorAdapt_intendedBody.library == library and config.armorAdapt_intendedBody.bodyClass == bodyClass and config.armorAdapt_intendedBody.subType == subType then
		config = config
	elseif config[armorAdapt_custom] ~= nil and config.armorAdapt_custom[library][bodyClass][subType] ~= nil then
		config.maleFrames = config.armorAdapt_custom[library][bodyClass][subType][maleFrames]
		config.femaleFrames = config.armorAdapt_custom[library][bodyClass][subType][femaleFrames]
		if config.armorAdapt_custom[library][bodyClass][subType][mask] ~= nil then
			parameters.mask = config.armorAdapt_custom[library][bodyClass][subType][mask]
		end
	elseif (parameters.itemTags ~= nil and parameters.itemTags[1] == "armorAdapted") or (parameters.armorAdapt_tags.subType ~= "null") then
		adtpath = "/items/armors/armorAdapt/default/"
		if type(maleFrames) == "table" then
			config.maleFrames.body = armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body, parameters.armorAdapt_layers.chest, "male")
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve, parameters.armorAdapt_layers.farm, "male")
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve, parameters.armorAdapt_layers.barm, "male")
			config.femaleFrames.body = armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body, parameters.armorAdapt_layers.chest, "female")
			config.femaleFrames.frontSleeve = armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve, parameters.armorAdapt_layers.farm, "female")
			config.femaleFrames.backSleeve = armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve, parameters.armorAdapt_layers.barm, "female")
		elseif itemSlot ~= "back" then
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."m.png", config.maleFrames, parameters.armorAdapt_layers, "male")
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."f.png", config.femaleFrames, parameters.armorAdapt_layers, "female")
		else
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/back.png", config.maleFrames, parameters.armorAdapt_layers, "male")
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/back.png", config.femaleFrames, parameters.armorAdapt_layers, "female")
		end

		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end

		if (parameters.mask ~= nil and itemSlot == "head") or (parameters.mask ~= nil and maskFrames ~= "/items/armors/armorAdapt/default/null/Default/mask.png" and itemSlot == "head") then
			parameters.mask = armorAdapt.defaultCheck(maskFrames, adtpath, bodyClass, subType, "/mask.png", "mask.png", parameters.armorAdapt_layers.mask)
		end
	end

	return config, parameters
end

function armorAdapt.defaultCheck(parameterPath, adtpath, bodyClass, subType, imageName, defaultImage, layers, gender)
	local imgchk = root.imageSize
	local pathTable = {parameterPath, adtpath..bodyClass.."/"..subType..imageName, adtpath..bodyClass..imageName, defaultImage}
	if _ENV.root["assetOrigin"] ~= nil then
		pathTable[4] = root.itemConfig(config2.itemName).directory..defaultImage
		for i = 1, #pathTable do
			if root.assetOrigin(pathTable[i]) ~= nil then
				imageString = pathTable[i]
			break
			end
		end
		imageString = armorAdapt.directivesBuild(imageString, layers, gender)
	elseif defaultImage == "mask.png" then
		pathTable[4] = root.itemConfig(config2.itemName).directory..defaultImage
		for i = 1, #pathTable do
			if imgchk(pathTable[i])[1] == 43 then
				imageString = pathTable[i]
			break
			end
		end
		imageString = armorAdapt.directivesBuild(imageString, layers, gender)
	else
		pathTable[4] = root.itemConfig(config2.itemName).directory..defaultImage
		for i = 1, #pathTable do
			if imgchk(pathTable[i])[1] > 64 then
				imageString = pathTable[i]
			break
			end
		end
		imageString = armorAdapt.directivesBuild(imageString, layers, gender)
	end
	
	return imageString
end

function armorAdapt.directivesBuild(imageString, layers, gender)
	if next(layers) then
		local base = nil
		for local i = 1, #layers["base"] do
			local mid = "?"
			if layers["base"][i][2] ~= nil then
				mid = "?addmask="..layers[gender]["base"][i][gender][2].."?"
			else
				mid = "?"
			end
			if base == nil then
				base = layers[gender]["base"][i][gender][1]
			else
				base = base..mid.."blendscreen"..layers[gender]["base"][i][gender][1]..";-2;-2"
			end
		end
		if base ~= nil then
			imageString = base..imageString
		end
		for local i = 1, #layers["overlay"] do
			if layers["overlay"][i][gender][2] ~= nil then
				imageString = imageString.."?addmask="..layers["overlay"][i][gender][2].."?blendscreen="..layers["overlay"][i][gender][1]..";-2;-2"
			else
				imageString = imageString.."?blendscreen="..layers["overlay"][i][gender][1]..";-2;-2"
			end
		end
	end
	return imageString
end