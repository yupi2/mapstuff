-- Useful function definition so we don't duplicate it in the map lua files.
function util.RemoveEntsByModel(model)
	for _, v in ipairs(ents.FindByModel(model)) do
		v:Remove()
	end
end

hook.Add("Initialize", "MapStuff plz", function()
	local map = game.GetMap()
	local sv_map = "mapstuff/sv_"..map..".lua"
	local sh_map = "mapstuff/sh_"..map..".lua"
	local cl_map = "mapstuff/cl_"..map..".lua"

	if file.Exists(sh_map, "LUA") then
		if SERVER then
			AddCSLuaFile(sh_map)
		end
		include(sh_map)

		return
	end

	if SERVER and file.Exists(sv_map, "LUA") then
		include(sv_map)
	end

	if file.Exists(cl_map, "LUA") then
		if SERVER then
			AddCSLuaFile(cl_map)
		else
			include(cl_map)
		end
	end
end)
