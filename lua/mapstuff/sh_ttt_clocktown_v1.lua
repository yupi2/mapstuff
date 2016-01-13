-- Goes into lua/mapstuff/

if SERVER then
	util.AddNetworkString( "ClocktownRound" )

	local clockTownDays = {
		"day1relay",
		"night1relay",
		"day2relay",
		"night1relay",
		"day3relay",
		"night3relay",
		"day4relay",
	}

	local clockTownMoonPos = {
		[ 1 ] = Vector( 10408, 1664, 6979.98 ),		-- Dawn of a new day
		[ 2 ] = Vector( 10408, 1664, 6745.495 ),	-- Night of the first day
		[ 3 ] = Vector( 10408, 1664, 6511.01 ),		-- Dawn of the second day
		[ 4 ] = Vector( 10408, 1664, 5953.41 ),		-- Night of the second day
		[ 5 ] = Vector( 10408, 1664, 5395.8 ),		-- Dawn of the third day
		[ 6 ] = Vector( 10408, 1664, 5302.865 ),	-- Night of the third day
		[ 7 ] = Vector( 10408, 1664, 5209.93 ),		-- Final Hours
	}

	local clockTownSounds = {
		"clocktown/day1.wav",
		"clocktown/night1.wav",
		"clocktown/day2.wav",
		"clocktown/night2.wav",
		"clocktown/day3.wav",
		"clocktown/day4.wav"
	}

	local clockTownDay = 1
	local clockTownDayTime = true
	local clockTownCameraTime =  false
	local notificationDuration = 5

	hook.Add("SetupPlayerVisibility", "Clocktown - Night Camera", function( ply, view )
		if not clockTownDayTime and clockTownCameraTime and clockTownCameraTime > CurTime() then
			AddOriginToPVS( Vector( -295, 629, 185 ) )
		end
	end)

	hook.Add("TTTPrepareRound", "Clocktown - Round-prep Stuff", function()
		for _,v in pairs( ents.FindByModel( "models/props_gameplay/resupply_locker.mdl" ) ) do
			v:Remove()
		end

		local dayName = clockTownDays[ clockTownDay ]
		local dayRelay = ents.FindByName( dayName )[1]
		if IsValid( dayRelay ) then
			dayRelay:Input( "Trigger" )
		end

		clockTownDayTime = dayName:sub( 1, 3 ) == "day"
		clockTownCameraTime = CurTime() + notificationDuration

		if clockTownMoonPos[ clockTownDay ] then
			timer.Simple(1, function()
				local moon = ents.FindByName( "moonchoochoo" )[1]
				if IsValid( moon ) then
					moon:SetPos( clockTownMoonPos[ clockTownDay ] )
				end
			end)
		end

		net.Start( "ClocktownRound" )
		net.WriteBit( clockTownDayTime )
		net.WriteFloat( clockTownCameraTime )
		net.WriteInt( GetGlobalInt( "ttt_rounds_left", 0 ), 8 )
		net.WriteInt( GetConVarNumber( "ttt_round_limit" ), 8 )
		net.Broadcast()

		clockTownDay = clockTownDay + 1
		if clockTownDay > #clockTownDays then
			clockTownDay = 1
		end
	end)

	hook.Add("TTTBeginRound", "Clocktown - Music", function()
		RunConsoleCommand("ulx", "splaysound", clockTownSounds[clockTownDay-1])
	end)

	hook.Add("TTTEndRound", "Clocktown - End Music", function()
		RunConsoleCommand("ulx", "stopsound")--RunConsoleCommand("ulx", "hide", "ulx stopsounds")--
	end)

	local Weather = {
		Shaker = nil
	}

	--resource.AddSingleFile( "/moon_rumble_stereo.wav" )

	function Weather:CreateShaker()
		self.Shaker = ents.Create( "env_shake" )
		self.Shaker:SetKeyValue( "spawnflags", 1 + 4 + 8 + 16 )
		self.Shaker:SetKeyValue( "amplitude", 5 )
		self.Shaker:SetKeyValue( "frequency", 5 )
		self.Shaker:SetKeyValue( "duration", 9 )
		self.Shaker:Spawn()
	end

	function Weather:DoRumble( amp, freq )
		if not IsValid( self.Shaker ) then
			Weather:CreateShaker()
		end
		BroadcastLua([[LocalPlayer():EmitSound("clocktown/rumble.wav",300,100)]])
		self.Shaker:SetKeyValue( "amplitude", ( amp or 5 ) )
		self.Shaker:SetKeyValue( "frequency", ( freq or 5 ) )
		self.Shaker:Fire( "StartShake", "", 0 )
	end

	function Weather:CreateRumbleLoop()
		timer.Simple(math.random( 30, 120 ), function()
			self:DoRumble( math.random( 5, 10 ), math.random( 5, 10 ) )
			Weather:CreateRumbleLoop()
		end)
	end

	concommand.Add("weather_earthquake", function( ply, cmd, args )
		Weather:DoRumble( math.random( 5, 10 ), math.random( 5, 10 ) )
	end)

	-- Start Clocktown rumbles
	Weather:CreateRumbleLoop()
	-- Used so that the map/lua doesn't cut rounds out.
	SetGlobalInt("ttt_round_limit", 8)
else
	surface.CreateFont("ClocktownHeader", {
		font = "Trebuchet MS",
		size = 64,
		weight = 100,
		antialias = true,
	})

	surface.CreateFont("ClocktownMain", {
		font = "Trebuchet MS",
		size = 256,
		weight = 7000,
		antialias = true,
	})

	local round = 0
	local remain = 0
	local daytime = true
	local roundScreenEndTime = false
	local roundScreenStartTime = false

	local gradient = Material( "gui/gradient" )

	local camPos = Vector( 55, 596, 67 )
	local camAngle = Angle( 0, 153, 0 )
	local panDistance = 64

	local function getRoundScreenPercent()
		return ( roundScreenEndTime - CurTime() ) / ( roundScreenEndTime - roundScreenStartTime )
	end

	local view = {}

	local redTintTab = {
		[ "$pp_colour_addr" ] = 0.08,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0.2,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}

	local blueTintTab = table.Copy(redTintTab)
	blueTintTab[ "$pp_colour_addr" ] = 0
	blueTintTab[ "$pp_colour_addb" ] = 0.08

	hook.Add("RenderScreenspaceEffects", "Clocktown - Coloured Days", function()
		-- If the player has footvision, don't draw the colors.
		if LocalPlayer():IsActive() then
			local wep = LocalPlayer():GetActiveWeapon()
			if wep:IsValid() and wep:GetClass() == 'weapon_ttt_footvision' then
				return
			end
		end

		if remain == 1 then
			DrawColorModify(redTintTab)
		elseif not daytime then
			DrawColorModify(blueTintTab)
		end
	end)

	hook.Add("CalcView", "MyCalcView", function( ply, pos, angles, fov )
		if not daytime and roundScreenEndTime and roundScreenEndTime > CurTime() then
			view.origin = camPos
			view.angles = camAngle
			view.fov = fov

			view.origin = view.origin + vector_up * ( panDistance * getRoundScreenPercent() )
			return view
		end
	end)

	net.Receive("ClocktownRound", function( len, ply )
		daytime = net.ReadBit() == 1

		roundScreenStartTime = CurTime()
		roundScreenEndTime = net.ReadFloat()

		remain = net.ReadInt(8)
		round = ( net.ReadInt(8) - remain ) + 1
	end)

	hook.Add("PostRenderVGUI", "Clocktown Round Counter", function()
		if not roundScreenEndTime or roundScreenEndTime <= CurTime() then
			return
		end

		local w,h = ScrW(), ScrH()

		if daytime then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, w, h )

			local roundText = ("The %i%s Round"):format( round, STNDRD( round ) )

			surface.SetFont( "ClocktownMain" )
			local tw, th = surface.GetTextSize( roundText )

			draw.DrawText( roundText, "ClocktownMain", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.DrawText( "Dawn of", "ClocktownHeader", w * 0.5, h * 0.5 - th * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.DrawText( ("-%i Rounds Remain-"):format( remain ), "ClocktownHeader", w * 0.5, h * 0.5 + th, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			local x,y = 0, h * 0.1

			surface.SetDrawColor( 123, 55, 123, 255 )
			surface.SetMaterial( gradient )
			surface.DrawTexturedRect( x, y, w * 0.85, h * 0.2 )

			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.SetMaterial( gradient )
			surface.DrawTexturedRect( x, y, w * 0.25, h * 0.2 )

			local roundText = ("Night of the %i%s Round"):format( round, STNDRD( round ) )

			draw.DrawText( roundText, "ClocktownHeader", w * 0.1 + 3, h * 0.15 + 3, color_black )
			draw.DrawText( roundText, "ClocktownHeader", w * 0.1, h * 0.15, Color( 255, 222, 0 ) )
			draw.DrawText( ("-%i Rounds Remain-"):format( remain ), "ClocktownHeader", w * 0.1 + 3, h * 0.2 + 3, color_black )
			draw.DrawText( ("-%i Rounds Remain-"):format( remain ), "ClocktownHeader", w * 0.1, h * 0.2, Color( 243, 75, 80 ) )
		end
	end)
end

