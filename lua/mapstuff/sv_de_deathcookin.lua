-- Remove the rotating arm boom thing that can be glitched and moved into the
--  basket and kill people which is really stupid.
hook.Add("TTTPrepareRound", "kill that shit", function()
	local spoorboom = ents.FindByName("spoorboom")[1]
	spoorboom:Fire("Kill")
end)
