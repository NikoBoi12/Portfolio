local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 
local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local MobService = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("MobService"))
local Utility = require(ReplicatedStorage:WaitForChild("Utility"))
local NikoUtility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Utility"))
local GameUtility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GameUtility"))

local TowerService = ReplicatedStorage:WaitForChild("Services"):WaitForChild("TowerService")

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()
local IsStudio = RunService:IsStudio()

local Module = {}

local OpenMenu

function Module.new(Tower)
	local self = Utility.Factory(Module)
	
	self.AllUpgrades = Tower.Config.Upgrades
	self.UpgradeApplied = Utility.NewEvent()
	self.Tower = Tower
	self.MenuConnections = {}
	self.Connections = {}
	self.Targets = {}
	
	Tower.TowerData.AppliedUpgrades = {Path1 = 0, Path2 = 0}
	
	self:UpgradeInput()
	
	return self
end


--function Module:SetCost()
--	self.Cost = {Path1 = 0, Path2 = 0}
--	for Path, UpgradeNum in self.AppliedUpgrades do
--		if UpgradeNum == #self.AllUpgrades[Path] then continue end

--		self.Cost[Path] = self.AllUpgrades[Path][UpgradeNum+1].Cost
--	end
--end


function Module:UpgradeInput()
	self.Connections[#self.Connections+1] = UserInput.InputBegan:Connect(function(Input, GameService)
		if GameService then return end

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			local Result, Position = NikoUtility.GetMouseResult()

			if Result and Result.Instance.Parent == self.Tower.Model then
				if OpenMenu and OpenMenu ~= self then
					OpenMenu:CloseUpgrade()
				end
				
				self:OpenUpgrade()
			end
		end
	end)
end


function Module:OpenUpgrade()
	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer.PlayerGui

	self.Range = self.Tower.TowerData.Range
	
	self:CreateUpgrade()

	if PlayerGui.TowerInfo.Canvas.Visible == true then self:CloseUpgrade() return end
	
	PlayerGui.TowerInfo.Canvas.Visible = true
	
	OpenMenu = self
end


function Module:CloseUpgrade()
	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer.PlayerGui
	self:UnvisualizeParts()
	local TowerInfo = PlayerGui.TowerInfo.Canvas
	GameUtility.DisconnectConnections(self.MenuConnections)
	TowerInfo.Visible = false
	
	print("CLosing")
	
	OpenMenu = nil
	
	if self.Tower.Sell then
		self.Tower.Sell:Closed()
	end
end


function Module:BuildUI()
	self.TowerInfo.TowerNameLabel.Text = self.Configs.TowerName
	self:BuildViewport()
	
	local i = 0
	
	for Path, UpgradeNum in self.AppliedUpgrades do
		i += 1
		if UpgradeNum == #self.AllUpgrades[Path] then continue end -- add logic later to show its locked or something

		local UpgradeFrame = self.UpgradeMenu["Upgrade"..i]
		local Configs = self.AllUpgrades[Path][UpgradeNum+1].UIConfig
		
		UpgradeFrame.UpgradeImage.Image = Configs.UpgradeImage
		UpgradeFrame.UpgradeName.Text = Configs.UpgradeName
	end
	
	for UpgradePath=1, 2 do
		local Upgrade = self.UpgradeMenu["Upgrade"..UpgradePath].Bars

		for BarNum=1, 5 do
			local Bar = Upgrade["Bar"..BarNum]
			if BarNum <= self.AppliedUpgrades["Path"..UpgradePath] then
				Bar.Unlocked.Visible = true
			else
				Bar.Unlocked.Visible = false
			end
		end
	end
end


function Module:BuildViewport()
	local ViewPort = self.TowerInfo.TowerViewport
	local Camera = Instance.new("Camera"):Clone()
	local TowerModel = self.Configs.Model:Clone()

	ViewPort.CurrentCamera = Camera

	TowerModel:PivotTo(CFrame.new(0,0,0))
	Camera.CFrame = CFrame.lookAt(Vector3.new(0,0,-4), Vector3.zero)
	Camera.Parent = ViewPort
	TowerModel.Parent = ViewPort
end




function Module:CreateUpgrade(Tower)
	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer.PlayerGui

	self.TowerInfo = PlayerGui.TowerInfo.Canvas
	self.UpgradeMenu = self.TowerInfo.UpgradeMenu
	self.Range = self.Tower.TowerData.Range
	self.Model = self.Tower.Model
	
	--self:BuildUI()
	
	--[[
	TEMP
	]]
	
	if self.Tower.Sell then
		PlayerGui.TowerInfo.Canvas.UpgradeMenu.Sell.Visible = true
		self.Tower.Sell:CreateSell()
	else
		PlayerGui.TowerInfo.Canvas.UpgradeMenu.Sell.Visible = false
	end
	
	self:VisualizeParts()
	
	self:BindUpgradeKeys()
end


function Module:VisualizeParts()
	if self.NewTween then
		self.NewTween:Pause()
		self.NewTween = nil
	end
	

	
	if self.NewTweenConnection then
		self.NewTweenConnection:Disconnect()
		self.NewTweenConnection = nil
	end
		
	
	local Range = self.Model.RangeDisplay
	local Goal = {}
	
	Goal.Scale = Vector3.new(self.Range*2, self.Range*2, self.Range*2)
	
	local Distance = (self.Range*2 - Range.Mesh.Scale.Y)
	
	local Time = Distance/45
	Range.Transparency = 0
	local Info = TweenInfo.new(Time, Enum.EasingStyle.Linear)

	self.NewTween = TweenService:Create(Range.Mesh, Info, Goal)
	self.NewTween:Play()
end


function Module:UnvisualizeParts()
	if self.NewTween then
		self.NewTween:Pause()
		self.NewTween = nil
	end
	
	if self.NewTweenConnection then
		self.NewTweenConnection:Disconnect()
		self.NewTweenConnection = nil
	end
	
	local Range = self.Model.RangeDisplay
	
	local Distance = (Range.Mesh.Scale.Y - 0.001)
	
	local Time = Distance/45
	

	local Goal = {}
	Goal.Scale = Vector3.new(.001, .001, .001)
	
	local Info = TweenInfo.new(Time, Enum.EasingStyle.Linear)
	
	self.NewTween = TweenService:Create(Range.Mesh, Info, Goal)
	self.NewTween:Play()
	
	self.NewTweenConnection = self.NewTween.Completed:Connect(function()
		Range.Transparency = 1
	end)
end


function Module:ApplyUpgrade(Path, TowerUID)
	local self = self or require(TowerService).List[TowerUID].Upgrades
	local OtherPath = Path == "Path1" and "Path2" or Path == "Path2" and "Path1"
	
	if self.Tower.TowerData.AppliedUpgrades[OtherPath] >= 2 and self.Tower.TowerData.AppliedUpgrades[Path] == 2 or self.Tower.TowerData.AppliedUpgrades[Path] == #self.AllUpgrades[Path] then
		return
	end
	
	if IsClient then
		self:CloseUpgrade()
		script.ApplyUpgrades:FireServer(Path, self.Tower.UID)
	else
		if self.Tower.TowerData.AppliedUpgrades[Path] then
			self.Tower.TowerData.AppliedUpgrades[Path] += 1
		end

		self:ApplyTowerUpgrade(Path)
	end
	
	GameUtility.DisconnectConnections(self.MenuConnections)
	self.UpgradeApplied:Fire()
end


function Module:ApplyTowerUpgrade(Path)
	self.AllUpgrades[Path][self.Tower.TowerData.AppliedUpgrades[Path]](self.Tower)
end


function Module:BindUpgradeKeys()
	self.MenuConnections[#self.MenuConnections+1] = self.UpgradeMenu.Path1.Activated:Connect(function()
		self:ApplyUpgrade("Path1")
	end)
	
	self.MenuConnections[#self.MenuConnections+1] = self.UpgradeMenu.Path2.Activated:Connect(function()
		self:ApplyUpgrade("Path2")
	end)
end


function Module:Remove()
	if IsClient then
		self:CloseUpgrade()
	end
	GameUtility.DisconnectConnections(self.Connections)
end


if IsServer then
	script.ApplyUpgrades.OnServerEvent:Connect(function(Player, Path, TowerUID)
		Module.ApplyUpgrade(nil, Path, TowerUID)
	end)
else
	
end


return Module
