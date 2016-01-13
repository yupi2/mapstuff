-- Goes into lua/mapstuff/

if SERVER then
	hook.Add("TTTBeginRound", "Start Grav", function()
         RunConsoleCommand("sv_gravity", "800")
    end)

	hook.Add("TTTEndRound", "End Grav", function()
         RunConsoleCommand("sv_gravity", "600")
	end)
end

