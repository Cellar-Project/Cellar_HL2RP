local PLUGIN = PLUGIN

-- glow04_noz is the stock no-z-test glow, so the heartbeat blob draws through walls
-- without any render state juggling. Both assets are overridable from the content
-- pack via the manifest fallbacks.
local heartbeatMaterial = Schema.assets.Material("cellar/ui/heartbeat.png", "sprites/glow04_noz")
local heartbeatSound = Schema.assets.Sound("cellar/misc/heartbeat.wav", "player/heartbeat1.wav")
local trailMaterial = "particle/particle_glow_04"

local HEARTBEAT_PERIOD = 1.1 -- seconds between pulses
local emitter

-- One controllable sound patch per body rather than fire-and-forget sound.Play
-- calls: those cannot be stopped, so toggling the ability off would leave every
-- already-started beat playing to the end of the file. A patch per target also caps
-- the number of concurrent instances at one per player instead of piling up.
local heartbeats = {}
local heartbeatActive = false

local function StopHeartbeat(target)
	local patch = heartbeats[target]

	if (patch) then
		patch:Stop()
		heartbeats[target] = nil
	end
end

local function StopAllHeartbeats()
	for target in pairs(heartbeats) do
		StopHeartbeat(target)
	end

	heartbeatActive = false
end

local function PlayHeartbeat(target, volume, pitch)
	local patch = heartbeats[target]

	if (!patch) then
		patch = CreateSound(target, heartbeatSound)

		if (!patch) then
			return
		end

		patch:SetSoundLevel(60)
		heartbeats[target] = patch
	end

	-- Stop first so each beat is a crisp restart even if the previous one is still
	-- playing, instead of only adjusting the volume of a sound already in progress.
	patch:Stop()
	patch:PlayEx(volume, pitch)
end

-- Helix fires this on the client whenever a local var changes, so the ability being
-- switched off - by the command, by death, or by a character switch - stops the audio
-- immediately instead of waiting for the next HUDPaint.
function PLUGIN:OnLocalVarSet(key, value)
	if (key == "assassinPulse" and !value) then
		StopAllHeartbeats()
	end
end

function PLUGIN:OnReloaded()
	StopAllHeartbeats()
end

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

	-- Players who disconnected never reach the HUDPaint loop again, so their patch
	-- would otherwise stay behind.
	for target in pairs(heartbeats) do
		if (!IsValid(target)) then
			StopHeartbeat(target)
		end
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
		-- Covers the cases the local var does not change, such as going into crit.
		if (heartbeatActive) then
			StopAllHeartbeats()
		end

		return
	end

	heartbeatActive = true

	local range = ix.config.Get("assassinHeartbeatRange", 512)
	local rangeSquared = range * range
	local origin = client:EyePos()
	local phase = (CurTime() % HEARTBEAT_PERIOD) / HEARTBEAT_PERIOD
	-- Two quick beats per cycle, like a real pulse.
	local beat = math.max(math.sin(phase * math.pi * 2) ^ 8, math.sin((phase - 0.16) * math.pi * 2) ^ 8 * 0.7)
	local bPlay = CurTime() >= nextHeartbeat

	if (bPlay) then
		nextHeartbeat = CurTime() + HEARTBEAT_PERIOD
	end

	for _, target in ipairs(player.GetAll()) do
		if (target == client or !target:Alive() or !target:GetCharacter()) then
			StopHeartbeat(target)
			continue
		end

		local distanceSquared = origin:DistToSqr(target:GetPos())

		if (distanceSquared > rangeSquared) then
			-- Walking out of range has to silence them too.
			StopHeartbeat(target)
			continue
		end

		local fraction = 1 - math.sqrt(distanceSquared) / range
		local center = target:WorldSpaceCenter()

		-- Each body is its own source, so the beat arrives from their direction with
		-- the engine's distance falloff. The patch is created client-side, so it is
		-- audible to this assassin only.
		if (bPlay) then
			PlayHeartbeat(target, 0.35 + fraction * 0.4, 92 + fraction * 22)
		end

		local screen = center:ToScreen()

		if (!screen.visible) then
			continue
		end

		local size = (56 + beat * 42) * (0.45 + fraction * 0.55)

		surface.SetMaterial(heartbeatMaterial)
		surface.SetDrawColor(215, 30, 30, (40 + beat * 130) * (0.35 + fraction * 0.65))
		surface.DrawTexturedRect(screen.x - size * 0.5, screen.y - size * 0.5, size, size)
	end
end
