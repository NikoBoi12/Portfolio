local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameUtility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GameUtility"))
local UserInput = game:GetService("UserInputService")

local ComponentsFolder = ReplicatedStorage:WaitForChild("Components")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local Utility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Utility"))
local Animation = require(ReplicatedStorage.Utilities:WaitForChild("Animation"))
local AttackComp = require(ComponentsFolder:WaitForChild("Attack"))
local TowerData = require(ReplicatedStorage:WaitForChild("Managers"):WaitForChild("TowerData"))
local TestingFunc = require(script.TestingFunctions)
local CurrencyManager = require(ReplicatedStorage:WaitForChild("Managers"):WaitForChild("CurrencyManager"))

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()
local IsStudio = RunService:IsStudio()

local CreateTowerRemote = script.CreateTower
local RemoveTower = script.RemoveTower

local Module = {
	List = {}
}

local Tower = {}

Module.Tower = Tower

function Module.CreateTower(Player, Packet)
	local Config = require(ReplicatedStorage.Configs.TowerConfigs)["Monster"][Packet.Name]

	local Data = PlayerData.GetData(Player)

	local self = Utility.Factory(Tower)

	self.Name = Packet.Name
	self.Owner = Player
	
	self.UID = self.UID or Packet.UID or GameUtility.GenerateUID()
	self.TowerDataUID = self.TowerDataUID or Packet.TowerDataUID or GameUtility.GenerateUID()
	self.Config = Config
	self.TowerData = self:CreateData()
	
	self.Location = {
		Position = Packet.Position,
		Rotation = Packet.Rotation or 0,
	}
	
	self.Model = self.Config.Model
	
	self.Connections = {}
	
	if IsServer then
		if self:SanityChecks() then
			self = nil
			return
		end
	end

	Module.List[self.UID] = self

	if IsServer then
		local NewPacket = self:GetNetworkingPacket()
		CreateTowerRemote:FireAllClients(Player, NewPacket)
		
		if not Packet.UID then
			CurrencyManager.RemoveCurrency(Player, self.Config.Cost)
		end
	end

	self:Spawn()
	self:Update()
	self:CreateComponents()
	self:AddTowerToTracker()
	self:TestFunctions()
end


function Tower:AddTowerToTracker()
	if IsServer then
		local Data = PlayerData.GetData(self.Owner)
		
		if not Data.ActiveTowers[self.Config.Name] then
			Data.ActiveTowers[self.Config.Name] = 1
		else
			Data.ActiveTowers[self.Config.Name] += 1
		end
	end
end


function Tower:SanityChecks()
	if IsServer then
		local Data = PlayerData.GetData(self.Owner)
		
		if Data.ActiveTowers[self.Config.Name] and Data.ActiveTowers[self.Config.Name] == self.Config.MaxTower then
			return true
		end
		
		if not CurrencyManager.CanRemoveCurrency(self.Owner, self.Config.Cost) then
			return true
		end
	end
end


function Tower:CreateComponents()
	for ComponentName, Component in self.Config.Components do
		self[ComponentName] = Component.new(self)
	end
end


function Tower:CreateData()
	if TowerData[self.TowerDataUID] then return TowerData[self.TowerDataUID] end
	
	TowerData[self.TowerDataUID] = {}
	
	for Stat, Value in self.Config.BaseTowerStats do
		TowerData[self.TowerDataUID][Stat] = Value
	end
	
	TowerData[self.TowerDataUID].TotalCost = self.Config.Cost
	TowerData[self.TowerDataUID].CurrentModel = self.Config.Model.Name

	return TowerData[self.TowerDataUID]
end




function Tower:TestFunctions()
	if not IsStudio then return end
	
	--TestingFunc.CheckUpdate(self)
	
	if IsServer then
		
	else
		
	end
end


function Tower:CreateTowerModel()
	self.Model = self.Model:Clone()
	self.Model:PivotTo(CFrame.Angles(0, math.rad(self.Location.Rotation), 0) + self.Location.Position)
	self.Model.Parent = workspace.Towers
end


function Tower:Spawn()
	self:BindEvents()
	 
	if IsClient then
		self:CreateTowerModel()
		self:TowerInput()
		Animation.Play(self.Model, {Name = "FroggitIdle", AnimationId = self.Config.Animations.Idle, Priority = Enum.AnimationPriority.Idle})
	else 
		
		--task.delay(2, function() 
		--	self.TowerData.CurrentModel = "Froggit2"	
			
		--end)
		--self.AttackComp:FindTarget(self.Position)
	end
end


function Tower:Update()
	self.Connections[#self.Connections+1] = RunService.Heartbeat:Connect((function(DT)
		if IsServer then

		end
	end))
end

function Tower:GetTarget()
	
end


function Tower:TowerInput()
	self.Connections[#self.Connections+1] = UserInput.InputBegan:Connect(function(Input, GameService)
		if GameService then return end
	end)
end



function Tower:BindEvents()
	if RunService:IsClient() then
		self.TowerData.Changed:Connect(function(Index, Value)
			if Index == "CurrentModel" then
				local Model = ReplicatedStorage.Storage.Towers:FindFirstChild(Value)
				
				if Model then
					self.Model:Destroy()
					self.Model = Model
					self:CreateTowerModel()
				end
			end
		end)
	else

		

	end
end


function Tower:GetNetworkingPacket()
	return {
		Name = self.Name,
		Type = self.TowerType,
		Rotation = self.Location.Rotation,
		Position = self.Location.Position,
		UID = self.UID,
		TowerDataUID = self.TowerDataUID,
	}
end


function Tower.Remove(Player, self, UID)
	local self = self or Module.List[UID or self.UID]

	Module.List[self.UID] = nil
	GameUtility.DisconnectConnections(self.Connections)

	--local StaticTowerService = require(ReplicatedStorage.Modules.Towers.TowerService.StaticTowerService)

	--local StaticTowers = {}

	for _, Component in self do
		if type(Component) == "table" then
			if Component["Remove"] then
				Component:Remove(self)
			end
		end
	end

	--for i, UID in self.AttackComp.ActiveStatics do
	--	local Static = StaticTowerService.List[UID]

	--	table.insert(StaticTowers, Static)
	--end

	--for i, Static in StaticTowers do
	--	Static:Remove()
	--end



	if RunService:IsServer() then
		RemoveTower:FireAllClients(nil, nil, self.UID)
	else
		self.Model:Destroy()
	end
end


function Tower:GetNetworkPacket()

end


if RunService:IsServer() then
	RemoveTower.OnServerEvent:Connect(Tower.Remove)
	CreateTowerRemote.OnServerEvent:Connect(Module.CreateTower)
else
	RemoveTower.OnClientEvent:Connect(Tower.Remove)
	CreateTowerRemote.OnClientEvent:Connect(Module.CreateTower)
end

return Module
