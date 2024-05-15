armorAdapt = {}

function armorAdapt.compareArmorTables(a, b)
	local adtItmMtch = root.itemDescriptorsMatch
	local rouletteTable = { "1", "1", "1", "1", "1", "1", "1", "1" }
	local mismatchTable = {}
	for k = 1, #rouletteTable do
		if not adtItmMtch(a[k], b[k], true) then
			mismatchTable[k] = k
		end
	end

	if not next(mismatchTable) then
		return true
	else
		return mismatchTable	
	end
	sb.logInfo("mismatchTable is %s", mismatchTable)
end

function armorAdapt.slotUpdate()
	for adt_misnum = 8, 1, -1 do
		slotUAdapt = {adaptHeadType, adaptHeadType, adaptChestType, adaptChestType, adaptLegType, adaptLegType, adaptBackType, adaptBackType}
		slotUBody = {bodyHead, bodyHead, bodyChest, bodyChest, bodyLegs, bodyLegs, bodyBack, bodyBack}
		if mismatchCheck[adt_misnum] == adt_misnum then
			if adaptArmor[adt_misnum] ~= nil then
				armorAdapt_itemBase = adaptArmor[adt_misnum]
				if armorAdapt_itemBase.name == "perfectlygenericitem" then
					eqpitm(slotTable[adt_misnum], nil)
				end
					adaptArmorItem = armorAdapt.runArmorAdapt(armorAdapt_itemBase, adt_misnum, slotUAdapt[adt_misnum], slotUBody[adt_misnum], hideBody, entityType, armAdtSpriteLibrary, statusFolder, frameOverrideFolder)
				if adaptArmorItem ~= nil then
					eqpitm(slotTable[adt_misnum], adaptArmorItem)
					armorAdapt.showCompletionLog(adaptArmorItem, playerSpecies, bodyType, entityType)
					adaptStorageArmorTable[adt_misnum] = adaptArmorItem
					played[4] = 0
				else
					adaptStorageArmorTable[adt_misnum] = adaptArmor[adt_misnum]
				end
			else
				adaptStorageArmorTable[adt_misnum] = nil
			end
		end
	end
end

function armorAdapt.generatePlayerArmorTable(adaptPlayerArmor)
	adaptPlayerArmor = {}
	local plrItm = player.equippedItem
	adaptPlayerArmor[1] = plrItm("head")
	adaptPlayerArmor[2] = plrItm("headCosmetic")
	adaptPlayerArmor[3] = plrItm("chest")
	adaptPlayerArmor[4] = plrItm("chestCosmetic")
	adaptPlayerArmor[5] = plrItm("legs")
	adaptPlayerArmor[6] = plrItm("legsCosmetic")
	adaptPlayerArmor[7] = plrItm("back")
	adaptPlayerArmor[8] = plrItm("backCosmetic")
	return adaptPlayerArmor
end

function armorAdapt.generateNpcArmorTable(adaptNpcArmor)
	adaptNpcArmor = {}
	local npcItm = npc.getItemSlot
	adaptNpcArmor[1] = npcItm("head")
	adaptNpcArmor[2] = npcItm("headCosmetic")
	adaptNpcArmor[3] = npcItm("chest")
	adaptNpcArmor[4] = npcItm("chestCosmetic")
	adaptNpcArmor[5] = npcItm("legs")
	adaptNpcArmor[6] = npcItm("legsCosmetic")
	adaptNpcArmor[7] = npcItm("back")
	adaptNpcArmor[8] = npcItm("backCosmetic")
	return adaptNpcArmor
end

function armorAdapt.showCompletionLog(item, species, bodytype, entity)
	local infLg = sb.logInfo
	local entityTable = {}
	if entity == "player" then
		entityTable = {"Player", "Player"}
	elseif entity == "npc" then
		entityTable = {"NPC", "Npc"}
	end
	if root.assetJson("/scripts/armorAdapt/armorAdapt.config:show"..entityTable[2].."BuildCompletion") == true then
		infLg("[Armor Adapt]["..entityTable[1].." Handler]: Item %s has sucessfully been adapted to the species %s and the sub type %s", root.itemConfig(item).config.itemName, species, bodyType)
	end
end


function armorAdapt.showCustomSkipLog(entity)
	if entity == "player" then
		if root.assetJson("/scripts/armorAdapt/armorAdapt.config:showCustomItemSkip") == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Custom Directives based item detected, skipping conversion.")
		end
	end
end

function armorAdapt.transformativeEffects()
	for transEffect, transSettings in pairs(adaptConfig.armorAdaptTransformativeEffects) do
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
					elseif (transSettings["setting"] == "classEdit" or transSettings["setting"] == "disguise") and (adaptEffect == transSettings["effectName"] or adaptEffect == "armorAdapt_null" )then
						stack2Table[stknum] = transSettings["modifier"]
						adaptEffect = transSettings["effectName"]
						if transSettings["setting"] == "disguise" then
							stackTable[stknum] = dfltBdy
							hideBody = true
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
	
	if stseffact(adaptEffect) == false then
		adaptSpecies,adaptHeadType,adaptChestType,adaptLegType,adaptBackType = storagePlayerSpecies, storageAdaptHeadType, storageAdaptChestType, storageAdaptLegType, storageAdaptBackType
		
		hideBody = false
		adaptEffect = "armorAdapt_null"
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