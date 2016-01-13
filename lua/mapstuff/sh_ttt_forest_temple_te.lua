if SERVER then
	hook.Add("TTTPrepareRound", "Remove Vending Machines", function()
		util.RemoveEntsByModel("models/props/cs_office/vending_machine.mdl")
	end)
else
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

	hook.Add("OnEntityCreated", "Play ftemple Music", function( ent )
		if ent == LocalPlayer() then
			ent.MapMusic = CreateSound( ent, "zelda/ftemple/ftemple.mp3" )
			ent.MapMusic:PlayEx( 0.5, 100 )
			hook.Remove( "OnEntityCreated", "Play ftemple Music" )
		end
	end)
end
