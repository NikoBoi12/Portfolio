local Module = {
	Class = {},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService =  game:GetService("RunService")

local Utility = require(ReplicatedStorage:WaitForChild("Utilities").ReverbUtils)
local GameUtility = require(ReplicatedStorage.Utilities:WaitForChild("GameUtility"))

local SyncMovment = script:WaitForChild("Sync")

local Paths = workspace:WaitForChild("Paths")
local Base = Paths:WaitForChild("Base")
local MobSpawn = Paths:WaitForChild("Spawn")
local Options = Paths:WaitForChild("Options")
local PathOptions = Options:GetChildren()

local RandomSeed = Random.new()

local List = {} -- [UID] = Component
Module.List = List

function Module.new(Packet, Parent:{}) -- Tower/Mob
	local self = Utility.Factory(Module.Class)
	self.UID = Packet.UID or game:GetService("HttpService"):GenerateGUID(false)
	self.TotalAlpha = 0
	self.Speed = Packet.Speed
	self.Direction = Packet.Direction or 1
	self.HeightOffset = Vector3.new(0, Packet.HeightOffset, 0)
	self.TotalDistance = 0
	self.ReachedBase = Utility.NewEvent()
	self.LastSync = os.clock()
	self.DistanceToPoints = {} -- { {Distance=num, FROM=MobSpawn, GOTO=1} }
	self.Parent = Parent
	self.Path = Packet.Path and self:SetPath(Packet.Path) or nil -- Folder Instance
	self.Created = workspace:GetServerTimeNow()
	
	List[self.UID] = self
	
	return self
end

function Module.Class:GetNetworkPacket()
	return {
		["Path"] = self.Path,
		["TotalDistance"] = self.TotalDistance,
		["Direction"] = self.Direction,
		["UID"] = self.UID,
	}
end

function Module.Class:GetSyncPacket()
	return {
		["UID"] = self.UID,
		["Speed"] = self.Speed,
		["TotalDistance"] = self.TotalDistance,
		["ServerTime"] = workspace:GetServerTimeNow(),
	}
end

function Module.Class:SetPath(NewPath)
	if type(NewPath) == "string" then
		NewPath = Options:FindFirstChild(NewPath)
	end
	self.Path = NewPath
	self:GetPathTotalDistance()
end

function Module.Class:GetPathTotalDistance()
	if self.Path then
		table.clear(self.DistanceToPoints)
		
		local NumPoints = #self.Path:GetChildren()
		self.TotalPathDistance = 0
		
		local Start =  self.Direction == 1 and 1 or NumPoints
		local End = self.Direction == 1 and NumPoints+1 or 0
		for i = Start, End, self.Direction do
			local PreviousPoint = self.Path:FindFirstChild(i-self.Direction) or self.Direction == 1 and MobSpawn or Base
			local Point = self.Path:FindFirstChild(i) or self.Direction == 1 and Base or MobSpawn
			local Distance = (Point.Position-PreviousPoint.Position).Magnitude
			self.TotalPathDistance += Distance
			table.insert(self.DistanceToPoints, {
				Distance = Distance,
				FROM = PreviousPoint,
				GOTO = Point,
			})
		end
		
		return self.TotalPathDistance
	else
		warn("Does not have path property set", debug.traceback())
	end
end

function Module.Class:GetPositionOnPathFromDistance()
	local SumDistance = 0
	for _, Data in self.DistanceToPoints do
		SumDistance += Data.Distance
		if self.TotalDistance < SumDistance then
			local RelativeDistance = SumDistance - self.TotalDistance
			local Position = Data.GOTO.Position:Lerp(Data.FROM.Position, RelativeDistance/Data.Distance)
			return Position, Data
		end
	end
	
	local End = self.Direction == 1 and Base or MobSpawn
	self.ReachedBase:Fire()
	return End.Position, {GOTO = {Position=End.CFrame*Vector3.new(0,0,-5)}}
end

function Module.Class:UpdateTime()
	self:Update(workspace:GetServerTimeNow() - self.Created)
	self.Created = workspace:GetServerTimeNow()
end

function Module.Class:Update(DeltaTime)
	
	self.TotalDistance += self.Speed*DeltaTime
	local Position, Data = self:GetPositionOnPathFromDistance()
	if self.Parent.Model then
		local PrimaryPart = self.Parent.Model.PrimaryPart
		PrimaryPart:PivotTo(CFrame.lookAt(Position, Data.GOTO.Position))
	end

end

function Module.Class:Destroy()
	Module.List[self.UID] = nil
end


if RunService:IsServer() then
	function Module.Class:Sync()
		if RunService:IsServer() and os.clock() - self.LastSync >= 1 then
			self.LastSync = os.clock()
			script.Sync:FireAllClients(self:GetSyncPacket())
		end
	end
	
	function Module.Class:SetSpeed(NewSpeed:number)
		if self.Speed == NewSpeed then return end
		
		self.Speed = NewSpeed
		script.ChangeSpeed:FireAllClients({
			UID = self.UID,
			Speed = self.Speed,
			ServerTime = workspace:GetServerTimeNow(),
		})
	end
else -- IsClient
	SyncMovment.OnClientEvent:Connect(function(SyncPacket)
		local Component = List[SyncPacket.UID]
		if Component == nil then
			warn("No component found for UID", SyncPacket.UID, SyncPacket)
			return
		end
		
		Component.Speed = SyncPacket.Speed
		local RemoteDelay = workspace:GetServerTimeNow() - SyncPacket.ServerTime
		Component.TotalDistance = SyncPacket.TotalDistance + (SyncPacket.Speed * RemoteDelay)
	end)
	
	script:WaitForChild("ChangeSpeed").OnClientEvent:Connect(function(SpeedPacket)
		--[[
			SpeedPacket = {
				UID = self.UID,
				Speed = NewSpeed,
				ServerTime = workspace:GetServerTimeNow(),
			}
		--]] 
		
		local Component = List[SpeedPacket.UID] or warn("No component found for UID", SpeedPacket.UID, SpeedPacket)
		
		local RemoteDelay = (workspace:GetServerTimeNow() - SpeedPacket.ServerTime)
		Component.TotalDistance += (SpeedPacket.Speed - Component.Speed) * RemoteDelay
		
		Component.Speed = SpeedPacket.Speed
	end)
	
	
end


return Module
