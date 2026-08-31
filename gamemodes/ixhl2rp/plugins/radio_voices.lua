local PLUGIN = PLUGIN

PLUGIN.name = "Radio voicelines"
PLUGIN.author = "maxxoft"
PLUGIN.description = "Adds radio voicelines support."


if SERVER then
	util.AddNetworkString("PlayVRadio")
else
	net.Receive("PlayVRadio", function(len, ply)
		-- local speaker = net.ReadEntity()
		print("playing")
		local snd = net.ReadString()
		local beep = net.ReadString()
		local sounds = {snd, beep}

		-- a delay before any sound is played
		delay = delay or 0
		spacing = spacing or 0.1

		for _, v in pairs(sounds) do
			if v == " " then goto next end
			local postSet, preSet = 0, 0

			-- check if this sound has special time offsets
			if (istable(v)) then
				postSet, preSet = v[2] or 0, v[3] or 0
				v = v[1]
			end

			local length = SoundDuration(v)
			-- if the sound has a pause before it is played, add it here
			delay = delay + preSet

			timer.Simple(delay, function()
				if (IsValid(entity)) then
					surface.PlaySound(v)
				end
			end)

			-- add the delay for the next sound
			delay = delay + length + postSet + spacing
			::next::
		end
	end)
end
