if SERVER then
	-- Lazer (or is it laser) beam shit here
else
	local lazerTagSounds = {
		Sound("swwa.mp3"),     -- 1 Journey - Separate Ways (Worlds Apart)
		Sound("dad-cc.wav"),   -- 2 Madonna - Die Another Day (Country Club Martini Crew STRYKER Radio Edit)
		Sound("ns.wav"),       -- 3 Halo 2 - Never Surrender
		Sound("ttb-cln.wav"),  -- 4 Britney & T.I. - Tik Tik Boom (Carita La Nina Remix)
		Sound("z-loz-om.mp3"), -- 5 Zedd - The Legend Of Zelda (Original Mix)
		Sound("ir.mp3")        -- 6 Deadmau5 & Kaskade - I Remember
	}

	local lazerTagChannels = {nil, nil, nil, nil, nil, nil}
	local currentRoundChannel = nil

	local function GetCurrentRound()
		local left  = GetGlobalInt("ttt_rounds_left", 0)
		local limit = GetConVarNumber("ttt_round_limit")
		local round = limit - left + 1

		-- While loop is used to keep going through the songs if the round
		--  limit is bigger than the number of songs. And is this where
		--  someone should use the modulo symbol?
		while round > #lazerTagSounds do
			round = round - #lazerTagSounds
		end

		return round
	end

	local channelsSetup = 0
	local function LazertagChannelSetup(channel, errorID, errorName)
		channelsSetup = channelsSetup + 1
		if errorName then
			print("channelsSetup: " .. channelsSetup .. " failed with error:")
			print(errorName)
		end

		if IsValid(channel) then
			print("channelsSetup: " .. channelsSetup .. " is okay")
			channel:SetVolume(0.6)
			channel:EnableLooping(true)
			lazerTagChannels[channelsSetup] = channel
		end
	end

	hook.Add("InitPostEntity", "Lazertag - Start music late", function()
		-- Setup the music sound-channels to play later.
		local flags = "noplay noblock"
		for k, v in ipairs(lazerTagSounds) do
			sound.PlayFile("sound/" .. v, flags, LazertagChannelSetup)
		end

		currentRoundChannel = lazerTagChannels[GetCurrentRound()]

		if GetRoundState() == ROUND_ACTIVE then
			if IsValid(currentRoundChannel) then
				currentRoundChannel:Play()
			end
		end
	end)

	hook.Add("TTTBeginRound", "Lazertag - Start music", function()
		currentRoundChannel = lazerTagChannels[GetCurrentRound()]

		if IsValid(currentRoundChannel) then
			currentRoundChannel:Play()
		end
	end)

	hook.Add("TTTEndRound", "Lazertag - End music", function()
		if IsValid(currentRoundChannel) then
			currentRoundChannel:Stop()
		end
	end)
end
