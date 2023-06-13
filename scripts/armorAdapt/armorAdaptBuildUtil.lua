armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	if parameters.itemTags ~= nil and parameters.itemTags[4] ~= nil then
		config = util.mergeTable({ }, config)
		local adtspc,adtbdy,adtpath = parameters.itemTags[2], parameters.itemTags[3], "/items/armors/armorAdapt/default/"
		local maleFrames = parameters.maleFrames
		local femaleFrames = parameters.femaleFrames
		if type(maleFrames) = "table" then
			config.maleFrames.body = armorAdapt.defaultCheck(maleFrames.body, adtpath, adtspc, "/chestm.png", config.maleFrames.body)
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(maleFrames.frontSleeve, adtpath, adtspc, "/fsleeve.png", config.maleFrames.frontSleeve)
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(maleFrames.backSleeve, adtpath, adtspc, "/bsleeve.png", config.maleFrames.backSleeve)
			config.femaleFrames.body = armorAdapt.defaultCheck(femaleFrames.body, adtpath, adtspc, "/chestf.png", config.femaleFrames.body)
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(femaleFrames.frontSleeve, adtpath, adtspc, "/fsleevef.png", config.femaleFrames.frontSleeve)
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(femaleFrames.backSleeve, adtpath, adtspc, "/bsleevef.png", config.femaleFrames.backSleeve)
		elseif parameters.itemTags[4] ~= "back"
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, adtspc, "/"..parameters.itemTags[4].."m.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, adtspc, "/"..parameters.itemTags[4].."f.png", config.femaleFrames)
		else
			config.maleFrames = armorAdapt.defaultCheck(maleFrames, adtpath, adtspc, "/back.png", config.maleFrames)
			config.femaleFrames = armorAdapt.defaultCheck(femaleFrames, adtpath, adtspc, "/back.png", config.femaleFrames)
		end

		if parameters.itemTags[6] ~= nil and parameters.itemTags[5] == "hideBody" then
			config.hideBody = true
		end

		if parameters.mask ~= nil then
			parameters.mask = armorAdapt.defaultCheck(adtpath..adtspc.."/"..parameters.itemTags[5].."/"..adtbdy.."/mask.png", adtpath, adtspc, "/mask.png", defaultImage)
		end
	end
	return config, parameters
end

function armorAdapt.defaultCheck(parameterPath, adtpath, adtspc, imageName, defaultImage)
	local imgchk = root.imageSize
	local pathTable = {parameterPath, adtpath..adtspc.."/"..adtbdy..imageName, adtpath..adtspc..imageName, defaultImage}
	for i = 1, #pathTable do
		if imgchk(pathTable[i])[1] > 64 then
			imageString = pathTable[i]
		break
		end
	end
	return imageString
end