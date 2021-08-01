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
		  maleFrames.body = maleFrames.body
		  maleFrames.frontSleeve = maleFrames.frontSleeve
		  maleFrames.backSleeve = maleFrames.backSleeve
		  femaleFrames.body = femaleFrames.body
		  femaleFrames.frontSleeve = femaleFrames.frontSleeve
		  femaleFrames.backSleeve = femaleFrames.backSleeve
		end

		config.maleFrames = maleFrames
		config.femaleFrames = femaleFrames
		end
		if parameters.mask ~= nil then
		local mask = parameters.mask

		config.mask = mask
		end

		return config, parameters

	else
		config = config
		return config, parameters
	end
end