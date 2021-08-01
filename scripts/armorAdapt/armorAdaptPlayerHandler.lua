require "/scripts/armorAdapt/armorAdaptUtil.lua"

function init()

adaptSpecies = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptDebug = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptSlots = root.assetJson("/scripts/armorAdapt/armorAdapt.config:slotTable")
played = { 0, 0, 0, 0, 0, 0, 0, 0 }
bodyTable = { "Default", "Standard", "None", "None", "None" }
slotTable = { "head", "headCosmetic", "chest", "chestCosmetic", "legs", "legsCosmetic", "back", "backCosmetic" }
bodyType = bodyTable[1]
bodyShape = bodyTable[2]
bodyAccessory = bodyTable[3]
bodyAlt = bodyTable[4]
bodyOther = bodyTable[5]
for _,standardSpecies in ipairs(adaptSpecies.vanillaBodySpecies) do
	if player.species() == standardSpecies then
		self.playerSpecies = "standard"
	end
end
for _,customSpecies in ipairs(adaptSpecies.customBodySpecies) do
	if player.species() == customSpecies then
		self.playerSpecies = player.species()
	else
		self.npcSpecies = "standard"
	end
end
adaptItems = root.assetJson(string.format("/armorAdapt/armorAdaptList_%s.json:supportedItems",self.playerSpecies)) or {}
equippedArmorTimer = 10
adaptLoopTimer = 10
	if adaptDebug.showStartUp == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		sb.logInfo("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
storageArmorTable = {}
changed = true
end



function update(dt)
	adaptPlayerArmor = armorAdapt.generatePlayerArmorTable()
	if armorAdapt.compareArmorTables(adaptPlayerArmor, storageArmorTable) == false then
		changed = false
	else
		changed = true
	end
	
	if changed == false then
		for v,armorSpecies in ipairs(adaptSpecies.supportedSpecies) do
			if self.playerSpecies == armorSpecies then
				if played[8] == 0 and (adaptDebug.showSpecies == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Supported Species Recognized: %s", self.playerSpecies)
					played[8] =1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.playerSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyShape = bodyTable[2]
					bodyAccessory = bodyTable[3]
					bodyAlt = bodyTable[4]
					bodyOther = bodyTable[5]
				if played[6] == 0 and (adaptDebug.showBodyType == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Body Type Recognized: Your main body type is %s, Your body shape is %s, your body accessory is %s, if you have an alternate feature it is %s, and any other feature if present is %s", bodyType, bodyShape, bodyAccessory, bodyAlt, bodyOther)
					played[5] = 1
					played[6] = 1
				end
			else
				if played[5] == 0 and (adaptDebug.showSpecies == true) then
					sb.logWarn("[Armor Adapt][Player Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.playerSpecies)
					played[5] = 1
				end
			end
		end	
		
		if played[1] == 0 and (adaptDebug.showEntityArmor == true) then
			sb.logInfo("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptPlayerArmor[1], adaptPlayerArmor[2], adaptPlayerArmor[3], adaptPlayerArmor[4], adaptPlayerArmor[5], adaptPlayerArmor[6], adaptPlayerArmor[7], adaptPlayerArmor[8])
			played[1] = 1
		end
		for k,slot in ipairs(slotTable) do
			equippedArmorTimer = equippedArmorTimer - dt
			if  adaptPlayerArmor[k] == adaptPlayerArmor[1] then
				armorType = 1
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[2] then
				armorType = 2
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[3] then
				armorType = 3
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[4] then
				armorType = 4
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[5] then
				armorType = 5
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[6] then
				armorType = 6
			elseif adaptPlayerArmor[k] == adaptPlayerArmor[7] then
				armorType = 7
			else
				armorType = 8
			end
			--sb.logInfo("A detected item index is %s", adaptPlayerArmor[k])
			if equippedArmorTimer <= 0 then
				for _,armorItem in ipairs(adaptItems) do
					if root.itemDescriptorsMatch(adaptPlayerArmor[k], armorItem) then
						if root.itemConfig(adaptPlayerArmor[k]).parameters.itemTags == nil or root.itemConfig(adaptPlayerArmor[k]).parameters.itemTags[2] ~= self.playerSpecies or root.itemConfig(adaptPlayerArmor[k]).parameters.itemTags[3] ~= bodyType then
						key = k
						baseArmorItem = root.itemConfig(adaptPlayerArmor[k])
						adaptArmorPlayerItem = copy(adaptPlayerArmor[k])
							if played[2] == 0 and (adaptDebug.showSupportedItem == true) then
								sb.logInfo("[Armor Adapt][Player Handler]: The name for the suported item is %s", root.itemConfig(adaptPlayerArmor[k]).config.itemName)
								sb.logInfo("[Armor Adapt][Player Handler]: The parameters for the suported item are %s", root.itemConfig(adaptPlayerArmor[k]).parameters)
								
								played[2] = 1
							end
						if armorType == 1 or armorType == 2 then
							adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerHeadItem(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						elseif armorType == 3 or armorType == 4 then
							adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerChestItem(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						elseif armorType == 5 or armorType == 6 then
							adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerPantsItem(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						else
							adaptArmorPlayerItem = armorAdapt.generateAdaptedPlayerBackItem(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						end
							if played[4] == 0 and (adaptDebug.showBuildInfo == true) then
								sb.logInfo("[Armor Adapt][Player Handler]: The tags of the base item are %s", baseArmorItem.config.itemTags)
								sb.logInfo("[Armor Adapt][Player Handler]: The male frames of the base item are %s", baseArmorItem.config.maleFrames)
								sb.logInfo("[Armor Adapt][Player Handler]: The female frames of the base item are %s", baseArmorItem.config.femaleFrames)
								sb.logInfo("[Armor Adapt][Player Handler]: The mask of the base item is %s", baseArmorItem.config.mask)
		
								sb.logInfo("[Armor Adapt][Player Handler]: Adapted item tags are %s", adaptArmorPlayerItem.parameters.itemTags)
								sb.logInfo("[Armor Adapt][Player Handler]: Adapted item male frames are %s", 	adaptArmorPlayerItem.parameters.maleFrames)
								sb.logInfo("[Armor Adapt][Player Handler]: Adapted item female frames are %s", adaptArmorPlayerItem.parameters.femaleFrames)
								sb.logInfo("[Armor Adapt][Player Handler]: Adapted item mask is %s", adaptArmorPlayerItem.parameters.mask)
					
								played[4] = 1
							end
							--sb.logInfo("Show completion is %s", adaptDebug.showBuildCompletion)
							player.setEquippedItem(slotTable[armorType], adaptArmorPlayerItem)
							if adaptDebug.showBuildCompletion == true then
								sb.logInfo("[Armor Adapt][Player Handler]: Item %s has sucessfully been adapted to the species %s and the body type %s", root.itemConfig(adaptArmorPlayerItem).config.itemName, self.playerSpecies, bodyType)
							end
							played[1] = 0
							played[2] = 0
							played[3] = 0
							played[4] = 0
							equippedArmorTimer = 10

						end
						storageArmorTable = armorAdapt.generatePlayerArmorTable()
						--sb.logInfo("Is the equipped armor the same? %s", changed)
					else
						if (played[3] == 0) and (adaptDebug.showSupportedItem == true) then
							sb.logInfo("[Armor Adapt][Player Handler]: No supported armor found, continuing search")
							played[3] = 1
						end
					end

				end
			end
			
		end

	end

end

function uninit()
	if adaptDebug.showShutDown == true then
		sb.logInfo("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
end