armorAdapt = {}

function armorAdapt.spriteBuild(directory, config, parameters, level, seed)
	configItemName = config.itemName
	intendedBody = config["armorAdapt_intendedBody"] or nil
	armAdtCustom = config["armorAdapt_custom"] or nil
	pathTable = {}
	played = false
	--common buildscript table merge to prevent re-assertion of original config
	config = util.mergeTable({ }, config)

	config.inventoryIcon = config.iconPath
	--creating parameters if non existant prior
	if parameters.armorAdapt_tags == nil or not next(parameters.armorAdapt_tags) then
		parameters.armorAdapt_tags = {
			library = "default", 
			bodyClass = "standard", 
			subType = "Default", 
			hideBool = "showBody", 
			nullcheck = "false", 
			itemFolder = "null", 
			defaultSystem = false,
			genderOverride = "null"
		}
	end
	--storing parameters in custom var names to prevent overriding with other buildscripts
	AAlibrary = parameters.armorAdapt_tags.library
	AAbodyClass = parameters.armorAdapt_tags.bodyClass
	AAsubType = parameters.armorAdapt_tags.subType
	
	AAhideBool = parameters.armorAdapt_tags.hideBool
	AAitemFolder = parameters.armorAdapt_tags.itemFolder
	AAdefaultSys = parameters.armorAdapt_tags.defaultSystem

	--checking to see if species settings match intended body of item original images to avoid further checks
	if intendedBody ~= nil and 
	intendedBody["library"] == AAlibrary and 
	intendedBody["bodyClass"] == AAbodyClass and 
	intendedBody["subType"] == AAsubType then
	
		config = config
	
	--intended body mismatch so checking item for preset image paths that match species settings
	elseif armAdtCustom ~= nil and 
	armAdtCustom[AAlibrary] ~= nil and 
	armAdtCustom[AAlibrary][AAbodyClass] ~= nil and 
	armAdtCustom[AAlibrary][AAbodyClass][AAsubType] ~= nil then

		config.maleFrames = armorAdapt.pathBuild(armAdtCustom[AAlibrary][AAbodyClass][AAsubType]["maleFrames"])
		config.femaleFrames = armorAdapt.pathBuild(armAdtCustom[AAlibrary][AAbodyClass][AAsubType]["femaleFrames"])
	
	--no preset image paths for species settings in item so checking if custom folder paths exist, if not original images
	elseif AAitemFolder ~= "null" then

		--null check is only true for animal species or species missing limbs, this is a forced invisibility of items
		if parameters.armorAdapt_tags.nullcheck == true then
			config.maleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
			config.femaleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
			config.maleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
			config.femaleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
			config.maleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
			config.femaleFrames = "/items/armors/armorAdapt/default/null/default/back.png"
		else
			config.maleFrames.body = armorAdapt.defaultCheck(armorAdapt.constructPaths("/chestm.png", config.maleFrames.body))
			config.femaleFrames.body = armorAdapt.defaultCheck(armorAdapt.constructPaths("/chestf.png", config.femaleFrames.body))
			config.maleFrames.frontSleeve = armorAdapt.defaultCheck(armorAdapt.constructPaths("/fsleeve.png", config.maleFrames.frontSleeve))
			config.femaleFrames.frontSleeve = armorAdapt.defaultCheck(armorAdapt.constructPaths("/fsleevef.png", config.femaleFrames.frontSleeve))
			config.maleFrames.backSleeve = armorAdapt.defaultCheck(armorAdapt.constructPaths("/bsleeve.png", config.maleFrames.backSleeve))
			config.femaleFrames.backSleeve = armorAdapt.defaultCheck(armorAdapt.constructPaths("/bsleevef.png", config.femaleFrames.backSleeve))
		end
		
		if AAhideBool == "hideBody" then
			config.hideBody = true
		end
	end

	--for species with a neutral body shape or are a singular gender. To auto force the frames on both "genders" the game forces.
	if parameters.armorAdapt_tags.genderOverride == "male" then
		config.femaleFrames = config.maleFrames
	elseif parameters.armorAdapt_tags.genderOverride == "female" then
		config.maleFrames = config.femaleFrames
	end

	return config, parameters
end

function armorAdapt.defaultCheck()
	--checking if images exist, if modified client use assetOrigin to prevent errors, otherwise will spam log with missing image errors as it checks
	local imgchk = root.imageSize
	if _ENV.root["assetOrigin"] ~= nil then
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

function armorAdapt.constructPaths(partImage, originalImage)
	--creating a queue table of image paths for defaultCheck to run through. Non standard library adds a check before defaulting to normal library if failed. Species that use default outfits or if transformation effects are active add 2 more checks for matching images. All else fails original image is at end of list which should always succeed unless is empty.
	pathTable= {}
	if AAlibrary ~= "default" then
		pathTable[1] = "/items/armors/"..AAlibrary.."/"..AAbodyClass.."/"..AAitemFolder.."/"..AAsubType..partImage
		
		if AAdefaultSys == true or AAitemFolder ~= configItemName then
			table.insert(pathTable, "/items/armors/armorAdapt/default/"..AAbodyClass.."_"..AAlibrary.."/"..AAsubType..partImage)
			table.insert(pathTable, "/items/armors/armorAdapt/default/"..AAbodyClass.."_"..AAlibrary..partImage)
		end
		
		table.insert(pathTable, "/items/armors/armorAdapt/"..AAbodyClass.."/"..AAitemFolder.."/"..AAsubType..partImage)	
	else
		pathTable[1] = "/items/armors/armorAdapt/"..AAbodyClass.."/"..AAitemFolder.."/"..AAsubType..partImage
		
		if AAdefaultSys == true or AAitemFolder ~= configItemName then
			table.insert(pathTable, "/items/armors/armorAdapt/default/"..AAbodyClass.."/"..AAsubType..partImage)
			table.insert(pathTable, "/items/armors/armorAdapt/default/"..AAbodyClass..partImage)
		end
	end
	table.insert(pathTable, root.itemConfig(configItemName).directory..originalImage)
end

function armorAdapt.pathBuild(frameTable)
	--checking for directory shortcuts and adjusting image path as needed, <itemDir> for item directory and <(itemName)> of the linked item's item directory.

	if string.find(frameTable["body"], ":") then
		local shortDir = string.sub(frameTable["body"], 1, string.find(frameTable["body"], ":")-1)
		if shortDir == "itemDir" then
			frameTable["body"] = string.gsub(frameTable["body"], shortDir..":", root.itemConfig(configItemName).directory)
		elseif AAitemFolder ~= "null" then
			frameTable["body"] = string.gsub(frameTable["body"], shortDir..":", root.itemConfig(shortDir).directory)
		end
	end

	if string.find(frameTable["frontSleeve"], ":") then
		local shortDir = string.sub(frameTable["frontSleeve"], 1, string.find(frameTable["frontSleeve"], ":")-1)
		if shortDir == "itemDir" then
			frameTable["frontSleeve"] = string.gsub(frameTable["frontSleeve"], shortDir..":", root.itemConfig(configItemName).directory)
		elseif AAitemFolder ~= "null" then
			frameTable["frontSleeve"] = string.gsub(frameTable["frontSleeve"], shortDir..":", root.itemConfig(shortDir).directory)
		end
	end
	
	if string.find(frameTable["backSleeve"], ":") then
		local shortDir = string.sub(frameTable["backSleeve"], 1, string.find(frameTable["backSleeve"], ":")-1)
		if shortDir == "itemDir" then
			frameTable["backSleeve"] = string.gsub(frameTable["backSleeve"], shortDir..":", root.itemConfig(configItemName).directory)
		elseif AAitemFolder ~= "null" then
			frameTable["backSleeve"] = string.gsub(frameTable["backSleeve"], shortDir..":", root.itemConfig(shortDir).directory)
		end
	end
return frameTable
end