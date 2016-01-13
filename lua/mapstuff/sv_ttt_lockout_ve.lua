hook.Add("TTTBeginRound", "Start Grav", function()
	RunConsoleCommand("sv_gravity", "300")
end)

hook.Add("TTTEndRound", "End Grav", function()
	RunConsoleCommand("sv_gravity", "600")
end)
