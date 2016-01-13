hook.Add("TTTBeginRound", "Start Peach Music", function()
	if LocalPlayer().MapMusic then
		LocalPlayer().MapMusic:PlayEx( 0.5, 100 )
	end
end)

hook.Add("TTTEndRound", "End Peach Music", function()
	if LocalPlayer().MapMusic then
		LocalPlayer().MapMusic:FadeOut( 3 )
	end
end)

hook.Add("OnEntityCreated", "Play pcastle Music", function( ent )
	if ent == LocalPlayer() then
		ent.MapMusic = CreateSound( ent, "mario/inside-the-castle-walls-final.wav" )
		ent.MapMusic:PlayEx( 0.5, 100 )
		hook.Remove( "OnEntityCreated", "Play pcastle Music" )
	end
end)
