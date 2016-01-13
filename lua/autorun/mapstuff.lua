---------------------------------------------
-- Used to run lua files on a specific map --
---------------------------------------------

-- Goes into lua/autorun/

-- Set within the mapstuff function
local mapname

-- Used so we don't have millions of for-loops within a single function.
local function RemoveEnts(str)
	for _, v in pairs(ents.FindByModel(str)) do
		v:Remove()
	end
end

local GenericMapStuffHook

if SERVER then
	-- Stuff not worthy of their own files.
	GenericMapStuffHook = function()
		if mapname == "cyberpunk_2_2" or mapname == "cyberpunk_uda_v1m1" then
			RemoveEnts("models/props_gameplay/resupply_locker.mdl")
			RemoveEnts("models/props_2fort/chimney007.mdl")
			RemoveEnts("models/props_farm/roof_vent001.mdl")
		elseif mapname == "trade_delfinoplaza_final" then
			RemoveEnts("models/props_medieval/medieval_resupply.mdl")
		elseif mapname == "cs_number13_final" then
			RemoveEnts("models/Characters/Hostage_02.mdl")
		elseif mapname == "ttt_yucatan" then
		    RemoveEnts("models/props_c17/oildrum001.mdl")
		elseif mapname == "ttt_knii_beta" then
			RemoveEnts("radio")
		else
			hook.Remove("TTTPrepareRound", "GenericMapStuffHook")
		end
	end
end

local function MapStuff()
	mapname = game.GetMap()
	local mapluafile = "mapstuff/" .. mapname .. ".lua"

	if file.Exists(mapluafile, "LUA") then
		if SERVER then
			GenericMapStuffHook = nil -- Remove all references to function
			AddCSLuaFile(mapluafile)
		end
		include(mapluafile)
	elseif SERVER then
		hook.Add("TTTPrepareRound", "GenericMapStuffHook", GenericMapStuffHook)
	end
end

hook.Add("Initialize", "Do map-specific stuff", MapStuff)

