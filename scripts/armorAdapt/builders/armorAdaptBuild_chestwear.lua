armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	config2 = config
	config = util.mergeTable({ }, config)
	config.armorAdapt_layers = {}
	if parameters.armorAdapt_layers == nil or (type(parameters.armorAdapt_layers) == "table" and not next(parameters.armorAdapt_layers)) then
		parameters.armorAdapt_layers = {}
		parameters.armorAdapt_layers.chest = {}
		parameters.armorAdapt_layers.barm = {}
		parameters.armorAdapt_layers.farm = {}
	end
	config.armorAdapt_tags = true
	if parameters.armorAdapt_tags == nil or not next(parameters.armorAdapt_tags) then
		parameters.armorAdapt_tags = {library = "null", hideBool = "null", bodyClass = "null", subType = "null", nullcheck = "false", itemFolder = "null"}
	end
	library = parameters.armorAdapt_tags.library
	hideBool = parameters.armorAdapt_tags.hideBool
	bodyClass = parameters.armorAdapt_tags.bodyClass
	subType = parameters.armorAdapt_tags.subType
	itemFolder = parameters.armorAdapt_tags.itemFolder
	if library == "default" then
		librarySeg = "armorAdapt"
	else
		librarySeg = library
	end
	if parameters.armorAdapt_tags["nullCheck"] ~= "false" then
		basePath = "/items/armors/"..librarySeg.."/default/null/Default/"
	else
		basePath = "/items/armors/"..librarySeg.."/"..bodyClass.."/"..itemFolder.."/"..subType.."/"
	end
	maleFrames = { body = basePath.."chestm.png", frontSleeve = basePath.."fsleeve.png", backSleeve = basePath.."bsleeve.png" }
	femaleFrames = { body = basePath.."chestf.png", frontSleeve = basePath.."fsleevef.png", backSleeve = basePath.."bsleevef.png" }

	if config["armorAdapt_intendedBody"] ~= nil and config["armorAdapt_intendedBody"].library == library and config["armorAdapt_intendedBody"].bodyClass == bodyClass and config["armorAdapt_intendedBody"].subType == subType then
		config = config
	elseif config["armorAdapt_custom"] ~= nil and config.armorAdapt_custom[library][bodyClass][subType] ~= nil then
		config.maleFrames = config.armorAdapt_custom[library][bodyClass][subType][maleFrames]
		config.femaleFrames = config.armorAdapt_custom[library][bodyClass][subType][femaleFrames]
	elseif (parameters.itemTags ~= nil and parameters.itemTags[1] == "armorAdapted") or (parameters.armorAdapt_tags.subType ~= "null") then
		adtpath = "/items/armors/armorAdapt/default/"
		config.maleFrames.body = armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body)
		config.maleFrames.frontSleeve = armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve)
		config.maleFrames.backSleeve = armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve)
		config.femaleFrames.body = armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body)
		config.femaleFrames.frontSleeve = armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve)
		config.femaleFrames.backSleeve = armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve)

		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end
	--[[
		config.maleFrames.body = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body), parameters.armorAdapt_layers.chest, "male")
		config.maleFrames.frontSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve), parameters.armorAdapt_layers.farm, "male")
		config.maleFrames.backSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve), parameters.armorAdapt_layers.barm, "male")
		config.femaleFrames.body = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body), parameters.armorAdapt_layers.chest, "female")
		config.femaleFrames.frontSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve), parameters.armorAdapt_layers.farm, "female")
		config.femaleFrames.backSleeve = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve), parameters.armorAdapt_layers.barm, "female")

		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end
	]]--
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