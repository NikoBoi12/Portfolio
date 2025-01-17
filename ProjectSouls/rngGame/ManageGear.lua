local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local NetSync = require(ReplicatedStorage:WaitForChild("NetSync"))
local GearConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("GearConfig"))

local Gear = {}


function Gear.AddStats(Player, Item)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	local ItemConfig = GearConfig[Item]
	
	for Stat, Value in ItemConfig.Effects or {} do
		Data[Stat] = math.round((Data[Stat] + Value) * 100)/100
	end
	

	if RunService:IsServer() then
		if GearConfig[Item].SpecialEffect then GearConfig[Item].SpecialEffect.StartEffectServer(Player) end
	end
end


function Gear.RemoveStats(Player, Item)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	local ItemConfig = GearConfig[Item]

	for Stat, Value in ItemConfig.Effects or {} do
		Data[Stat] = math.round((Data[Stat] - Value) * 100)/100
	end
	
	if RunService:IsServer() then
		if GearConfig[Item].SpecialEffect then GearConfig[Item].SpecialEffect.EndEffectServer(Player) end
	end
end


function Gear.HasGearEquipped(Player, Slot, Item)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	if Data.Equipped[Slot] ~= Item then return end
	
	return true
end


function Gear.SlotUsed(Player, Slot)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	local Item = Data.Equipped[Slot]
	
	if Item then 
		return true
	end
end


function Gear.HasItem(Player, Item)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	return table.find(Data.Gear.InternalData, Item)
end


function Gear.Unequip(Player, Slot, NoReplication)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	local Item = Data.Equipped[Slot]
	
	if Gear.HasGearEquipped(Player, Slot) then return end
	
	Data.Equipped.InternalData[Slot] = nil
	table.insert(Data.Gear.InternalData, Item)
	Data.Gear.Changed:Fire(1, Item)
	
	if RunService:IsClient() and not NoReplication then
		script.Unequip:FireServer(Slot)
	elseif RunService:IsServer() then
		Gear.RemoveStats(Player, Item)
	end
	
	return true
end


function Gear.RemoveGear(Player, Item)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	if not Gear.HasItem(Player, Item) then return end
	
	if RunService:IsClient() then
		script.RemoveItem:FireServer(Item)
	else
		local FindValue = NetSync.table.find(Data.Gear, Item)
		
		NetSync.table.remove(Data.Gear, FindValue)
		Data.Gear.Changed:Fire(FindValue, nil, Item)
	end
end


function Gear.EquipGear(Player, Slot, Item, NoReplication)
	local Data = PlayerData.GetData(Player)
	if not Data then return end

	local FindValue = Gear.HasItem(Player, Item)
	if not FindValue then return end
	
	if Gear.SlotUsed(Player, Slot) then Gear.Unequip(Player, Slot, true) end
	table.remove(Data.Gear.InternalData, FindValue)
	Data.Gear.Changed:Fire(FindValue, nil, Item)
	
	local OldSlot = Data.Equipped.InternalData[Slot]
	
	Data.Equipped.InternalData[Slot] = Item

	local OldGearConfig = GearConfig[OldSlot]

	if RunService:IsClient() and not NoReplication then
		script.Equip:FireServer(Slot, Item)
	elseif RunService:IsServer() then
		Gear.AddStats(Player, Item)
	end

	return true
end

if RunService:IsServer() then
	script.RemoveItem.OnServerEvent:Connect(Gear.RemoveGear)
	script.Unequip.OnServerEvent:Connect(Gear.Unequip)
	script.Equip.OnServerEvent:Connect(Gear.EquipGear)
else
	
end

return Gear
