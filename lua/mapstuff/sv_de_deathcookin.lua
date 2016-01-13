hook.Add("TTTPrepareRound", "kill that shit", function()
		local spoorboom = ents.FindByName("spoorboom")[1]
		spoorboom:Fire("Kill")
	end)
end
