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
		sb.logInfo("mismatchTable is %s", mismatchTable)
		return mismatchTable
	end
end

function armorAdapt.exemptionCheck(mismatchTable)
	if type(mismatchTable) == "table" then
		for z = 1, #armAdt.slotTable do
		exemp_item = adaptArmor[z]
			if exemp_item.name == "startech:nanofield" or
			exemp_item.name == "startech:nanofieldstatichead" or 
			exemp_item.name == "startech:nanofieldstaticlegs" or 
			(exemp_item.parameters.directives ~= nil and string.len(exemp_item.parameters.directives) >= armAdt_MinDrtv) or 
			exemp_item.config.builder == "/sys/stardust/cosplay/build.lua" then
				mismatchTable[z] = nil
				armAdt_storage[z] = exemp_item
			end
		end
	end
	
	if not next(mismatchTable) then
		return true
	else
		sb.logInfo("mismatchTable edit is %s", mismatchTable)
		return mismatchTable
	end
end

function armorAdapt.slotUpdate()
	for adt_misnum = 8, 1, -1 do
		if mismatchCheck[adt_misnum] == adt_misnum then
			if armAdt.currentArmor[adt_misnum] ~= nil then
				armorAdapt_itemBase = armAdt.currentArmor[adt_misnum]
				if armorAdapt_itemBase.name == "perfectlygenericitem" then
					eqpitm(armAdt.slotTable[adt_misnum], nil)
				end
					adaptArmorItem = armorAdapt.runArmorAdapt(armorAdapt_itemBase, adt_misnum, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.entity, armAdt.spriteLibrary, armAdt.statusFolder)
				if adaptArmorItem ~= nil then
					eqpitm(armAdt.slotTable[adt_misnum], adaptArmorItem)
					armorAdapt.showCompletionLog(adaptArmorItem, armAdt.classFolders[adt_misnum], armAdt.subTypeFolders[adt_misnum], armAdt.entity)
					armAdt.itemStorage[adt_misnum] = adaptArmorItem
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

function armorAdapt.generatePlayerArmorTable(adaptPlayerArmor)
	adaptPlayerArmor = {}
	local plrItm = player.equippedItem
	for k = 1, #armAdt.slotTable do
		adaptPlayerArmor[k] = plrItm(armAdt.slotTable[k])
	end
	return adaptPlayerArmor
end

function armorAdapt.generateNpcArmorTable(adaptNpcArmor)
	adaptNpcArmor = {}
	local npcItm = npc.getItemSlot
	for k = 1, #armAdt_slotTable do
		adaptNpcArmor[k] = npcItm(armAdt.slotTable[k])
	end
	return adaptNpcArmor
end

function armorAdapt.showCompletionLog(item, species, bodytype)
	local infLg = sb.logInfo
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..armAdt_entity.."BuildCompletion") == true then
		infLg("[Armor Adapt]["..armAdt_entity.." Handler]: Item %s has sucessfully been adapted to the species %s and the sub type %s", root.itemConfig(item).config.itemName, species, bodyType)
	end
end

function armorAdapt.transformativeEffects()
	for transEffect, transSettings in pairs(armAdt_Config.armorAdaptTransformativeEffects) do
		if stseffact(transSettings["effectName"]) then
			local stackTable = { bodyType, bodyHead, bodyChest, bodyLegs, bodyBack }
			local storageStackTable = {storageBodyType, storageBodyHead, storageBodyChest, storageBodyLegs, storageBodyBack }
			local stack2Table = {adaptSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType}
			local disguiseStop = false
			if transSettings["setting"] == "overlay" and transSettings["singleFolder"] ~= nil then
				statusOverlayFolder = transSettings["singleFolder"]
			elseif transSettings["setting"] == "baseEdit" and transSettings["singleFolder"] ~= nil then
				statusBaseFolder = transSettings["singleFolder"]
			elseif transSettings["singleFolder"] ~= nil then
				statusFolder = transSettings["singleFolder"]
			end
			for stknum = 5, 1, -1 do
				if transSettings[stknum] == 1 then
					if transSettings["setting"] == "override" then
						stackTable[stknum] = storageStackTable[stknum]
					end
					if transSettings["setting"] == "override" or transSettings["setting"] == "stack" then
						stackTable[stknum] = stackTable[stknum]..transSettings["modifier"]
					elseif (transSettings["setting"] == "classEdit" or transSettings["setting"] == "disguise") then
						stack2Table[stknum] = transSettings["modifier"]
						if transSettings["setting"] == "disguise" then
							stackTable[stknum] = dfltBdy
							armAdt_hideBody = "hideBody"
							disguiseStop = true
						end
					end
				end
			end
			bodyType, bodyHead, bodyChest, bodyLegs, bodyBack = stackTable[1], stackTable[2], stackTable[3], stackTable[4], stackTable[5]
			adaptSpecies, adaptHeadType, adaptChestType, adaptLegType, adaptBackType = stack2Table[1], stack2Table[2], stack2Table[3], stack2Table[4], stack2Table[5]
		end
		if disguiseStop == true then
			break
		end
	end
end

function armorAdapt.v1SpeciesFill(specTable, spec1, spec2, spec3, spec4, spec5)
	if type(specTable) == "table" then
		for _,specValue in ipairs(specTable) do
			if player.species() == specValue then
				playerSpecies = spec1
				adaptHeadType = spec2
				adaptChestType = spec3
				adaptLegType = spec4
				adaptBackType = spec5
			end
		end
	end
end