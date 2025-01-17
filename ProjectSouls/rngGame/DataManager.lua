local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local NetSync = require(ReplicatedStorage:WaitForChild("NetSync"))
local RollConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RollConfig"))

local module = {}


function module.AddToCrafting(Player, Fragment, Override)
	local Data = PlayerData.GetData(Player)
	if not Data then return end

	if not Data.Fragments[Fragment] then
		Data.Fragments[Fragment] = Override or 1
	else
		Data.Fragments[Fragment] += Override or 1
	end
end


function module.AddToIndex(Player, Aura)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local Config = RollConfig[Aura]
	
	if not Config then warn("Not a real aura"..Aura) return end

	local Temp = {}

	for _, Effect in Data.Index do if Effect == Aura then return end end

	Data.Index[#Data.Index+1] = Aura
	
	
	return true
end


function module.AddTool(Player, Tool)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	if table.find(Data.Tools.InternalData, Tool) then return false end
	
	Data.Tools[#Data.Tools + 1] = Tool
	
	return true
end


return module
