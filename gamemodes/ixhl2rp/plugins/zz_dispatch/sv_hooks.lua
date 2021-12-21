function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	if currentChar then
		currentChar:LeaveSquad()
	end
end

function PLUGIN:PlayerDisconnected(client)
	client:LeaveSquad()
end