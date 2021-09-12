function init()
	world.sendEntityMessage(entity.id(), "applyStatusEffect", "armorAdapt_resetTrigger")
end

function uninit()
	world.sendEntityMessage(entity.id(), "applyStatusEffect", "armorAdapt_resetTrigger")
end