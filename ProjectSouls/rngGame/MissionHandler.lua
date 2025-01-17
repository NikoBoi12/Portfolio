local Module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local MissionClass = require(script:WaitForChild("MissionClass"))

local RNG = Random.new()

local NumberOfMissionsAllowed = 3
Module.NumberOfMissionsAllowed = NumberOfMissionsAllowed

if RunService:IsServer() then
	local function UpdateToClient(Player)
		local PlayerData = PlayerData.GetData(Player)
		if not PlayerData then return end
		local Missions = {}
		for i, Mission in PlayerData.Missions do
			if Mission.GetNetworkPacket == nil then
				warn("Cannot find network packet function for", Player, Mission.MissionType)
				continue
			end
			Missions[i] = Mission:GetNetworkPacket()
		end
		
		if Player and Player.Parent then
			script.UpdatePlayerUI:FireClient(Player, Missions)
		end
	end
	script:WaitForChild("UpdatePlayerUI").OnServerEvent:Connect(UpdateToClient)
	
	local function GetRandomMission(Missions, PlayerData)
		local AllMissions = script.MissionClass:GetChildren()
		local NonDuplicateMissions = {} -- {MissionModule, ...}
		for _, MissionModule in AllMissions do -- Gets a table of missions that the player doesn't have already
			local HasMission = false
			for _, Mission in Missions do
				if Mission.MissionType == MissionModule.Name then
					HasMission = true
					break
				end
			end
			
			if not HasMission then
				table.insert(NonDuplicateMissions, MissionModule)
			end
		end
		
		if #NonDuplicateMissions == 0 then return nil end
		local RandomMissionModule = require(NonDuplicateMissions[RNG:NextInteger(1, #NonDuplicateMissions)])
		
		local ArrayOfTasks = {}
		for _, Task in RandomMissionModule.Tasks do
			if Task.LevelRequired == nil or PlayerData.Level >= Task.LevelRequired then
				table.insert(ArrayOfTasks, Task)
			end
		end
		local RandomTask = ArrayOfTasks[RNG:NextInteger(1, #ArrayOfTasks)]
		local RandomMission = RandomMissionModule.new(RandomTask)
		
		return RandomMission
	end

	local function Refresh(Player, Index)
		Index = tonumber(Index)
		
		local PlayerData = PlayerData.GetData(Player)
		if not PlayerData then return end
		
		local OldMission = PlayerData.Missions[Index]
		if OldMission then
			OldMission:Destroy()
			PlayerData.Missions[Index] = nil
		end
		
		local Mission = GetRandomMission(PlayerData.Missions, PlayerData)
		if Mission == nil then return end
		
		PlayerData.SavedMissions[Index] = nil -- Getting rid of any old missions that was saved previously
		PlayerData.Missions[tonumber(Index)] = Mission
		
		SetupMission(Player, Mission, Index)
	end
	Module.Refresh = Refresh
	
	function SetupMission(Player, Mission, Index)
		Mission:Init(Player, UpdateToClient)

		Mission.Connections[#Mission.Connections + 1] = Mission.Completed:Connect(function()
			if Player == nil or Player.Parent == nil then return end
			script.MissionComplete:FireClient(Player, Mission:GetNetworkPacket())
		end)

		task.defer(function()
			if not Mission.Active then return end
			
			local TimePassed = os.time() - Mission.Created
			local TimeLeft = Mission.Task.TimeLimit - TimePassed
			if TimeLeft > 0 then
				task.wait(TimeLeft)
			end

			if Mission.Active then
				Mission.IsExpired = true
				Mission.Expired:Fire()
			end
		end)

		UpdateToClient(Player)
	end
	
	local function NewPlayer(Player)
		local PlayerData = PlayerData.GetData(Player)
		if not PlayerData then return end
		--PlayerData.SavedMissions = {}
		local SavedMissions = PlayerData.SavedMissions -- {{MissionType = "Defeat", TaskType = "10", StartingTime = os.time(), Progress = number}, ...}
		for i = 1, PlayerData.MissionExpansion and Module.NumberOfMissionsAllowedForVIP or NumberOfMissionsAllowed do
			local SavedMission = SavedMissions[i]
			local MakeNewMission = false
			
			if SavedMission then -- If player already has a mission, then create a object for it and update the object with the saved data
				local MissionModule = script:FindFirstChild(SavedMission.MissionType,true)
				if MissionModule == nil  then continue end
				
				MissionModule = MissionModule and require(MissionModule)
				local Task = MissionModule and MissionModule.Tasks and MissionModule.Tasks[SavedMission.TaskType]
				if Task and os.time() - SavedMission.Created < Task.TimeLimit then
					local Mission = MissionModule.new(Task, SavedMission)
					PlayerData.Missions[i] = Mission
					SetupMission(Player, Mission, i)
				else 
					MakeNewMission = true
				end
			else
				MakeNewMission = true
			end
			
			if MakeNewMission then -- This executes if no saved missions were found, and it makes a new mission
				Refresh(Player, i)
			end
		end
		
		PlayerData.Missions.Changed:Connect(function(Index, Value, OldValue)
			if PlayerData.Missions[Index] == nil then
				Refresh(Player, Index)
			end
		end)
		
		UpdateToClient(Player)
	end
	
	Players.PlayerAdded:Connect(NewPlayer)
	
	for _, Player in Players:GetPlayers() do
		task.defer(NewPlayer, Player)
	end
else -- IsClient
	local PlayerData = PlayerData.GetData(game.Players.LocalPlayer)
	if not PlayerData then return end
	
	local Players = game:GetService("Players")
	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	
	local UpdatePlayerUI = script:WaitForChild("UpdatePlayerUI")
	local MissionBoard = PlayerGui:WaitForChild("Menus"):WaitForChild("Canvas"):WaitForChild("Missions"):WaitForChild("DailyMissions")
	local ScrollingFrame = MissionBoard:WaitForChild("ScrollingFrame")
	local DefaultMissionSlot = ScrollingFrame:WaitForChild("DefaultMissionSlot")
	DefaultMissionSlot.Parent = nil
	
	MissionBoard:WaitForChild("Refresh").Activated:Connect(function()
		game:GetService("MarketplaceService"):PromptProductPurchase(Player, 1896239539)
	end)
	
	function convertSeconds(seconds)
		if seconds <= 0 then
			return "Expired"
		end
		
		local days = math.floor(seconds / (24 * 3600))
		seconds = seconds % (24 * 3600)
		local hours = math.floor(seconds / 3600)
		seconds = seconds % 3600
		local minutes = math.floor(seconds / 60)
		local remainingSeconds = seconds % 60
		
		local formattedTime = ""
		if days > 0 then
			formattedTime = string.format("%02d", days) .. ":"
		end

		if hours > 0 then
			formattedTime = formattedTime .. string.format("%02d", hours) .. ":"
		end

		formattedTime = formattedTime .. string.format("%02d:%02d", minutes, remainingSeconds)

		return formattedTime
	end
	
	UpdatePlayerUI.OnClientEvent:Connect(function(Missions)
		for _, Frame in ScrollingFrame:GetChildren() do
			if Frame:IsA("ImageLabel") then
				Frame:Destroy()
			end
		end
		
		for _, NetworkPacket in Missions do
			local New = DefaultMissionSlot:Clone()
			local Task = require(script:FindFirstChild(NetworkPacket.MissionType,true)).Tasks[NetworkPacket.TaskType]
			New:WaitForChild("Title").Text = Task.Description
			
			
			local Percentage = NetworkPacket.CurrentProgress / Task.MaxProgress
			New.Bar.UIGradient.Offset = Vector2.new(Percentage,0)
			if Percentage >= 1 then
				New.Bar.Progress.Text = "COMPLETED"
			else
				New.Bar.Progress.Text = math.floor(NetworkPacket.CurrentProgress).." / "..Task.MaxProgress
			end
			
			if Task.Reward.DarkDollars and tonumber(Task.Reward.DarkDollars) > 0 then
				New.Reward.Text = New.Reward.Text..[[<br /><font color="#FFFF00">]]..(Task.Reward.DarkDollars).. " Dark Dollars</font>"
			end
	

			if Task.Reward.Items then
				for Item, Amount in Task.Reward.Items do
					New.Reward.Text = New.Reward.Text..[[<br /><font color="#00FF00">]]..Item.." x"..tostring(Amount).." </font>"
				end
			end
			
			local OriginalText = New.Reward.Text
			
			New.Parent = ScrollingFrame
			
			task.defer(function()
				while New and New.Parent do
					local TimePassed = os.time() - NetworkPacket.Created
					local String = convertSeconds(Task.TimeLimit - TimePassed)
					if String == "Expired" then
						New.Expire.Text = String
						New.Expire.ExpiredGradient.Enabled = true
						New.Expire.Gradient.Enabled = false
						break
					else
						task.defer(function()
							if Task.Reward.Exp and tonumber(Task.Reward.Exp) > 0 then
								local Multiplier = 1
								New.Reward.Text = OriginalText..", "..[[<font color="#00ffff">]]..math.floor(Task.Reward.Exp*Multiplier).. " XP</font>"
							end
						end)

						
						New.Expire.Text = DefaultMissionSlot.Expire.Text:gsub("00:00:00", String)
						New.Expire.ExpiredGradient.Enabled = false
						New.Expire.Gradient.Enabled = true
					end
					task.wait(0.5)
				end
			end)
		end
	end)
	
	task.wait(5)
	ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	end)
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	UpdatePlayerUI:FireServer()
end

return Module
