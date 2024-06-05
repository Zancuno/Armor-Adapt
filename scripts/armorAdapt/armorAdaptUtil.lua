armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
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
	if type(mismatchTable) == "table" then
		if next(armAdt.currentArmor) then --check if entity is loaded
			for z = 1, #armAdt.slotTable do
				exempt_item = armAdt.currentArmor[z]
				if exempt_item ~= nil then
					if root.itemConfig(exempt_item).config["builder"] == nil or
					root.itemConfig(exempt_item).config.builder ~= "/armorAdapt/armorAdaptBuilder.lua" or
					exempt_item.name == "startech:nanofield" or
					exempt_item.name == "startech:nanofieldstatichead" or
					exempt_item.name == "startech:nanofieldstaticlegs" or
					(root.itemConfig(exempt_item).parameters.directives ~= nil and
					string.len(root.itemConfig(exempt_item).parameters.directives) >= armAdt_MinDrtv) then
						mismatchTable[z] = nil
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
	for adt_misnum = 8, 1, -1 do
		if armAdt_mismatch[adt_misnum] == adt_misnum then
			if armAdt.currentArmor[adt_misnum] ~= nil then
				armAdt_itemBase = armAdt.currentArmor[adt_misnum]
				if armAdt_itemBase.name == "perfectlygenericitem" then
					eqpitm(armAdt.slotTable[adt_misnum], nil)
				end
					armAdt_itemEdit = armorAdapt.runArmorAdapt(armAdt_itemBase, adt_misnum, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.spriteLibrary)
				if armAdt_itemEdit ~= nil then
					eqpitm(armAdt.slotTable[adt_misnum], armAdt_itemEdit)
					armorAdapt.showCompletionLog(armAdt_itemEdit, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.entity)
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
	armAdt_playerArmor = {}
	for k = 1, #armAdt.slotTable do
		armAdt_playerArmor[k] = player.equippedItem(armAdt.slotTable[k])
	end
	return armAdt_playerArmor
end

function armorAdapt.generateNpcArmorTable()
	armAdt_npcArmor = {}
	for k = 1, #armAdt.slotTable do
		armAdt_npcArmor[k] = npc.getItemSlot(armAdt.slotTable[k])
	end
	return armAdt_npcArmor
end

function armorAdapt.showCompletionLog(item, bodyClass, subType)
	local infLg = sb.logInfo
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt.entity.."BuildCompletion") == true then
		infLg("[Armor Adapt]["..armAdt.entity.." Handler]: Item %s has sucessfully been adapted to the body class %s and the sub type %s", root.itemConfig(item).config.itemName, bodyClass, subType)
	end
end

function armorAdapt.transformativeEffects()
	sb.logInfo("mismatchTable edit is %s", armAdt.subTypeFolders)
	local armAdt_statusOverride = false
	local armAdt_OverrideBackUp = {}
	for transEffect, transSettings in pairs(armAdt_Config.armorAdaptTransformativeEffects) do
		if stseffact(transSettings["effectName"]) then
			local disguiseStop = false
			for stknum = 8, 1, -2 do
				armAdt.statusFolders[stknum] = "none"
				armAdt.statusFolders[stknum-1] = "none"
				sb.logInfo("mismatchTable edit is %s", armAdt.slotTable[stknum-1])
				if transSettings["setting"] == "overlay" and transSettings["singleFolder"] ~= nil then
					statusOverlayFolder = transSettings["singleFolder"]
				elseif transSettings["setting"] == "baseEdit" and transSettings["singleFolder"] ~= nil then
					statusBaseFolder = transSettings["singleFolder"]
				end
				if transSettings[armAdt.slotTable[stknum-1]] == 1 then
					if transSettings["setting"] == "override" then
						armAdt.subTypeFolders[stknum] = armAdt.subTypeStorage[stknum]
						armAdt.subTypeFolders[stknum-1] = armAdt.subTypeStorage[stknum-1]
					end
					if transSettings["setting"] == "override" or transSettings["setting"] == "stack" then
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
						else
							armAdt.subTypeFolders[stknum] = armAdt.subTypeFolders[stknum]..transSettings["modifier"]
							armAdt.subTypeFolders[stknum-1] = armAdt.subTypeFolders[stknum-1]..transSettings["modifier"]
							if transSettings["setting"] == "override" then
								armAdt_statusOverride = true
							end
						end
					elseif (transSettings["setting"] == "classEdit" or transSettings["setting"] == "disguise") then
						armAdt.classFolders[stknum] = transSettings["modifier"]
						armAdt.classFolders[stknum-1] = transSettings["modifier"]
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
			if armAdt_statusOverride == true then
				armAdt_OverrideBackUp = armAdt.subTypeFolders
			end
		end
		if disguiseStop == true then
			break
		end
	end
	if armAdt_statusOverride == true then
		armAdt.subTypeFolders = util.mergeTable({}, armAdt_OverrideBackUp)
	end
	sb.logInfo("mismatchTable edit is %s", armAdt.subTypeFolders)
end