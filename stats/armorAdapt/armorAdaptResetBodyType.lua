function init()

	world.sendEntityMessage(entity.id(), "applyStatusEffect", "armorAdapt_resetTrigger")
	animator.playSound("botSound", 0)
end

function update(dt)
	effect.setParentDirectives("fade=ffffff=1.0")
end

function uninit()
	effect.setParentDirectives("fade=ffffff=0.5")
	world.sendEntityMessage(entity.id(), "applyStatusEffect", "armorAdapt_resetTrigger")
end