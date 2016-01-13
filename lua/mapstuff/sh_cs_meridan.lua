if SERVER then
	-- Remove the horn button that people spam.
	hook.Add("TTTPrepareRound", "Remove FUCKING Horn", function()
		local hornbutton = ents.FindByClass("func_button")[1]
		hornbutton:Remove()
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

	hook.Add("OnEntityCreated", "Play yacht Music", function( ent )
		if ent == LocalPlayer() then
			ent.MapMusic = CreateSound( ent, "customsound/yacht.wav" )
			ent.MapMusic:PlayEx( 0.5, 100 )
			hook.Remove( "OnEntityCreated", "Play yacht Music" )
		end
	end)
end
