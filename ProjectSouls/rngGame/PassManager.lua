local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")

local PlayerData = require(ReplicatedStorage.PlayerData)
local MissionHandler = require(ReplicatedStorage.Modules.MissionsHandler)
local Config = require(script.Config)
local Products = require(script.Products)

local GiftRemote = ReplicatedStorage.Remotes.GiftPass
local DonateRemote = ReplicatedStorage.Remotes.Donate
local PurchasePass = ReplicatedStorage.Remotes.PurchasePass
local GiftedChatRemote = ReplicatedStorage.Remotes.GiftedChat

local function Donate(Player, Amount)
	local ProductId = Config[Amount]
	
	MarketplaceService:PromptProductPurchase(Player, ProductId)
end

DonateRemote.OnServerEvent:Connect(Donate)

local function PassPurchased(Player, ID, WasPurchased)
	if not WasPurchased then return end
	local Data = PlayerData.GetData(Player)
	if not Data then return end
	
	if ID == 835236182 then
		Data.FastRollPass = true
	elseif ID == 835236184 then
		Data.SprintingPass = true
	elseif ID == 846193442 then
		Data["Jump BoostPass"] = true
	elseif ID == 955514335 then
		Data["Skip CutscenePass"] = true
	elseif ID == 955566358 then
		Data["VIPPass"] = true
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(PassPurchased)

local GamepassIds = {
	["Fast Roll"] = 1931120506;
	["Movement Speed"] = 1938051142;
	["Niko Ball"] = 1938051970;
	["Higher Jump"] = 1938052161;
	["VIP"] = 2644357394,
	["Skip Cutscene"] = 2644385831
}

local function GiftPlayerPass(Player : Player , UserId : number, PassName : string)
	local RequestId : number = GamepassIds[PassName] do if not RequestId then return end end
	local Data = PlayerData.GetData(Player)

	Data.GiftedPlayerId = UserId
	MarketplaceService:PromptProductPurchase(Player, RequestId)
end

GiftRemote.OnServerEvent:Connect(GiftPlayerPass)



local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	
	print(receiptInfo)

	local Player = Players:GetPlayerByUserId(userId)
	local Data = Player and PlayerData.GetData(Player)
	if Data == nil then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local devProductStats = Products[productId]
	if devProductStats == nil then warn("No stat found for devproduct",productId) return Enum.ProductPurchaseDecision.NotProcessedYet end

	local Success = false

	if devProductStats.Tip then
		if not RunService:IsStudio() then
			Data.Tips += devProductStats.Tip
		else
			print("gave", Player.Name, devProductStats.Tip,"tip!")
		end

		local TipAmount = tostring(devProductStats.Tip)
		Success = true
	end

	if devProductStats == "Refresh" then
		for i=1, MissionHandler.NumberOfMissionsAllowed do
			MissionHandler.Refresh(Player, i)
		end
		Success = true
	end
	
	if devProductStats == "Fast Roll Gift" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)
		
		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)
		
		if OtherPlayersData then
			print("Sucessful")
			OtherPlayersData.FastRollPass = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)
			
			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "Fast Roll"})
			
		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	if devProductStats == "Extra Movement Speed Gift" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)

		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)

		if OtherPlayersData then
			print("Sucessful")
			OtherPlayersData.SprintingPass = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)

			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "Sprinting Pass"})

		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	if devProductStats == "Niko Ball Gift" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)

		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)

		if OtherPlayersData then
			print("Sucessful")
			OtherPlayersData.HasBallPass = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)

			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "Niko Ball Pass"})

		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	
	if devProductStats == "Skip Cutscene Gift" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)

		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)

		if OtherPlayersData then
			OtherPlayersData["Skip CutscenePass"] = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)

			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "Skip Cutscenes!"})

		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	if devProductStats == "VIP Gift" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)

		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)

		if OtherPlayersData then
			print("Sucessful")
			OtherPlayersData.VIPPass = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)

			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "VIP"})

		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	
	if devProductStats == "Jump Boost GIft" then
		local GiftedPlayer = Players:GetPlayerByUserId(Data.GiftedPlayerId)

		local OtherPlayersData = PlayerData.GetData(GiftedPlayer)

		if OtherPlayersData then
			print("Sucessful")
			OtherPlayersData["Jump BoostPass"] = true
			Data.GiftedPlayer = nil
			Success = true
			GiftRemote:FireClient(Player, true)

			MessagingService:PublishAsync("Gifted", {Player = Player.Name, GiftedPlayer = GiftedPlayer.Name, Pass = "Jump Boost Pass"})

		else
			warn("Failed")
			GiftRemote:FireClient(Player)
		end
	end
	
	if not Success then
		warn("Failed to give player anything",productId,receiptInfo)
	else
		Data.RobuxSpent += receiptInfo.CurrencySpent
	end

	return Success and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
end


MarketplaceService.ProcessReceipt = processReceipt


MessagingService:SubscribeAsync("Gifted", function(Message)
	for _, Player in Players:GetPlayers() do
		GiftedChatRemote:FireClient(Player, Message.Data)
	end
end)
