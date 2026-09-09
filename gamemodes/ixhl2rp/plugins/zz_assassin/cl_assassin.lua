local PLUGIN = PLUGIN

-- glow04_noz is the stock no-z-test glow, so the heartbeat blob draws through walls
-- without any render state juggling. Both assets are overridable from the content
-- pack via the manifest fallbacks.
local heartbeatMaterial = Schema.assets.Material("cellar/ui/heartbeat.png", "sprites/glow04_noz")
local heartbeatSound = Schema.assets.Sound("cellar/misc/heartbeat.wav", "player/heartbeat1.wav")
local trailMaterial = "particle/particle_glow_04"

local HEARTBEAT_PERIOD = 1.1 -- seconds between pulses
local emitter

--[[
	Ability 4 - the cloaked body is not drawn at all. Movement is given away only by
	the red head trail below, so a stationary assassin is completely invisible.
]]
function PLUGIN:PrePlayerDraw(client)
	if (client:GetNetVar("assassinCloak", false)) then
		return true
	end
end

local function GetHeadPosition(client)
	local boneIndex = client:LookupBone("ValveBiped.Bip01_Head1")

	if (boneIndex) then
		local position = client:GetBonePosition(boneIndex)

		if (position) then
			return position
		end
	end

	return client:EyePos()
end

timer.Create("ixAssassinTrail", 0.1, 0, function()
	local localPlayer = LocalPlayer()

	if (!IsValid(localPlayer)) then
		return
	end

	-- Driven off the broadcast netvar rather than a tracked table, so players who
	-- were already cloaked when this client connected are handled too.
	for _, client in ipairs(player.GetAll()) do
		if (!client:GetNetVar("assassinCloak", false) or !client:Alive()) then
			continue
		end

		-- Stationary means no trail at all.
		if (client:GetVelocity():LengthSqr() < 400) then
			continue
		end

		local position = GetHeadPosition(client)

		if (!emitter or !emitter:IsValid()) then
			emitter = ParticleEmitter(position)
		end

		emitter:SetPos(position)

		local particle = emitter:Add(trailMaterial, position)

		if (particle) then
			particle:SetVelocity(VectorRand() * 3)
			particle:SetDieTime(0.85)
			particle:SetStartAlpha(70)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(9)
			particle:SetColor(190, 25, 25)
			particle:SetGravity(Vector(0, 0, 4))
			particle:SetAirResistance(60)
		end
	end
end)

--[[
	Ability 1 - heartbeat sense. Only players the server already sent to this client
	are considered, so this cannot reveal anything the client did not already know.
]]
local nextHeartbeat = 0

function PLUGIN:HUDPaint()
	local client = LocalPlayer()

	if (!IsValid(client) or !client:GetLocalVar("assassinPulse", false) or !PLUGIN:CanUseAbilities(client)) then
		return
	end

	local range = ix.config.Get("assassinHeartbeatRange", 512)
	local rangeSquared = range * range
	local origin = client:EyePos()
	local phase = (CurTime() % HEARTBEAT_PERIOD) / HEARTBEAT_PERIOD
	-- Two quick beats per cycle, like a real pulse.
	local beat = math.max(math.sin(phase * math.pi * 2) ^ 8, math.sin((phase - 0.16) * math.pi * 2) ^ 8 * 0.7)
	local bPlay = CurTime() >= nextHeartbeat
	local closest

	for _, target in ipairs(player.GetAll()) do
		if (target == client or !target:Alive() or !target:GetCharacter()) then
			continue
		end

		local distanceSquared = origin:DistToSqr(target:GetPos())

		if (distanceSquared > rangeSquared) then
			continue
		end

		local fraction = 1 - math.sqrt(distanceSquared) / range
		local screen = GetHeadPosition(target):ToScreen()

		if (!screen.visible) then
			continue
		end

		local size = (56 + beat * 42) * (0.45 + fraction * 0.55)

		surface.SetMaterial(heartbeatMaterial)
		surface.SetDrawColor(215, 30, 30, (40 + beat * 130) * (0.35 + fraction * 0.65))
		surface.DrawTexturedRect(screen.x - size * 0.5, screen.y - size * 0.5, size, size)

		if (!closest or fraction > closest) then
			closest = fraction
		end
	end

	if (bPlay and closest) then
		nextHeartbeat = CurTime() + HEARTBEAT_PERIOD
		-- Louder and higher pitched the closer the nearest body is.
		client:EmitSound(heartbeatSound, 45, 90 + closest * 25, 0.25 + closest * 0.45, CHAN_STATIC)
	end
end
