require "/scripts/util.lua"

armorAdabtBuilderVersion = 10

function build(directory, config, parameters, level, seed)
	armorAdaptCheck = root.assetJson("/cinematics/apex/intro.cinematic.disabled:muteMusic")
	if armorAdaptCheck == false then
		require("/scripts/armorAdapt/builders/armorAdaptBuild_"..config.category..".lua")
		config, parameters = armorAdapt.spriteBuild(directory, config, parameters, level, seed)
		local buildscripts = config.armorAdapt_buildscripts
		if type(buildscripts) == "table" then
			if next(buildscripts) then
				for i = 1, #buildscripts do
					require(buildscripts[i])
					config, parameters = build(directory, config, parameters, level, seed)
				end
			end
		end
		return config, parameters
	else
		config = config
		if imgchk(parameters.mask)[1] ~= 43 then
			parameters.mask = config.mask
		end
		local buildscripts = config.armorAdapt_buildscripts
		if type(buildscripts) == "table" then
			if next(buildscripts) then
				for i = 1, #buildscripts do
					require(buildscripts[i])
					config, parameters = build(directory, config, parameters, level, seed)
				end
			end
		end
	end
	return config, parameters
end