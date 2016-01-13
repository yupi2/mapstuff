if SERVER then
	hook.Add("TTTBeginRound", "Start Music", function()
		if LocalPlayer().MapMusic then
			LocalPlayer().MapMusic:PlayEx( 0.5, 100 )
		end
	end)

	hook.Add("TTTEndRound", "End Music", function()
		if LocalPlayer().MapMusic then
			LocalPlayer().MapMusic:FadeOut( 3 )
		end
	end)

	hook.Add("OnEntityCreated", "Play Sonic Music", function( ent )
		if ent == LocalPlayer() then
			ent.MapMusic = CreateSound( ent, "ttt_green_hill_zone.wav" )--table.Random( HotMapSounds ) )
			ent.MapMusic:PlayEx( 0.5, 100 )
			hook.Remove( "OnEntityCreated", "Play Sonic Music" )
		end
	end)

-- Should we enable sprinting
local advttt_sprint_enabled = CreateConVar("ttt_advttt_sprint_enabled", "1", FCVAR_ARCHIVE)
-- How fast should sprinting players move? Multiplier of normal speed
local advttt_sprint_speedmul = CreateConVar("ttt_advttt_sprint_speedmul", "1.5", FCVAR_ARCHIVE)
-- How fast should stamina deplete while sprinting
local advttt_sprint_depletion = CreateConVar("ttt_advttt_sprint_depletion", "1", FCVAR_ARCHIVE)
-- How fast should stamina restore while not sprinting
local advttt_sprint_restoration = CreateConVar("ttt_advttt_sprint_restoration", "0.75", FCVAR_ARCHIVE)
-- Should we use shift instead of tapping W for sprinting? Warning: shift is used for traitor voice chat
local advttt_sprint_useshift = CreateConVar("ttt_advttt_sprint_useshift", "0", FCVAR_ARCHIVE)
	
	
hook.Add("KeyPress", "WyoziAdvTTTSprintTap", function(ply, key)
	local thekey = advttt_sprint_useshift:GetBool() and IN_SPEED or IN_FORWARD
	if key == thekey and advttt_sprint_enabled:GetBool() then
		if (advttt_sprint_useshift:GetBool() or ply.W_LastWTap and ply.W_LastWTap > CurTime() - 0.2) and ply:GetNWFloat("w_stamina", 0) > 0.1 then
			ply.W_Sprinting = true
		end 
		ply.W_LastWTap = CurTime()
	end
end)

hook.Add("KeyRelease", "WyoziAdvTTTSprintTap", function(ply, key)
	local thekey = advttt_sprint_useshift:GetBool() and IN_SPEED or IN_FORWARD
	if key == thekey then
		ply.W_Sprinting = false
	end
end)
	
local function PMetaSetSpeed(self, slowed)
	local mul = 1
	local rest = not self:IsOnGround()

	if self.W_Sprinting and self:GetNWFloat("w_stamina", 0) > 0 then
		mul = mul * advttt_sprint_speedmul:GetFloat()
		local speed = self:GetVelocity():Length()
		if speed >= 200 then
			self:SetNWFloat("w_stamina", math.max(self:GetNWFloat("w_stamina", 0)-(advttt_sprint_depletion:GetFloat() * 0.003), 0))
		end
	else
		if not self:KeyDown(IN_JUMP) then
			self:SetNWFloat("w_stamina", math.min(self:GetNWFloat("w_stamina", 0)+(advttt_sprint_restoration:GetFloat() * 0.003), 1))
		end
		self.W_Sprinting = false
	end

	if self.LegDamage and self.LegDamage > 0 and advttt_eff_legslowdown:GetFloat() > 0 then
		local nor = self.LegDamage / 100 -- normalized
		nor = nor * advttt_eff_legslowdown:GetFloat()
		nor = math.Clamp(nor, 0, 0.7)
		nor = 1 - nor

		mul = mul * nor
		self.LegDamage = self.LegDamage - 0.5
	end

	if advttt_eff_weaponweight:GetBool() then
		mul = mul * (1 - WeaponsWeight(self))
	end
	
	if slowed then
		self:SetWalkSpeed(120 * mul)
		self:SetRunSpeed(120 * mul)
		self:SetMaxSpeed(120 * mul)
	else
		self:SetWalkSpeed(220 * mul)
		self:SetRunSpeed(220 * mul)
		self:SetMaxSpeed(220 * mul)
	end
end

hook.Add("InitPostEntity", "WyoziAdvTTTOverrideSetSpeed", function()
	local pmeta = FindMetaTable("Player")
	pmeta.SetSpeed = PMetaSetSpeed
end)	
	
end

if CLIENT then

local show_on_right_side = false
local show_label = true

hook.Add("HUDPaint", "WyoziAdvTTTHUD", function()
	local margin = 10
	local client = LocalPlayer()

	if not client:Alive() or client:Team() == TEAM_SPEC then return end
	if not TEAM_SPEC then return end -- not ttt

	local width = 250
	local height = 90

	local x = show_on_right_side and (ScrW() - width - margin*2) or margin*2
	local y = ScrH() - margin - height

	local bar_height = 9
	local bar_width = width - (margin*2)

	local health = math.max(0, client:Health())
	local health_y = y + height - bar_height - 5

	draw.RoundedBox(4, x, health_y, bar_width, bar_height, Color(25, 100, 25, 222))
	draw.RoundedBox(4, x, health_y, bar_width * math.max(client:GetNWFloat("w_stamina", 0), 0.02), bar_height, Color(50, 200, 50, 250))

	if show_label then
		draw.SimpleText("Stamina", "Trebuchet18", x, health_y, Color(255, 255, 255))
	end

end) 

end
