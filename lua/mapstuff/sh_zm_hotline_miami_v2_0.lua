if SERVER then
	hook.Add("TTTPrepareRound", "Remove Vending Machines", function()
		util.RemoveEntsByModel("models/props/cs_office/vending_machine.mdl")=
		util.RemoveEntsByModel("radio")
	end)
else
	local HotMapSounds = { "satinstorm/miami.mp3", "satinstorm/vengeance.mp3" }
	hook.Add("TTTBeginRound", "Start Music", function()
		if LocalPlayer().MapMusic then
			LocalPlayer().MapMusic:PlayEx( 0.5, 100 )
		end
	end)

	hook.Add("TTTEndRound", "End Music", function()
		if LocalPlayer().MapMusic then
			LocalPlayer().MapMusic:FadeOut( 3 )
		end
	end)

	hook.Add("OnEntityCreated", "Play Hot Music", function( ent )
		if ent == LocalPlayer() then
			ent.MapMusic = CreateSound( ent, table.Random( HotMapSounds ) )
			ent.MapMusic:PlayEx( 0.5, 100 )
			hook.Remove( "OnEntityCreated", "Play Hot Music" )
		end
	end)
end
