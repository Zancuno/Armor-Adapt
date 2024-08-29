require "/scripts/util.lua"
--[[
	Buildscript was developed from the aide of Silver Sokolova and StarTech Dev Zia, Zithia, Kiri and other members of the system.
	
	Silver provided examples and knowledge of build script conversion and nested builder running.
	
	The StarTech System provided information on how to make stub scripts and the basis of outfit image swapping.
]]
function build(directory, config, parameters, level, seed)
	if parameters then
	-- Prevents script crash
		if parameters.armorAdapt_convert then
			AAconvertTarget = parameters.armorAdapt_convert or { }
			-- Target item to convert dummy to
			
			AAconvertParams = parameters.armorAdapt_params or { }
			-- Parameters from previous item to prevent other script incompatibility
			
			AAconvertDirectory = parameters.armorAdapt_directory or "error"
			
			if AAconvertParams.armorAdapt_tags then
				AAconvertParams.armorAdapt_tags = nil
			end
			-- Cleaning up old armor adapt params to prevent reassertion

			AAnewParams = parameters.armorAdapt_tags
			
			config = util.mergeTable({ }, config)
			config = AAconvertTarget
			directory = AAconvertDirectory
			-- Overwriting config with target item's
			
			parameters = AAconvertParams
			-- Reasserting old params
			
			parameters.armorAdapt_tags = AAnewParams
			-- Inserting new Armor Adapt params
			
			config.iconPath = directory..AAconvertTarget.inventoryIcon
			-- setting icon path to update icons
			
			require("/scripts/armorAdapt/builders/armorAdaptBuild_"..config.category..".lua")
			config, parameters = armorAdapt.spriteBuild(directory, config, parameters, level, seed)
			-- Loading Armor Adapt builder by category to modify item with Armor Adapt changes
			
			if config.armorAdapt_buildscripts then
				AAbuildscripts = config.armorAdapt_buildscripts
				if type(AAbuildscripts) == "table" then
					if next(AAbuildscripts) then
						for i = 1, #AAbuildscripts do
							require(AAbuildscripts[i])
							config, parameters = build(directory, config, parameters, level, seed)
						end
					end
				end
			end
			-- Checking if developer has added or patched additional buildscripts into the item and running them [Extra Feature]
			
			parameters.armorAdapt_params = nil
			parameters.armorAdapt_convert = nil
			parameters.armorAdapt_directory = nil
			-- Param Cleanup
		end
	end
	return config, parameters
end