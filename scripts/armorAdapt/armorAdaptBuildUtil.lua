armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	config = util.mergeTable({ }, config)
	local maleFrames, femaleFrames, maskFrames, library, hideBool, bodyClass, subType = nil
	if config[armorAdapt_tags] ~= nil then
		maleFrames = parameters.armorAdapt_tags.maleFrames
		femaleFrames = parameters.armorAdapt_tags.femaleFrames
		maskFrames = parameters.armorAdapt_tags.mask
		library = parameters.armorAdapt_tags.library
		hideBool = parameters.armorAdapt_tags.hideBool
		bodyClass = parameters.armorAdapt_tags.bodyClass
		subType = parameters.armorAdapt_tags.subType
		
	elseif parameters.itemTags ~= nil and parameters.itemTags[4] ~= nil then
		maleFrames = parameters.maleFrames
		femaleFrames = parameters.femaleFrames
		library = parameters.itemTags[7]
		hideBool = parameters.itemTags[5]
		bodyClass = parameters.itemTags[2]
		subType = parameters.itemTags[3]
		if parameters.mask ~= nil then
			maskFrames = "/items/armors/armorAdapt/"..bodyClass.."/"..parameters.itemTags[5].."/"..subType.."/mask.png"
		end
	end
	if config[armorAdapt_intendedBody] ~= nil and config.armorAdapt_intendedBody.library == library and config.armorAdapt_intendedBody.bodyClass == bodyClass and config.armorAdapt_intendedBody.subType == subType then
		config = config
	elseif parameters.itemTags ~= nil and parameters.itemTags[1] == "armorAdapted" then
		adtpath = "/items/armors/armorAdapt/default/"
		if type(maleFrames) = "table" then
			config.maleFrames.body = armorAdapt.defaultCheck(maleFrames.body, adtpath, bodyClass, subType, "/chestm.png", config.maleFrames.body)
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleeve.png", config.maleFrames.frontSleeve)
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleeve.png", config.maleFrames.backSleeve)
			config.femaleFrames.body = armorAdapt.defaultCheck(femaleFrames.body, adtpath, bodyClass, subType, "/chestf.png", config.femaleFrames.body)
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, bodyClass, subType, "/fsleevef.png", config.femaleFrames.frontSleeve)
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, bodyClass, subType, "/bsleevef.png", config.femaleFrames.backSleeve)
		elseif parameters.itemTags[4] ~= "back"
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/"..parameters.itemTags[4].."m.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/"..parameters.itemTags[4].."f.png", config.femaleFrames)
		else
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, bodyClass, subType, "/back.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, bodyClass, subType, "/back.png", config.femaleFrames)
		end

		if parameters.itemTags[6] ~= nil and parameters.itemTags[5] == "hideBody" then
			config.hideBody = true
		end

		if parameters.mask ~= nil then
			parameters.mask = armorAdapt.defaultCheck(maskFrames, adtpath, bodyClass, subType "/mask.png", defaultImage)
		end
	end
	return config, parameters
end

function armorAdapt.defaultCheck(parameterPath, adtpath, subType, bodyClass, imageName, defaultImage)
	local imgchk = root.imageSize
	local pathTable = {parameterPath, adtpath..bodyClass.."/"..subType..imageName, adtpath..bodyClass..imageName, defaultImage}
	if _ENV.root[assetOrigin] ~= nil then
		pathTable[4] = root.itemConfig(config.itemName).directory.."/"..defaultImage
		for i = 1, #pathTable do
			if root.assetOrigin(pathTable[i]) ~= nil then
				imageString = pathTable[i]
			break
			end
		end
	else
		for i = 1, #pathTable do
			if imgchk(pathTable[i])[1] > 64 then
				imageString = pathTable[i]
			break
			end
		end
	end
	
	return imageString
end