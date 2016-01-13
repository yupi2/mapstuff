-- Goes into lua/mapstuff/

if SERVER then
	hook.Add("TTTPrepareRound", "kill that shit", function()
		local spoorboom = ents.FindByName("spoorboom")[1]
		if IsValid(spoorboom) then
			spoorboom:Fire("Kill")
		end
	end)
end
