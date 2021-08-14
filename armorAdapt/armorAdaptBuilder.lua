require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
	armorAdaptCheck = root.assetJson("/cinematics/apex/intro.cinematic.disabled:muteMusic")
	if armorAdaptCheck == false then
		if parameters.maleFrames or parameters.femaleFrames ~= nil then
		config = util.mergeTable({ }, config)
		local maleFrames = parameters.maleFrames
		local femaleFrames = parameters.femaleFrames


		if type(config.maleFrames or config.femaleFrames) == "table" then
			if type(maleFrames) == "string" then
				maleFrames = { body = maleFrames }
			end
			if type(femaleFrames) == "string" then
				femaleFrames = { body = femaleFrames }
			end

			if root.imageSize(femaleFrames.body)[1] <= 64 then
				maleFrames.body = string.format("/items/armors/armorAdapt/default/%s/%s/chestm.png", parameters.itemTags[2], parameters.itemTags[3])
				maleFrames.frontSleeve = string.format("/items/armors/armorAdapt/default/%s/%s/fsleeve.png", parameters.itemTags[2], parameters.itemTags[3])
				maleFrames.backSleeve = string.format("/items/armors/armorAdapt/default/%s/%s/bsleeve.png", parameters.itemTags[2], parameters.itemTags[3])
				femaleFrames.body = string.format("/items/armors/armorAdapt/default/%s/%s/chestf.png", parameters.itemTags[2], parameters.itemTags[3])
				femaleFrames.frontSleeve = string.format("/items/armors/armorAdapt/default/%s/%s/fsleeve.png", parameters.itemTags[2], parameters.itemTags[3])
				femaleFrames.backSleeve = string.format("/items/armors/armorAdapt/default/%s/%s/blseeve.png", parameters.itemTags[2], parameters.itemTags[3])
			else
				maleFrames.body = maleFrames.body
				maleFrames.frontSleeve = maleFrames.frontSleeve 
				maleFrames.backSleeve = maleFrames.backSleeve
				femaleFrames.body = femaleFrames.body
				femaleFrames.frontSleeve = femaleFrames.frontSleeve 
				femaleFrames.backSleeve = femaleFrames.backSleeve
			end
		end

		config.maleFrames = maleFrames
		config.femaleFrames = femaleFrames 
		end
	
		if parameters.headMaleFrames or parameters.headFemaleFrames ~= nil then
		config = util.mergeTable({ }, config)
		local mask = parameters.mask 
		local headMaleFrames = parameters.headMaleFrames
		local headFemaleFrames = parameters.headFemaleFrames
			if root.imageSize(mask)[1] <= 43 then
				config.mask = mask
			elseif root.imageSize(mask)[1] > 43 then
				config.mask = string.format("/items/armors/armorAdapt/default/%s/%s/mask.png", parameters.itemTags[2], parameters.itemTags[3])
			end
			if root.imageSize(headMaleFrames)[1] <= 64 then
				config.maleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/head.png", parameters.itemTags[2], parameters.itemTags[3])
				config.femaleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/head.png", parameters.itemTags[2], parameters.itemTags[3])
			else
				config.maleFrames = headMaleFrames
				config.femaleFrames = headFemaleFrames
			end
		end
		
		if parameters.pantsMaleFrames or parameters.pantsFemaleFrames ~= nil then
		config = util.mergeTable({ }, config)
		local pantsMaleFrames = parameters.pantsMaleFrames
		local pantsFemaleFrames = parameters.pantsFemaleFrames
			if root.imageSize(pantsMaleFrames)[1] <= 64 then
				config.maleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/pantsm.png", parameters.itemTags[2], parameters.itemTags[3])
				config.femaleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/pantsf.png", parameters.itemTags[2], parameters.itemTags[3])
			else
				config.maleFrames = pantsMaleFrames
				config.femaleFrames = pantsFemaleFrames
			end
		end
		
		if parameters.backMaleFrames or parameters.backFemaleFrames ~= nil then
		config = util.mergeTable({ }, config)
		local backMaleFrames = parameters.backMaleFrames
		local backFemaleFrames = parameters.backFemaleFrames
			if root.imageSize(pantsMaleFrames)[1] <= 64 then
				config.maleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/back.png", parameters.itemTags[2], parameters.itemTags[3])
				config.femaleFrames = string.format("/items/armors/armorAdapt/default/%s/%s/back.png", parameters.itemTags[2], parameters.itemTags[3])
			else
				config.maleFrames = backMaleFrames
				config.femaleFrames = backFemaleFrames
			end
		end
		return config, parameters

	else
		config = config
		return config, parameters
	end
end