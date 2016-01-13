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

hook.Add("OnEntityCreated", "Play Lost Woods Music", function( ent )
	if ent == LocalPlayer() then
		ent.MapMusic = CreateSound( ent, "zelda/lost_woods.wav" )
		ent.MapMusic:PlayEx( 0.5, 100 )
		hook.Remove( "OnEntityCreated", "Play Lost Woods Music" )
	end
end)
