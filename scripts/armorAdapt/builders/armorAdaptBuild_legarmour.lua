armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	config2 = config
	config = util.mergeTable({ }, config)
	config.armorAdapt_layers = {}
	if parameters.armorAdapt_layers == nil or (type(parameters.armorAdapt_layers) == "table" and not next(parameters.armorAdapt_layers)) then
		parameters.armorAdapt_layers = {}
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
	maleFrames = basePath.."pantsm.png"
	femaleFrames = basePath.."pantsf.png"

	if config["armorAdapt_intendedBody"] ~= nil and config["armorAdapt_intendedBody"].library == library and config["armorAdapt_intendedBody"].bodyClass == bodyClass and config["armorAdapt_intendedBody"].subType == subType then
		config = config
	elseif config["armorAdapt_custom"] ~= nil and config.armorAdapt_custom[library][bodyClass][subType] ~= nil then
		config.maleFrames = config.armorAdapt_custom[library][bodyClass][subType][maleFrames]
		config.femaleFrames = config.armorAdapt_custom[library][bodyClass][subType][femaleFrames]
	elseif (parameters.itemTags ~= nil and parameters.itemTags[1] == "armorAdapted") or (parameters.armorAdapt_tags.subType ~= "null") then
		adtpath = "/items/armors/armorAdapt/default/"
		config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/pantsm.png", config.maleFrames)
		config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/pantsf.png", config.femaleFrames)
		if (parameters.itemTags ~= nil and parameters.itemTags[6] ~= nil and parameters.itemTags[6] == "hideBody") or (parameters.armorAdapt_tags == "hideBody") then
			config.hideBody = true
		end
		--[[
		config.maleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."m.png", config.maleFrames), parameters.armorAdapt_layers, "male")
		config.femaleFrames = armorAdapt.directivesBuild(armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/"..itemSlot.."f.png", config.femaleFrames), parameters.armorAdapt_layers, "female")
		
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