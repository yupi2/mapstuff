hook.Add("TTTBeginRound", "Start Music", function()
	--RunConsoleCommand("sv_gravity", "500")
	if LocalPlayer().MapMusic then
		LocalPlayer().MapMusic:PlayEx( 0.5, 100 )
	end
end)

hook.Add("TTTEndRound", "End Music", function()
	--RunConsoleCommand("sv_gravity", "600")
	if LocalPlayer().MapMusic then
		LocalPlayer().MapMusic:FadeOut( 3 )
	end
end)

hook.Add("OnEntityCreated", "Play tetris Music", function( ent )
	if ent == LocalPlayer() then
		ent.MapMusic = CreateSound( ent, "gg_tetris/tetrismusic.wav" )
		ent.MapMusic:PlayEx( 0.5, 100 )
		hook.Remove( "OnEntityCreated", "Play tetris Music" )
	end
end)
