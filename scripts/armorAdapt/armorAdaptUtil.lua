armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	--checking equipped items vs a stored table. If mismatch, it creates a list of what slots have mismatched
	local adtItmMtch = root.itemDescriptorsMatch
	local rtCfg = root.itemConfig
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
				if exempt_item ~= nil then
				
					if root.itemConfig(exempt_item).config["builder"] == nil or
					root.itemConfig(exempt_item).config.builder ~= "/armorAdapt/armorAdaptBuilder.lua" or
					exempt_item.name == "startech:nanofield" or
					exempt_item.name == "startech:nanofieldstatichead" or
					exempt_item.name == "startech:nanofieldstaticlegs" or
					(root.itemConfig(exempt_item).parameters.directives ~= nil and
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

function armorAdapt.slotUpdate()
	--checks mismatched items, sends to build, then equips the item
	for adt_misnum = 8, 1, -1 do
		if armAdt_mismatch[adt_misnum] == adt_misnum then
			if armAdt.currentArmor[adt_misnum] ~= nil then
				armAdt_itemBase = armAdt.currentArmor[adt_misnum]
				
				--pgi check to prevent stack overflow, auto deletes PGIs from outfit slots
				if armAdt_itemBase.name == "perfectlygenericitem" then
					eqpitm(armAdt.slotTable[adt_misnum], nil)
				end
				
				--get returned item descriptor of the modified item
				armAdt_itemEdit = armorAdapt.runArmorAdapt(armAdt_itemBase, adt_misnum, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.spriteLibrary)
				
				if armAdt_itemEdit ~= nil then
					--equip the item
					eqpitm(armAdt.slotTable[adt_misnum], armAdt_itemEdit)
					armorAdapt.showCompletionLog(armAdt_itemEdit, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.entity)
					
					--update stored table to not be seen as mismatch
					armAdt.itemStorage[adt_misnum] = armAdt_itemEdit
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

function armorAdapt.showCompletionLog(item, bodyClass, subType)
	--log print to show completed item with body shape info, turn "showPlayerBuildCompletion" and or npc equivalent on in armorAdapt.config to make it show
	local infLg = sb.logInfo
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt.entity.."BuildCompletion") == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Item %s has sucessfully been adapted to the body class %s and the sub type %s", root.itemConfig(item).config.itemName, bodyClass, subType)
	end
end

function armorAdapt.transformativeEffects()
	--activated by the trigger status effect becoming active. Checks to see if a status effect patched into armorAdapt.config is active or not. If so modifies hide body, body class, and or body sub type to specified in config. These modify the paths for folder checking or the settings of the species to pull an entirely different image set. If no status effect folder is set in the effect's settings then it'll consider alternate sprites for every outfit item. If a folder is set, a dedicated folder for your use can be made.
	sb.logInfo("mismatchTable edit is %s", armAdt.subTypeFolders)
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
				sb.logInfo("mismatchTable edit is %s", armAdt.slotTable[stknum-1])
				
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
						if transSettings["singleFolder"] ~= nil and transSettings["setting"] == "override" then
							armAdt.statusFolders[stknum] = transSettings["singleFolder"]
							armAdt.statusFolders[stknum-1] = transSettings["singleFolder"]
						elseif transSettings["singleFolder"] ~= nil and transSettings["setting"] == "stack" then
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
							if transSettings["singleFolder"] ~= nil then
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
	sb.logInfo("mismatchTable edit is %s", armAdt.subTypeFolders)
end