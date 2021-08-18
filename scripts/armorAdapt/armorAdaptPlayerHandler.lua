require "/scripts/armorAdapt/armorAdaptUtil.lua"

function init()
adaptSpecies = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptDebug = root.assetJson("/scripts/armorAdapt/armorAdapt.config")
adaptEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptEffects")
adaptSpeciesEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptSpeciesEffects")
adaptOverrideEffects = root.assetJson("/scripts/armorAdapt/armorAdapt.config:armorAdaptOverrideEffects")
played = { 0, 0, 0, 0 }
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
		self.playerSpecies = "standard"
	end
end
equippedArmorTimer = 10
adaptLoopTimer = 10
	if adaptDebug.showStartUp == true then
		sb.logInfo("[Armor Adapt][Player Handler]: Initializing Armor Adapt System")
		sb.logInfo("[Armor Adapt][Player Handler]: Starting equipment check for adaptable items.")
	end
storageArmorTable = { "null", "null", "null", "null", "null", "null", "null", "null" }
changed = true
hideBody = false
storagePlayerSpecies = self.playerSpecies
end



function update(dt)
	adaptPlayerArmor = armorAdapt.generatePlayerArmorTable()
	if armorAdapt.compareArmorTables(adaptPlayerArmor, storageArmorTable) == false then
		changed = false
	else
		changed = true
	end
	
	if changed == false or status.uniqueStatusEffectActive("armorAdapt_resetTrigger") then
		for v,armorSpecies in ipairs(adaptSpecies.supportedSpecies) do
			if self.playerSpecies == armorSpecies then
				if played[1] == 0 and (adaptDebug.showPlayerSpecies == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Supported Species Recognized: %s", self.playerSpecies)
					played[1] = 1
				end
				bodyTable = armorAdapt.getSpeciesBodyTable(self.playerSpecies) or bodyTable
					bodyType = bodyTable[1]
					bodyShape = bodyTable[2]
					bodyAccessory = bodyTable[3]
					bodyAlt = bodyTable[4]
					bodyOther = bodyTable[5]
				if played[2] == 0 and (adaptDebug.showPlayerBodyType == true) then
					sb.logInfo("[Armor Adapt][Player Handler]: Body Type Recognized: Your main body type is %s, Your body shape is %s, your body accessory is %s, if you have an alternate feature it is %s, and any other feature if present is %s", bodyType, bodyShape, bodyAccessory, bodyAlt, bodyOther)
					played[3] = 1
					played[2] = 1
				end
			else
				if played[3] == 0 and (adaptDebug.showPlayerSpecies == true) then
					sb.logWarn("[Armor Adapt][Player Handler]: %s is not a supported species, request compatibility with mod author. Disregard if log later states support.", self.playerSpecies)
					played[3] = 1
				end
			end
		end	
		
		for _, effect in ipairs(adaptEffects) do
			if status.uniqueStatusEffectActive(effect) then
				bodyType = string.format("%s%s", bodyType, effect)
				--sb.logInfo("Effect is %s", bodyType)
			end

		end
		
		for _, speciesEffect in ipairs(adaptSpeciesEffects) do
			if status.uniqueStatusEffectActive(speciesEffect) then
				self.playerSpecies = string.format("%s%s", self.playerSpecies, speciesEffect)
				--sb.logInfo("Effect is %s", species)
			else
				self.playerSpecies = storagePlayerSpecies
			end

		end
		
		for _, overEffect in ipairs(adaptOverrideEffects) do
			if status.uniqueStatusEffectActive(overEffect) then
				self.playerSpecies = overEffect
				bodyType = "Default"
				hideBody = true
				--sb.logInfo("Effect is %s", species)
			else
				hideBody = false
				self.playerSpecies = storagePlayerSpecies
			end

		end
		
		if played[4] == 0 and (adaptDebug.showPlayerArmor == true) then
			sb.logInfo("[Armor Adapt][Player Handler]: The player currently has these items equipped: Head %s, Cosmetic head %s, chest %s, cosmetic chest %s, legs %s, cosmetic legs %s, back %s, and cosmetic back %s", adaptPlayerArmor[1], adaptPlayerArmor[2], adaptPlayerArmor[3], adaptPlayerArmor[4], adaptPlayerArmor[5], adaptPlayerArmor[6], adaptPlayerArmor[7], adaptPlayerArmor[8])
			played[4] = 1
		end
		for k,slot in ipairs(slotTable) do
			equippedArmorTimer = equippedArmorTimer - dt
			--sb.logInfo("A detected item index is %s", adaptPlayerArmor[k])
			if equippedArmorTimer <= 0 then
			--sb.logInfo("Timer has Expired")
				if adaptPlayerArmor[1] ~= nil then
					baseArmorItem = adaptPlayerArmor[1]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 1, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						--sb.logInfo("is %s nil?", adaptArmorPlayerItem)
						player.setEquippedItem(slotTable[1], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[1] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[1] = adaptPlayerArmor[1]
					end
				else
					storageArmorTable[1] = nil
				end
				if adaptPlayerArmor[2] ~= nil then
					baseArmorItem = adaptPlayerArmor[2]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 2, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[2], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[2] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[2] = adaptPlayerArmor[2]
					end
				else
					storageArmorTable[2] = nil
				end
				if adaptPlayerArmor[3] ~= nil then
					baseArmorItem = adaptPlayerArmor[3]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 3, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[3], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[3] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[3] = adaptPlayerArmor[3]
					end
				else
					storageArmorTable[3] = nil
				end
				if adaptPlayerArmor[4] ~= nil then
					baseArmorItem = adaptPlayerArmor[4]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 4, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[4], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[4] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[4] = adaptPlayerArmor[4]
					end
				else
					storageArmorTable[4] = nil
				end
				if adaptPlayerArmor[5] ~= nil then
					baseArmorItem = adaptPlayerArmor[5]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 5, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[5], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[5] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[5] = adaptPlayerArmor[5]
					end
				else
					storageArmorTable[5] = nil
				end
				if adaptPlayerArmor[6] ~= nil then
					baseArmorItem = adaptPlayerArmor[6]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 6, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[6], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[6] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[6] = adaptPlayerArmor[6]
					end
				else
					storageArmorTable[6] = nil
				end
				if adaptPlayerArmor[7] ~= nil then
					baseArmorItem = adaptPlayerArmor[7]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 7, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[7], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[7] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[7] = adaptPlayerArmor[7]
					end
				else
					storageArmorTable[7] = nil
				end
				if adaptPlayerArmor[8] ~= nil then
					baseArmorItem = adaptPlayerArmor[8]
					adaptArmorPlayerItem = armorAdapt.runPlayerAdapt(baseArmorItem, 8, self.playerSpecies, bodyType, hideBody)
					if adaptArmorPlayerItem ~= nil then
						player.setEquippedItem(slotTable[8], adaptArmorPlayerItem)
						armorAdapt.showPlayerCompletionLog(adaptArmorPlayerItem, self.playerSpecies, bodyType)
						storageArmorTable[8] = adaptArmorPlayerItem
						played[4] = 0
						equippedArmorTimer = 10
					else
						storageArmorTable[8] = adaptPlayerArmor[8]
					end
				else
					storageArmorTable[8] = nil
				end
				--sb.logInfo("Show completion is %s", adaptDebug.showBuildCompletion)
				
				equippedArmorTimer = 10
				--sb.logInfo("Stored Table is %s", storageArmorTable)
			end
		end
		--sb.logInfo("Is the script still false? %s", changed)
	end
end

function uninit()
	if adaptDebug.showShutDown == true then
		sb.logInfo("[Armor Adapt][Player Handler] Shutting Down: Thank you for using Armor Adapt.")
	end
end