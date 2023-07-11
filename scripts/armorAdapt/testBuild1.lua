require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
config = util.mergeTable({ }, config)
config.description = "This is a test"

return config, parameters
end