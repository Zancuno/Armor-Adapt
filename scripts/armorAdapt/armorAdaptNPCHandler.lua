require "/scripts/armorAdapt/armorAdaptUtil.lua"
local baseInit = init or function() end
local baseUpdate = update or function() end
function init()
baseInit()
adaptSpecies = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptDebug = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptEffects")
played = { 0, 0, 0, 0, 0, 0, 0, 0 }
bodyTable = { "Default", "Standard", "None", "None", "None" }
slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
bodyType = bodyTable[1]
bodyShape = bodyTable[2]
bodyAccessory = bodyTable[3]
bodyAlt = bodyTable[4]
bodyOther = bodyTable[5]
for _,standardSpecies in ipairs(adaptSpecies.vanillaBodySpecies) do
	if npc.species() == standardSpecies then
		self.npcSpecies = "standard"
	end
end
for _,customSpecies in ipairs(adaptSpecies.customBodySpecies) do
	if npc.species() == customSpecies then
		self.npcSpecies = npc.species()
	else
		self.npcSpecies = "standard"
	end
end
equippedArmorTimer = 10
adaptLoopTimer = 10
	if adaptDebug.showStartUp == true then
		sb.logInfo("[Armor Adapt][NPC Handler]: Initializing Armor Adapt System")
		sb.logInfo("[Armor Adapt][NPC Handler]: Starting equipment check for adaptable items.")
	end
storageArmorTable = {}
changed = true
end



function update(dt)
	baseUpdate(dt)
	adaptNpcArmor = armorAdapt.generateNpcArmorTable()
	if armorAdapt.compareArmorTables(adaptNpcArmor, storageArmorTable) == false then
		changed = false
	else
		changed = true
	end
	
	if changed == false then
		for v,armorSpecies in ipairs(adaptSpecies.supportedSpecies) do
			if self.npcSpecies == armorSpecies then
				if played[8] == 0 and (adaptDebug.showNpcSpecies == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Supported Species Recognized: %s", self.npcSpecies)
					played[8] =1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.npcSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyShape = bodyTable[2]
					bodyAccessory = bodyTable[3]
					bodyAlt = bodyTable[4]
					bodyOther = bodyTable[5]
				if played[6] == 0 and (adaptDebug.showNpcBodyType == true) then
					sb.logInfo("[Armor Adapt][NPC Handler]: Body Type Recognized: Your main body type is %s, Your body shape is %s, your body accessory is %s, if you have an alternate feature it is %s, and any other feature if present is %s", bodyType, bodyShape, bodyAccessory, bodyAlt, bodyOther)
					played[5] = 1
					played[6] = 1
				end
			else
				if played[5] == 0 and (adaptDebug.showNpcSpecies == true) then
					sb.logWarn("[Armor Adapt][NPC Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.npcSpecies)
					played[5] = 1
				end
			end
		end	
		
		for j, effect in ipairs(adaptEffects) do
			if status.uniqueStatusEffectActive(effect) then
				bodytype = bodytype ..effect
			end
		end
		
		if played[1] == 0 and (adaptDebug.showNpcArmor == true) then
			sb.logInfo("[Armor Adapt][NPC Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptNpcArmor[1], adaptNpcArmor[2], adaptNpcArmor[3], adaptNpcArmor[4], adaptNpcArmor[5], adaptNpcArmor[6], adaptNpcArmor[7], adaptNpcArmor[8])
			played[1] = 1
		end
		for k,slot in ipairs(slotTable) do
			equippedArmorTimer = equippedArmorTimer - dt
			if  adaptNpcArmor[k] == adaptNpcArmor[1] then
				armorType = 1
			elseif adaptNpcArmor[k] == adaptNpcArmor[2] then
				armorType = 2
			elseif adaptNpcArmor[k] == adaptNpcArmor[3] then
				armorType = 3
			elseif adaptNpcArmor[k] == adaptNpcArmor[4] then
				armorType = 4
			elseif adaptNpcArmor[k] == adaptNpcArmor[5] then
				armorType = 5
			elseif adaptNpcArmor[k] == adaptNpcArmor[6] then
				armorType = 6
			elseif adaptNpcArmor[k] == adaptNpcArmor[7] then
				armorType = 7
			else
				armorType = 8
			end
			--sb.logInfo("A detected item index is %s", adaptNpcArmor[k])
			if equippedArmorTimer <= 0 then
				if root.itemConfig(adaptNpcArmor[k]).parameters.itemTags == nil or root.itemConfig(adaptNpcArmor[k]).parameters.itemTags[2] ~= self.npcSpecies or root.itemConfig(adaptNpcArmor[k]).parameters.itemTags[3] ~= bodyType then
				key = k
				baseArmorItem = root.itemConfig(adaptNpcArmor[k])
				adaptArmorNpcItem = copy(adaptNpcArmor[k])
					if played[2] == 0 and (adaptDebug.showNpcSupportedItem == true) then
						sb.logInfo("[Armor Adapt][NPC Handler]: The name for the suported item is %s", root.itemConfig(adaptNpcArmor[k]).config.itemName)
						sb.logInfo("[Armor Adapt][NPC Handler]: The parameters for the suported item are %s", root.itemConfig(adaptNpcArmor[k]).parameters)
						
						played[2] = 1
					end
				if armorType == 1 or armorType == 2 then
					adaptArmorNpcItem = armorAdapt.generateAdaptedNpcHeadItem(adaptArmorNpcItem, self.npcSpecies, bodyType)
				elseif armorType == 3 or armorType == 4 then
					adaptArmorNpcItem = armorAdapt.generateAdaptedNpcChestItem(adaptArmorNpcItem, self.npcSpecies, bodyType)
				elseif armorType == 5 or armorType == 6 then
					adaptArmorNpcItem = armorAdapt.generateAdaptedNpcPantsItem(adaptArmorNpcItem, self.npcSpecies, bodyType)
				else
					adaptArmorNpcItem = armorAdapt.generateAdaptedNpcBackItem(adaptArmorNpcItem, self.npcSpecies, bodyType)
				end
					if played[4] == 0 and (adaptDebug.showNpcBuildInfo == true) then
						sb.logInfo("[Armor Adapt][NPC Handler]: The tags of the base item are %s", baseArmorItem.config.itemTags)
						sb.logInfo("[Armor Adapt][NPC Handler]: The male frames of the base item are %s", baseArmorItem.config.maleFrames)
						sb.logInfo("[Armor Adapt][NPC Handler]: The female frames of the base item are %s", baseArmorItem.config.femaleFrames)
						sb.logInfo("[Armor Adapt][NPC Handler]: The mask of the base item is %s", baseArmorItem.config.mask)
						sb.logInfo("[Armor Adapt][NPC Handler]: The config of the base item is %s", baseArmorItem.config)

						sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item tags are %s", adaptArmorNpcItem.parameters.itemTags)
						sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item male frames are %s", 	adaptArmorNpcItem.parameters.maleFrames)
						sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item female frames are %s", adaptArmorNpcItem.parameters.femaleFrames)
						sb.logInfo("[Armor Adapt][NPC Handler]: Adapted item mask is %s", adaptArmorNpcItem.parameters.mask)
			
						played[4] = 1
					end
					--sb.logInfo("Show completion is %s", adaptDebug.showBuildCompletion)
					npc.setItemSlot(slotTable[armorType], adaptArmorNpcItem)
					if adaptDebug.showNpcBuildCompletion == true then
						sb.logInfo("[Armor Adapt][NPC Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(adaptArmorNpcItem).config.itemName, self.npcSpecies, bodyType)
					end
					played[1] = 0
					played[2] = 0
					played[3] = 0
					played[4] = 0
					equippedArmorTimer = 10
					storageArmorTable[armorType] = adaptArmorPlayerItem
				elseif root.itemConfig(adaptNpcArmor[k]).parameters.itemTags ~= nil and root.itemConfig(adaptNpcArmor[k]).parameters.itemTags[2] == self.npcSpecies and root.itemConfig(adaptNpcArmor[k]).parameters.itemTags[3] == bodyType then
					storageArmorTable[k] = adaptNpcArmor[k]
				end
			end
			
		end

	end
end