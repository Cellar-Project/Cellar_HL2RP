local CHAR = ix.meta.character

function CHAR:SetSquad(squad)
	self.dispatchSquad = squad
end

function CHAR:GetSquad()
	return self.dispatchSquad
end
