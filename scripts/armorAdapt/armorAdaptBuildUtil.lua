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
	config.armorAdapt_layers = {}
	if parameters.armorAdapt_layers == nil or (type(parameters.armorAdapt_layers) == "table" and not next(parameters.armorAdapt_layers)) then
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
		config.armorAdapt_tags = true
		if parameters.armorAdapt_tags == nil or not next(parameters.armorAdapt_tags) then
			parameters.armorAdapt_tags = {maleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestm.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleeve.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleeve.png"}, femaleFrames = { body ="/items/armors/armorAdapt/default/null/Default/chestf.png", frontSleeve = "/items/armors/armorAdapt/default/null/Default/fsleevef.png", backSleeve = "/items/armors/armorAdapt/default/null/Default/bsleevef.png"}, maskFrames = "/items/armors/armorAdapt/default/null/Default/mask.png", library = "null", hideBool = "null", bodyClass = "null", subType = "null"}
		end
	else
		config.armorAdapt_tags = true
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
	if config["armorAdapt_intendedBody"] ~= nil and config.armorAdapt_intendedBody.library == library and config.armorAdapt_intendedBody.bodyClass == bodyClass and config.armorAdapt_intendedBody.subType == subType then
		config = config
	elseif config["armorAdapt_custom"] ~= nil and config.armorAdapt_custom[library][bodyClass][subType] ~= nil then
		config.maleFrames = config.armorAdapt_custom[library][bodyClass][subType][maleFrames]
		config.femaleFrames = config.armorAdapt_custom[library][bodyClass][subType][femaleFrames]
		if config.armorAdapt_custom[library][bodyClass][subType][mask] ~= nil then
			parameters.mask = config.armorAdapt_custom[library][bodyClass][subType][mask]
		end
	elseif (parameters.itemTags ~= nil and parameters.itemTags[1] == "armorAdapted") or (parameters.armorAdapt_tags.subType ~= "null") then
		adtpath = "/items/armors/armorAdapt/default/"
		if type(maleFrames) == "table" then
			config.maleFrames.body = armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body)
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve)
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve)
			config.femaleFrames.body = armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body)
			config.femaleFrames.frontSleeve = armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve)
			config.femaleFrames.backSleeve = armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve)
		elseif itemSlot ~= "back" then
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."m.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."f.png", config.femaleFrames)
		else
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/back.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/back.png", config.femaleFrames)
		end

		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end

		if (parameters.mask ~= nil and itemSlot == "head") or (parameters.mask ~= nil and maskFrames ~= "/items/armors/armorAdapt/default/null/Default/mask.png" and itemSlot == "head") then
			parameters.mask = armorAdapt.defaultCheck(maskFrames, adtpath, bodyClass, subType, "/mask.png", "mask.png" )
		end
		--[[if type(maleFrames) == "table" then
			config.maleFrames.body = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body), parameters.armorAdapt_layers.chest, "male")
			config.maleFrames.frontSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve), parameters.armorAdapt_layers.farm, "male")
			config.maleFrames.backSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve), parameters.armorAdapt_layers.barm, "male")
			config.femaleFrames.body = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body), parameters.armorAdapt_layers.chest, "female")
			config.femaleFrames.frontSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve), parameters.armorAdapt_layers.farm, "female")
			config.femaleFrames.backSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve), parameters.armorAdapt_layers.barm, "female")
		elseif itemSlot ~= "back" then
			config.maleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."m.png", config.maleFrames), parameters.armorAdapt_layers, "male")
			config.femaleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."f.png", config.femaleFrames), parameters.armorAdapt_layers, "female")
		else
			config.maleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/back.png", config.maleFrames), parameters.armorAdapt_layers, "male")
			config.femaleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/back.png", config.femaleFrames), parameters.armorAdapt_layers, "female")
		end

		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end

		if (parameters.mask ~= nil and itemSlot == "head") or (parameters.mask ~= nil and maskFrames ~= "/items/armors/armorAdapt/default/null/Default/mask.png" and itemSlot == "head") then
			parameters.mask = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maskFrames, adtpath, bodyClass, subType, "/mask.png", "mask.png" ), parameters.armorAdapt_layers.mask, "null")
		end]]--
	end

	return config, parameters
end

function armorAdapt.defaultCheck(parameterPath, adtpath, bodyClass, subType, imageName, defaultImage)
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
	elseif defaultImage == "mask.png" then
		pathTable[4] = root.itemConfig(config2.itemName).directory..defaultImage
		for i = 1, #pathTable do
			if imgchk(pathTable[i])[1] == 43 then
				imageString = pathTable[i]
			break
			end
		end
	else
		pathTable[4] = root.itemConfig(config2.itemName).directory..defaultImage
		for i = 1, #pathTable do
			if imgchk(pathTable[i])[1] > 64 then
				imageString = pathTable[i]
			break
			end
		end
	end
	
	return imageString
end
--[[
function armorAdapt.directivesBuild(imageString, layers, gender)
	if layers[gender].frameOverride ~= nil then
		base = layers[gender].frameOverride
	else
		base = nil
	end
	if next(layers) then
		if next(layers["base"])then
			for  i = 1, #layers["base"] do
				local mid = "?"
				if layers["base"][gender][i][2] ~= nil then
					mid = "?addmask="..layers["base"][gender][i][2].."?"
				else
					mid = "?"
				end
				if base == nil then
					base = layers["base"][gender][i][1]
				else
					base = base..mid.."blendscreen"..layers["base"][gender][i][1]..";-2;-2"
				end
			end
		end
		if base ~= nil then
			imageString = base.."?blendscreen="..imageString..";-2;-2"
		end
		if next(layers["overlay"]) then
			for  g = 1, #layers["overlay"] do
				if layers["overlay"][gender][i][2] ~= nil then
					imageString = imageString.."?addmask="..layers["overlay"][gender][i][2].."?blendscreen="..layers["overlay"][gender][i][1]..";-2;-2"
				else
					imageString = imageString.."?blendscreen="..layers["overlay"][gender][i][1]..";-2;-2"
				end
			end
		end
	end
	return imageString
end]]--