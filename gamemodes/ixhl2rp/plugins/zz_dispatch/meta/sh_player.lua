do
	local CHAR = ix.meta.character
	CHAR.GetOriginalName = CHAR.GetName

	function CHAR:GetSquadName()
		return self.dispatchSquad and self.dispatchSquad:GetMemberTag(self) or "ERROR"
	end
	
	function CHAR:SetSquad(squad)
		self.lastSquad = self.dispatchSquad
		self.dispatchSquad = squad
		self.GetName = squad and CHAR.GetSquadName or nil

		if CLIENT then
			if self:GetPlayer() == LocalPlayer() then
				if squad then
					hook.Run("OnJoinSquad", squad)
				else
					hook.Run("OnLeftSquad", self.lastSquad)
				end
			end
		else
			hook.Run("OnCharacterSquadChanged", self, self.lastSquad, self.dispatchSquad)
		end
	end

	function CHAR:GetSquad()
		return self.dispatchSquad
	end

	if SERVER then
		function CHAR:LeaveSquad()
			local squad = self:GetSquad()

			if squad then
				squad:RemoveMember(self, false, true)
			end
		end
	end
end

do
	local PLAYER = FindMetaTable("Player")

	if SERVER then
		function PLAYER:LeaveSquad()
			local character = self:GetCharacter()

			if character then
				character:LeaveSquad()
			end
		end
	end
end