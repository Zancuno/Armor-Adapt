armorAdapt = {}
--[[
	Item Utility Functions
]]

function armorAdapt.generatePlayerArmorTable()
	--grabs items equipped on player in order from head to back cosmetic
	armAdt_playerArmor = {}
	for k = 1, #armAdt.slotTable do
		armAdt_playerArmor[k] = player.equippedItem(armAdt.slotTable[k])
	end
	return armAdt_playerArmor
end

function armorAdapt.generateNpcArmorTable()
	--grabs items equipped on npc in order from head to back cosmetic
	armAdt_npcArmor = {}
	for k = 1, #armAdt.slotTable do
		armAdt_npcArmor[k] = npc.getItemSlot(armAdt.slotTable[k])
	end
	return armAdt_npcArmor
end

function armorAdapt.compareArmorTables(a, b)
	--checking equipped items vs a stored table. If mismatch, it creates a list of what slots have mismatched
	local adtItmMtch = root.itemDescriptorsMatch
	local mismatchTable = {}
	
	for k = 1, #armAdt.slotTable do
		if not adtItmMtch(a[k], b[k], true) then
			mismatchTable[k] = k
		end
	end
	
	if not next(mismatchTable) then
		return true
	else
		return mismatchTable
	end
end

function armorAdapt.exemptionCheck(mismatchTable)
	--checking mismatch list for items that need to be exempted from conversion.
	if type(mismatchTable) == "table" then
		--check if entity is loaded
		if next(armAdt.currentArmor) then 
			for z = 1, #armAdt.slotTable do
				exempt_item = armAdt.currentArmor[z]
				
				--nil check to prevent script failure
				if exempt_item then
				
					if root.itemConfig(exempt_item).config["builder"] and
					root.itemConfig(exempt_item).config.builder == "/sys/stardust/cosplay/build.lua" or
					exempt_item.name == "startech:nanofield" or
					exempt_item.name == "startech:nanofieldstatichead" or
					exempt_item.name == "startech:nanofieldstaticlegs" or
					(root.itemConfig(exempt_item).parameters.directives and
					string.len(root.itemConfig(exempt_item).parameters.directives) >= armAdt_MinDrtv) then
					
						mismatchTable[z] = nil
						
						--update stored table with exempt item to not trigger mismatch again
						armAdt.itemStorage[z] = exempt_item
						
						if armAdt_Config.showCustomItemSkip == true then
							sb.logInfo("[Armor Adapt]["..armAdt.entity.." Handler] %s exempted from conversion", exempt_item.name)
						end
					end
				end
			end
		end
	end
	
	if mismatchTable == true then
		return true
	elseif not next(mismatchTable) then
		return true
	else	
		return mismatchTable
	end
end

function armorAdapt.postCleanup(cleanTable)
	--parameter cleanup on uninit to help in case of uninstall or item bugginess
	if type(cleanTable) == "table" then
		for h, g in pairs(cleanTable) do
			local freshItem = root.createItem(g.name)
			freshItem.parameters = g.parameters
			freshItem.parameters.armorAdapt_tags = nil
			freshItem.parameters.armorAdapt_params = nil
			freshItem.parameters.armorAdapt_convert = nil
			eqpitm(armAdt.slotTable[h], freshItem)
		end
	end
end

--[[
	Item Conversion Functions
]]
function armorAdapt.slotUpdate()
	--checks mismatched items, sends to build, then equips the item
	for adt_misnum = 8, 1, -1 do
		if armAdt_mismatch[adt_misnum] == adt_misnum then
			if armAdt.currentArmor[adt_misnum] then
				armAdt_itemBase = armAdt.currentArmor[adt_misnum]
				
				--pgi check to prevent stack overflow, auto deletes PGIs from outfit slots
				if armAdt_itemBase.name == "perfectlygenericitem" then
					eqpitm(armAdt.slotTable[adt_misnum], nil)
				end
				
				--get returned item descriptor of the modified item
				armAdt_itemEdit = armorAdapt.runArmorAdapt(armAdt_itemBase, adt_misnum, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.spriteLibrary)
				
				if armAdt_itemEdit then
					--equip the item
					eqpitm(armAdt.slotTable[adt_misnum], armAdt_itemEdit)
					armorAdapt.showCompletionLog(armAdt_itemEdit, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.entity)
					
					--update stored table to not be seen as mismatch
					armAdt.itemStorage[adt_misnum] = armorAdapt.updatedSlot(adt_misnum)
					armAdt.flags[4] = 0
				else
					armAdt.itemStorage[adt_misnum] = armAdt.currentArmor[adt_misnum]
				end
			else
				armAdt.itemStorage[adt_misnum] = nil
			end
		end
	end
end

function armorAdapt.updatedSlot(num)
	--grabbing specific item descriptor to store to prevent unnecessary second loop
	if armAdt.entity == "Player" then
		updatedItem = player.equippedItem(armAdt.slotTable[num])
		return updatedItem
	elseif armAdt.entity == "Npc" then
		updatedItem = npc.getItemSlot(armAdt.slotTable[num])
		return updatedItem
	end
end

function armorAdapt.runArmorAdapt(baseItem, key, bodyClass, subType, adtlibrary)
	--param build for items to be passed to the builder, returns to script that equips item

	local bldLg,rtCfg = armorAdapt.showBuildLog, root.itemConfig
	baseName = baseItem.name
	
	--checking if transformative effect is active and has dedicated folder
	if armAdt.statusFolders[key] ~= "none" then
		baseName = armAdt.statusFolders[key]
	end
	nullCheck = "false"
	
	--checking for animal species or species without limbs to assert blank images
	if bodyClass == "null" then
		nullCheck = "true"
	end
	
	--adding armor adapt tags in case somehow missing to prevent script aborting
	if baseItem.parameters.armorAdapt_tags == nil then
		baseItem.parameters.armorAdapt_tags = { }
		baseItem.parameters.armorAdapt_tags["bodyClass"] = "none"
		baseItem.parameters.armorAdapt_tags["subType"] = "none"
	end
	itemTagTable = baseItem.parameters.armorAdapt_tags
	bodyClassCheck = baseItem.parameters.armorAdapt_tags.bodyClass
	bodySubTypeCheck = baseItem.parameters.armorAdapt_tags.subType
	
	--checking for prior version item params and removing if found to clean them up
	if baseItem.parameters.itemTags and baseItem.parameters.itemTags[1] == "armorAdapted" then
		baseItem.parameters.itemTags = nil
	end
	
	--checking if prior image params exist to clean up for compatibility
	if (key == 3 and baseItem.parameters.maleFrames) or (key == 4 and baseItem.parameters.maleFrames) then
		if string.find(baseItem.parameters.maleFrames.body, "armorAdapt") then
			baseItem.parameters.maleFrames = nil
			baseItem.parameters.femaleFrames = nil
		end
	elseif baseItem.parameters.maleFrames then
		if string.find(baseItem.parameters.maleFrames, "armorAdapt") then
			baseItem.parameters.maleFrames = nil
			baseItem.parameters.femaleFrames = nil
		end
	end
	
	--param building
	armorAdapt.showItemLog(baseItem)
	local adaptItem = {
		count = 1,
		name = "armAdt_"..armAdt.slotTable[key],
		parameters = {
			armorAdapt_convert = root.itemConfig(baseItem).config,
			armorAdapt_params = baseItem.parameters,
			armorAdapt_directory = root.itemConfig(baseItem).directory,
			armorAdapt_tags = {
				library = adtlibrary,
				frameOverride = armAdt.frameOverrideFolder,
				hideBool = armAdt.hideBody,
				bodyClass = bodyClass,
				subType = subType,
				nullCheck = nullCheck,
				itemFolder = baseName,
				defaultSystem = armAdt.defaultSystem,
				genderOverride = armAdt.genderOverride
			}
		}
	}
	bldLg(baseItem, adaptItem)
	return adaptItem
end

--[[
	Entity Settings Functions
]]

function armorAdapt.speciesConfig()
	--building species body class settings
	
	armAdtSpriteLibrary = "default"
	
	--building body class settings from species file, has more settings to play with
	if root.assetJson("/species/"..armAdt.initSpecies..".species")["armorAdapt_settings"] then
		speciesSettings = root.assetJson("/species/"..armAdt.initSpecies..".species:armorAdapt_settings")
		armAdt.classType = armAdt.initSpecies
		armAdt.classFolders[1] = speciesSettings.headFolder
		armAdt.classFolders[2] = speciesSettings.headFolder
		armAdt.classFolders[3] = speciesSettings.chestFolder
		armAdt.classFolders[4] = speciesSettings.chestFolder
		armAdt.classFolders[5] = speciesSettings.legFolder
		armAdt.classFolders[6] = speciesSettings.legFolder
		armAdt.classFolders[7] = speciesSettings.backFolder
		armAdt.classFolders[8] = speciesSettings.backFolder
		
		--checking species file for a script to generate sub type settings
		if speciesSettings.subTypeScript then
			armAdt.subTypeScript = speciesSettings.subTypeScript
		end
		
		--checking if species has opted into an alt library
		if speciesSettings.spriteLibrary then
			armAdt.spriteLibrary = speciesSettings.spriteLibrary
		end
		
		--checking if species has custom frames files to override outfits
		if speciesSettings.outfitFrames then
			armAdt.frameOverrideFolder = speciesSettings.outfitFrames
		end
		
		--checking if species uses default outfit
		if speciesSettings.outfitDefaults then
			armAdt.defaultSystem = speciesSettings.outfitDefaults
		else 
			armAdt.defaultSystem = false
		end
		
		--checking if species is neutral or only one gender. Forces only "male" or "female" frames is set accordingly
		if speciesSettings.outfitGenderOverride then
			armAdt.genderOverride = speciesSettings.outfitGenderOverride
		else
			armAdt.genderOverride = "null"
		end
	else
		armAdt.classType = dfltSpc
		armAdt.classFolders[1] = dfltSpc
		armAdt.classFolders[2] = dfltSpc
		armAdt.classFolders[3] = dfltSpc
		armAdt.classFolders[4] = dfltSpc
		armAdt.classFolders[5] = dfltSpc
		armAdt.classFolders[6] = dfltSpc
		armAdt.classFolders[7] = dfltSpc
		armAdt.classFolders[8] = dfltSpc
	end
	
	--backwards compatible building body class settings from armorAdapt.config, more restricted
	v1Species = { 
		animalSpecies = {armAdt.initSpecies, dfltNl, dfltNl, armAdt.initSpecies, dfltNl},
		customBodySpecies = {armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies},
		customHeadChestLegSpecies = {armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, armAdt.initSpecies, dfltSpc},
		customChestLegSpecies= {armAdt.initSpecies, dfltSpc, armAdt.initSpecies, armAdt.initSpecies, dfltSpc},
		customHeadLegSpecies = {armAdt.initSpecies, armAdt.initSpecies, dfltSpc, armAdt.initSpecies, dfltSpc},
		customLegSpecies = {armAdt.initSpecies, dfltSpc, dfltSpc, armAdt.initSpecies, dfltSpc},
		customChestSpecies= {armAdt.initSpecies, dfltSpc, armAdt.initSpecies, dfltSpc, dfltSpc},
		customHeadSpecies = {armAdt.initSpecies, armAdt.initSpecies, dfltSpc, dfltSpc, dfltSpc},
		vanillaBodySpecies = {dfltSpc, dfltSpc, dfltSpc, dfltSpc, dfltSpc}
	}
	for spcEntry, spcSet in pairs(v1Species) do
		for _, spcList in ipairs(armAdt_Config[spcEntry]) do
			if spcList == armAdt.initSpecies then
				armAdt.classType = v1Species[spcEntry][1]
				armAdt.classFolders[1] = v1Species[spcEntry][2]
				armAdt.classFolders[2] = v1Species[spcEntry][2]
				armAdt.classFolders[3] = v1Species[spcEntry][3]
				armAdt.classFolders[4] = v1Species[spcEntry][3]
				armAdt.classFolders[5] = v1Species[spcEntry][4]
				armAdt.classFolders[6] = v1Species[spcEntry][4]
				armAdt.classFolders[7] = v1Species[spcEntry][5]
				armAdt.classFolders[8] = v1Species[spcEntry][5]
			end	
		end
	end
end

function armorAdapt.getSpeciesBodyTable(speciesCheck)
	--checks if a species has a script to build body sub type settings or provide defaults

	if armAdt.flags[2] == 0 and (armAdt_Config.showPlayerSpecies == true) then
		inflg("[Armor Adapt][Player Handler]: Species Recognized: %s", speciesCheck)
		armAdt.flags[2] = 1
	end
	
	--runs script from species file to build sub type seettings
	if armAdt.subTypeScript then
		require(armAdt.subTypeScript)
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
		
	--backwards compatible, checks armorAdapt.config for the script to build sub type settings	
	elseif armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck] then
		require(armAdt_Config.adaptSpeciesSubTypeScripts[speciesCheck])
		armAdt.subTypeFolders = armorAdapt.speciesBodyTable()
	else 
		armAdt.subTypeFolders = { "Default", "Default", "Default", "Default", "Default", "Default", "Default", "Default" }
	end
	
	--store a backup of settings
	armAdt.subTypeStorage = util.mergeTable({}, armAdt.subTypeFolders)
	
	
	if armAdt.flags[3] == 0 and (armAdt_Config["show"..armAdt.entity.."BodyType"] == true) then
		inflg("[Armor Adapt]["..armAdt.entity.." Handler]: Sub Body Type Recognized: Your head type is %s, your chest type is %s, your leg type is %s, and your back type is %s", armAdt.subTypeFolders[1], armAdt.subTypeFolders[3], armAdt.subTypeFolders[5], armAdt.subTypeFolders[7])
		armAdt.flags[3] = 1
	end
end

function armorAdapt.transformativeEffects()
	--activated by the trigger status effect becoming active. Checks to see if a status effect patched into armorAdapt.config is active or not. If so modifies hide body, body class, and or body sub type to specified in config. These modify the paths for folder checking or the settings of the species to pull an entirely different image set. If no status effect folder is set in the effect's settings then it'll consider alternate sprites for every outfit item. If a folder is set, a dedicated folder for your use can be made.
	local armAdt_statusOverride = false
	
	--allow override effects to re-assert their settings after loop
	local armAdt_OverrideBackUp = {}
	
	for transEffect, transSettings in pairs(armAdt_Config.armorAdaptTransformativeEffects) do
		if stseffact(transSettings["effectName"]) then
			local disguiseStop = false
			for stknum = 8, 1, -2 do
				--reset status effect folder for next loop
				armAdt.statusFolders[stknum] = "none"
				armAdt.statusFolders[stknum-1] = "none"
				
				--currently unused for status effects that instead of replacing images, layer an image over the sprite
				--[[if transSettings["setting"] == "overlay" and transSettings["singleFolder"] ~= nil then
					statusOverlayFolder = transSettings["singleFolder"]
					
				--currently unused for status effects that layer an image underneath the outfit item
				elseif transSettings["setting"] == "baseEdit" and transSettings["singleFolder"] ~= nil then
					statusBaseFolder = transSettings["singleFolder"]
				end]]
				
				if transSettings[armAdt.slotTable[stknum-1]] == 1 then
					
					--reset status modifier to remove any stacks
					if transSettings["setting"] == "override" then
						armAdt.subTypeFolders[stknum] = armAdt.subTypeStorage[stknum]
						armAdt.subTypeFolders[stknum-1] = armAdt.subTypeStorage[stknum-1]
					end
					
					if transSettings["setting"] == "override" or transSettings["setting"] == "stack" then
						
						--sets modifier as status effect folder
						if transSettings["singleFolder"] and transSettings["setting"] == "override" then
							armAdt.statusFolders[stknum] = transSettings["singleFolder"]
							armAdt.statusFolders[stknum-1] = transSettings["singleFolder"]
						elseif transSettings["singleFolder"] and transSettings["setting"] == "stack" then
							if armAdt.statusFolders[stknum] ~= "none" then
								armAdt.statusFolders[stknum] = armAdt.statusFolders[stknum]..transSettings["singleFolder"]
								armAdt.statusFolders[stknum-1] = armAdt.statusFolders[stknum-1]..transSettings["singleFolder"]
							else
								armAdt.statusFolders[stknum] = transSettings["singleFolder"]
								armAdt.statusFolders[stknum-1] = transSettings["singleFolder"]
							end
							
						--attaches modifier to end of body sub type since doesn't have a status folder
						else
							armAdt.subTypeFolders[stknum] = armAdt.subTypeFolders[stknum]..transSettings["modifier"]
							armAdt.subTypeFolders[stknum-1] = armAdt.subTypeFolders[stknum-1]..transSettings["modifier"]
							if transSettings["setting"] == "override" then
								armAdt_statusOverride = true
							end
						end
					elseif (transSettings["setting"] == "classEdit" or transSettings["setting"] == "disguise") then
					
						--modifies the body class to specified modifier
						armAdt.classFolders[stknum] = transSettings["modifier"]
						armAdt.classFolders[stknum-1] = transSettings["modifier"]
						
						--is a disguise so is overriding everything and will end the loop when done
						if transSettings["setting"] == "disguise" then
							if transSettings["singleFolder"] then
								armAdt.statusFolders[stknum] = transSettings["singleFolder"]
								armAdt.statusFolders[stknum-1] = transSettings["singleFolder"]
							end
							armAdt.subTypeFolders[stknum] = dfltBdy
							armAdt.subTypeFolders[stknum-1] = dfltBdy
							armAdt.hideBody = "hideBody"
							disguiseStop = true
						end
					end
				end
			end
			--store a copy of body sub type to re-assert for override
			if armAdt_statusOverride == true then
				armAdt_OverrideBackUp = armAdt.subTypeFolders
			end
		end
		if disguiseStop == true then
			break
		end
	end
	--reassert stored data for override
	if armAdt_statusOverride == true then
		armAdt.subTypeFolders = util.mergeTable({}, armAdt_OverrideBackUp)
	end

end

--[[
	Log Prints
]]
function armorAdapt.showEquippedLog()
	if armAdt.flags[4] == 0 and (armAdt_Config["show"..armAdt.entity.."Armor"] == true) then
		inflg("[Armor Adapt]["..armAdt.entity.." Handler]: The "..armAdt.entity.." currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", armAdt.currentArmor[1], armAdt.currentArmor[2], armAdt.currentArmor[3], armAdt.currentArmor[4], armAdt.currentArmor[5], armAdt.currentArmor[6], armAdt.currentArmor[7], armAdt.currentArmor[8])
		armAdt.flags[4] = 1
	end
end

function armorAdapt.showItemLog(item)
	--log print to show item being queued for conversion with config and parameters for debugging, turn "showPlayerSupportedItem" for players or "showNpcSupportedItem" for NPCs to make it show in the log
	local infLg = sb.logInfo
	if armAdt_Config["show"..armAdt.entity.."SupportedItem"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The name for the item in queue is %s", item.name)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The unmodified parameters for the queued item are %s", item.parameters.armorAdapt_tags)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The unmodified config for the queued item is %s", root.itemConfig(item).config)
	end
end

function armorAdapt.showBuildLog(baseItem, adaptItem)
	--log print to show the item frames prior to conversion and what Armor Adapt tags will be applied, turn on "showPlayerBuildInfo" for players or "showNpcBuildInfo" for NPCs to make it show in log
	local infLg = sb.logInfo
	if armAdt_Config["show"..armAdt.entity.."BuildInfo"] == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The unmodified male frames of the base item are %s", root.itemConfig(baseItem).config.maleFrames)
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: The unmodified female frames of the base item are %s", root.itemConfig(baseItem).config.femaleFrames)

		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Adapted item tags to be added are %s", adaptItem.parameters.armorAdapt_tags)
	end
end

function armorAdapt.showCompletionLog(item, bodyClass, subType)
	--log print to show completed item with body shape info, turn "showPlayerBuildCompletion" and or npc equivalent on in armorAdapt.config to make it show
	local infLg = sb.logInfo
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt.entity.."BuildCompletion") == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Item %s has sucessfully been adapted to the body class %s and the sub type %s", root.itemConfig(item).config.itemName, bodyClass, subType)
	end
end