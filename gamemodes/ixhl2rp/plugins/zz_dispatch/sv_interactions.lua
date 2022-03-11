util.AddNetworkString("squad.menu.datafile")
util.AddNetworkString("squad.menu.leader")
util.AddNetworkString("squad.menu.move")
util.AddNetworkString("squad.menu.reward")
util.AddNetworkString("squad.menu.spectate")
util.AddNetworkString("squad.menu.disband")
util.AddNetworkString("squad.menu.rewardall")

net.Receive("squad.menu.datafile", function(len, client)
	local id = net.ReadUInt(32)
end)

net.Receive("squad.menu.leader", function(len, client)
	local id = net.ReadUInt(32)
end)

net.Receive("squad.menu.move", function(len, client)
	local id, new, squad_tag = net.ReadUInt(32), net.ReadBool(), net.ReadInt(5)
end)

net.Receive("squad.menu.reward", function(len, client)
	local id, points, reason = net.ReadUInt(32), net.ReadInt(32), net.ReadString()
end)

net.Receive("squad.menu.spectate", function(len, client)
	local id = net.ReadUInt(32)
end)

net.Receive("squad.menu.disband", function(len, client)
	local squad_tag = net.ReadUInt(5)
end)

net.Receive("squad.menu.rewardall", function(len, client)
	local squad_tag, points, reason = net.ReadUInt(5), net.ReadInt(32), net.ReadString()
end)