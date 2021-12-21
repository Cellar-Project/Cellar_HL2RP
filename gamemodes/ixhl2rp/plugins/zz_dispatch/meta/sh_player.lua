do
	local CHAR = ix.meta.character

	function CHAR:SetSquad(squad)
		self.dispatchSquad = squad
	end

	function CHAR:GetSquad()
		return self.dispatchSquad
	end

	if SERVER then
		function CHAR:LeaveSquad()
			local squad = self:GetSquad()

			if squad then
				squad:RemoveMember(self)
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