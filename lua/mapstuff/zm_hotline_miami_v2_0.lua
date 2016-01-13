if SERVER then
	hook.Add("TTTPrepareRound", "Remove Vending Machines", function()
		for _, v in pairs(ents.FindByModel("models/props/cs_office/vending_machine.mdl", "radio")) do
			v:Remove()
		end
	end)
else
    --local HotMapSounds = { "satinstorm/miami.mp3", "satinstorm/vengeance.mp3" }
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
			ent.MapMusic = CreateSound( ent, "satinstorm/miami.mp3" )--table.Random( HotMapSounds ) )
			ent.MapMusic:PlayEx( 0.5, 100 )
			hook.Remove( "OnEntityCreated", "Play Hot Music" )
		end
	end)
end

