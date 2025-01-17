local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local Timer = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Timer"))

local Item = {}


function Item.StartTimer(Player, ItemName, Duration)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	Data.CurrentEffects[ItemName] = {}
	local Config = ItemConfig[ItemName]
	
	local Timer = Timer.new(Duration, true, ItemName)
	Data.CurrentEffects[ItemName]["Timer"] = Timer
	Data.CurrentEffects[ItemName]["Duration"] = Duration

	for Stat, Value in Config.Effects do
		Data[Stat] = math.round((Data[Stat] + Value) * 100)/100
	end

	script.StartCounter:FireClient(Player, Player, ItemName)

	Data.CurrentEffects[ItemName]["CompletedFunc"] = Timer.Completed:Once(function()
		for Stat, Value in Config.Effects do
			Data[Stat] = math.round((Data[Stat] - Value) * 100)/100
			Data.CurrentEffects[ItemName] = nil
		end
	end)
end


function Item.ApplyEffect(Player, ItemName, Amount)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	local Config = ItemConfig[ItemName]
	
	local CurrentEffect = Data.CurrentEffects[ItemName]
	
	if CurrentEffect then
		CurrentEffect["Timer"].Duration += Config.Duration * Amount
		Data.CurrentEffects[ItemName]["Duration"] = CurrentEffect["Timer"].Duration
	else
		local Duration = Config.Duration * Amount
		Item.StartTimer(Player, ItemName, Duration)
	end
end


function Item.UseItem(Player, ItemName, Amount)
	local Config = ItemConfig[ItemName]
	if not Config then warn("No Config Found") return end
	if Amount < 0 then return end
	
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local ItemData = Data.Items[ItemName]

	if ItemData and ItemData >= Amount then
		if RunService:IsClient() then
			script.Consume:FireServer(ItemName, Amount)
		else
			Item.ApplyEffect(Player, ItemName, Amount)
			if Data.Items[ItemName] - Amount == 0 then
				Data.Items[ItemName] = nil
			else
				Data.Items[ItemName] -= Amount
			end
		end
	end
end


function Item.LoadEffects(Player)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	for _, Table in Data.SavedEffects do
		local Duration = Table.Duration - Table.TimeElapsed
		Item.StartTimer(Player, Table.Name, Duration)
	end
	
	Data.SavedEffects = {}
end

if RunService:IsServer() then PlayerService.PlayerAdded:Connect(Item.LoadEffects) end



function Item.DisplayEffect(Player, ItemName)
	local Config = ItemConfig[ItemName]
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local PlayerGui = Player:WaitForChild("PlayerGui")

	local Menus = PlayerGui:WaitForChild("HUD"):WaitForChild("Canvas")
	local StatusEffect = Menus:WaitForChild("StatusEffects")
	
	if StatusEffect:FindFirstChild(ItemName) then return end
	
	local TotalTime = 0
	
	local DisplayStatus = script.StatusEffect:Clone()
	DisplayStatus.DisplayImage.Image = Config.Image or ""
	DisplayStatus.Duration.Text = Data.CurrentEffects[ItemName]["Duration"]
	DisplayStatus.DisplayImage.Image = "rbxassetid://"..Config.Icon
	DisplayStatus.Parent = StatusEffect
	
	while true do
		task.wait(1)
		TotalTime += 1
		if Data.CurrentEffects[ItemName] == nil or TotalTime >= Data.CurrentEffects[ItemName]["Duration"] then break end
		DisplayStatus.Duration.Text = Data.CurrentEffects[ItemName]["Duration"] - TotalTime
	end
	
	DisplayStatus:Destroy()
end


if RunService:IsServer() then
	script.Consume.OnServerEvent:Connect(Item.UseItem)
else
	script.StartCounter.OnClientEvent:Connect(Item.DisplayEffect)
end

return Item
