--currently unused, attempt at using metatables to transfer status effect data
armAdt_statusParams = getmetatable''[armAdt_transEffects]
if not armAdt_statusParams then
	armAdt_statusParams = {}
	getmetatable''["armAdt_transEffects"] = armAdt_statusParams
end