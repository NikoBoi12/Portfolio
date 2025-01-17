local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

local RNG = require(ReplicatedStorage.Modules.RNG)
local RollConfig = require(ReplicatedStorage.Configs.RollConfig)
local PlayerData = require(ReplicatedStorage.PlayerData)
local AuraService = require(ReplicatedStorage.Modules.Services.AuraService)
local CraftingConfig = require(ReplicatedStorage.Configs.CraftingConfig)
local CraftingManager = require(ReplicatedStorage.Modules.CraftingManager)
local DataManager = require(ReplicatedStorage.Modules.RNGManagers.DataManager)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Analytics = require(ReplicatedStorage.Modules.Analytics)

local Remotes = ReplicatedStorage.Remotes
local RollRemote = Remotes.Rolling
local ChangeVFXRemote = Remotes.ChangeVFX
local StoreEffectRemote = Remotes.StoreEffect
local UpdateNewClient = Remotes.UpdateNewClient
local ChatRemote = Remotes.MessageSend
local CraftItemRemote = Remotes.CraftItem

local function CreatePacket(AuraName)
	return {
		Name = AuraName
	}
end


local function CraftItem(Player, ItemName)
	local Config = CraftingConfig[ItemName]
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local SanityCheck = CraftingManager.CheckAndRemove(Player, ItemName)
	
	if SanityCheck then warn("Sanity Check Triggered") return end
	
	local DataTable = Data[Config.Type]
	
	local IsArray = Utility.IsArray(DataTable)
	
	if Config.TypeValue then
		if Config.TypeValue == "Array" then
			IsArray = true
		end
	end

	if IsArray then
		if Config.Type == "Index" then
			DataManager.AddToIndex(Player, ItemName)
			DataManager.AddToCrafting(Player, ItemName)
		else
			DataTable[#DataTable+1] = ItemName
		end
	else
		if not DataTable[ItemName] then
			DataTable[ItemName] = 0
		end
		DataTable[ItemName] += 1
	end
end

CraftItemRemote.OnServerEvent:Connect(CraftItem)


local function SwapVFX(Player, AuraName)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local OldAura = Data.Aura
	local OldauraName = nil
	
	Data.CurrentEffect = AuraName
	
	if OldAura then
		local self = AuraService.GetAura(OldAura)
		OldauraName = self.Name
		self:Destroy()
	end
	
	local Aura = AuraService.CreateAura(Player, CreatePacket(AuraName))

	Data.Aura = Aura.UID
	ChangeVFXRemote:FireAllClients(Player, AuraName, OldauraName)
end


local function UpdateClient(Player, AuraName, Individual)
	ChangeVFXRemote:FireClient(Individual, Player, AuraName)
end


local function EquipVFX(Player, Aura, AlreadyEquipped)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local Check = false
	
	for _, AuraName in Data.Index do
		if Aura == AuraName then
			Check = true
		end
	end

	if not Check then warn(Player.Name.. "Is probably an exploiter IMPORTANT") return end
	
	Analytics.EquipAura(Player, "Equipped Aura")

	if not AlreadyEquipped then
		if not Data["AmountEquipped"] then
			Data["AmountEquipped"] = {}
		end

		if not Data["AmountEquipped"][Aura] then
			Data["AmountEquipped"][Aura] = 0
		end

		Data["AmountEquipped"][Aura] += 1
	end
	
	SwapVFX(Player, Aura)
end

ChangeVFXRemote.OnServerEvent:Connect(EquipVFX)



local function BeginRoll(Player)
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	local IsNew = false

	if (os.clock() - Data.LastRolled) < 1 then return end

	Data.LastRolled = os.clock()
	
	Data.Rolls += 1
	Data.PityRollsNew += 1


	local LuckOverride = 0

	if Data.PityRollsNew == 10 then
		Data.PityLuck = 1.5
	end
	
	local WeekendLuck = 0
	
	if os.date("*t").wday == 7 or os.date("*t").wday == 6 or os.date("*t").wday == 1 then
		WeekendLuck = .75
	end

	local Aura = RNG.CalculateRng(Player, RollConfig, "Monster", LuckOverride, WeekendLuck)
	
	if Data.PityRollsNew >= 10 then
		Data.PityLuck = 1
		Data.PityRollsNew = 0
	end
	
	Data.RolledAura = Aura
	
	for _, Effect in Data.Index do
		if Effect == Aura then
			IsNew = false
			break
		else
			IsNew = true
		end
	end
	
	DataManager.AddToCrafting(Player, Aura)
	DataManager.AddToIndex(Player, Aura)
	
	RollRemote:FireClient(Player, Aura, IsNew)

	local Config = RollConfig[Aura]
	
	task.wait()

	Data.RolledAura = nil
	
	Analytics.LogRollAnalytics(Player)
	
	if not Data.RollsForCurrentSession then
		Data.RollsForCurrentSession = 0
	end 

	Data.RollsForCurrentSession += 1
	
	if Config.Rarity >= 100000 then
		task.wait(5)
		MessagingService:PublishAsync("GlobalRoll", {Player = Player.Name, AuraName = Aura})
	end
end

RollRemote.OnServerEvent:Connect(BeginRoll)


MessagingService:SubscribeAsync("GlobalRoll", function(Message)
	for _, Player in Players:GetPlayers() do
		local Data = PlayerData.GetData(Player)
		if not Data then return end
		if Data.GlobalChat then
			ChatRemote:FireClient(Player, Message.Data)
		end
	end
end)


Players.PlayerAdded:Connect(function(LocalPlayer)
	for _, Player in Players:GetPlayers() do
		local Data = PlayerData.GetData(Player)
		if not Data then return end
		if Player == LocalPlayer then continue end
		
		if Data.CurrentEffect then
			UpdateClient(Player, Data.CurrentEffect, LocalPlayer)
		end
		

		
		if game:GetService("RunService"):IsStudio() then
			local Data = PlayerData.GetData(Player)

			for i, v in RollConfig.OrderedIndex do
				DataManager.AddToIndex(Player, v.AuraName)
			end
		end
	end
end)
