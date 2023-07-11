require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
config = util.mergeTable({ }, config)
config.price = 200

return config, parameters
end