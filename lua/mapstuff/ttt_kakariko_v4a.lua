-- Goes into lua/mapstuff/

if SERVER then
	hook.Add("TTTEndRound", "Lazertag - End Music", function()
		RunConsoleCommand("ulx", "sstopsounds")--RunConsoleCommand("ulx", "hide", "ulx stopsounds")
	end)
end	
