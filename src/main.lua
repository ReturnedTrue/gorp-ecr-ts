local gorp_ecr = {}

local ecr_proxy = require(script.Parent.bundled.ecr)
local gorp_proxy = require(script.Parent.bundled.gorp)

gorp_ecr.init = function(packages)
	for key, value in packages.ecr do
		ecr_proxy[key] = value
	end

	for key, value in packages.gorp do
		gorp_proxy[key] = value
	end

	require(script.Parent.bundled.gorp_ecr)
end

return {
	default = gorp_ecr
}