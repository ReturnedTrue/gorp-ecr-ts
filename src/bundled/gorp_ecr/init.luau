local ecr = require(script.Parent.ecr)
local gorp = require(script.Parent.gorp)

local query_hook = require(script.query_hook)
local group_hook = require(script.group_hook)

type World = ecr.Registry
type Id = ecr.entity

local convert_scale = gorp.convert_scale

gorp.ecs_layer.on_hook_world = function(world)
	return table.clone(world)
end

gorp.ecs_layer.id = function(id: number)
	return id
end

gorp.ecs_layer.get = function(world: World, id: Id, ctype: unknown)
	return world:try_get(id, ctype)
end

gorp.ecs_layer.query = function(world: World, included: {unknown}, excluded: {unknown})
	if #included == 0 then included = {ecr.entity} end
	return world:view(unpack(included)):exclude(unpack(excluded))
end

gorp.ecs_layer.write = function(world: World, id: Id, values: {[unknown]: unknown})
	for ctype, value in values do
		world:set(id, ctype, value)
	end
end

gorp.ecs_layer.get_all_components = function(world: World, id: Id)
	local ctypes = {}

	for _, ctype in gorp.components do
		if world:has(id, ctype) then
			ctypes[ctype] = world:get(id, ctype)
		end
	end

	return ctypes
end

gorp.ecs_layer.on_change = function(world: World, ctype: unknown, callback: (Id, unknown) -> ())
	local changed = world:on_change(ctype):connect(callback)
	local added = world:on_add(ctype):connect(callback)
	return function()
		added:disconnect()
		changed:disconnect()
	end
end

gorp.ecs_layer.system_labels = {
	{
		category = "General Performance",

		capture = function(resume)
			local start = os.clock()
			resume()
			local finish = os.clock()
			local b = buffer.create(4)
			buffer.writef32(b, 0, finish - start)
			return b
		end,

		decode = function(packet)
			local s = buffer.readf32(packet, 0)
			return { `Last Frame\n{convert_scale(s, "s")}` }
		end,
	},
	{
		category = "View Performance",

		capture = function(resume)
			--FIXME: cyclic require
			return query_hook.capture(resume)
		end,

		decode = function(packet, names)
			return query_hook.decode(packet, names)
		end,
	},

	{
		category = "Group Performance",
		capture = function(resume)
			return group_hook.capture(resume)
		end,

		decode = function(packet, names)
			return group_hook.decode(packet, names)
		end,
	},
}

return gorp