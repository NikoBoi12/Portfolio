--[[
I would reccomend using only 1024 by 1024 sprite sheets as anything higher roblox will automatically reduce it and anything lower will just kill the quality
]]

local RunService = game:GetService("RunService")

local SpriteSheet = {}


function SpriteSheet.GetRectSize(Resolution, Packet) --{Width, Height} (Resolution), Rows, Columns
	return Vector2.new(Resolution.Height/Packet.Columns, Resolution.Width/Packet.Rows)
end


function SpriteSheet.GetFrames(Packet) --{Width, Height} (Resolution), Rows, Columns
	local Resolution = Packet.Resolution or {Width = 1024, Height = 1024}
	
	if not Packet.Rows or not Packet.Columns then warn("Missing Rows or Column Data") return end
	
	local FrameVectors = {}
	
	local Column = 0
	local Row = 0
	for i=1, Packet.MaxFrames or Packet.Rows*Packet.Columns do
		if Column == Packet.Columns then
			Column = 0
			Row += 1
		end

		table.insert(FrameVectors, Vector2.new(Column, Row))
		Column += 1
	end
	
	
	local RectSize = SpriteSheet.GetRectSize(Resolution, Packet)
	
	return {Frames = FrameVectors, ImageRectSize = RectSize}
end


function SpriteSheet.PlaySprite(Packet) -- ["FrameData"] = {{Width, Height} (Resolution), Rows, Columns}, Frames, Image, FramesPerSecond, ImageRectSize
	if not Packet.Image then warn("Missing Image") return end
	if not Packet.Frames then
		if not Packet.FrameData then warn("Missing Frame Data") return end
		local FramesInfo = SpriteSheet.GetFrames(Packet["FrameData"])
		Packet.Frames = FramesInfo.Frames
		Packet.ImageRectSize = FramesInfo.ImageRectSize
	end
	
	if Packet.ImageRectSize and Packet.Image.ImageRectSize ~= Packet.ImageRectSize then
		Packet.Image.ImageRectSize = Packet.ImageRectSize
	end
	
	local DisconnectFunc = false
	
	local ExitPacket = {
		StopPlay = false,
		Completed = Instance.new("BindableEvent"),
		Disconnect = function(self)
			DisconnectFunc = true
		end,
	}
	
	task.defer(function()
		for i, Frame in Packet.Frames do
			task.wait(1/(Packet.FramesPerSecond or 1))
			if ExitPacket.StopPlay == true or DisconnectFunc == true then break end
			SpriteSheet.SetFrame(Frame, Packet.Image)
		end
		
		--SpriteSheet.SetFrame(Packet.Frames[1], Packet.Image)
		ExitPacket.Completed:Fire()
		ExitPacket.Completed:Destroy()
	end)
	
	return ExitPacket
end


function SpriteSheet.SetFrame(Frame, Image)
	if not Frame then warn("Missing Frame") return end 
	if not Image then warn("Missing Image", debug.traceback()) return end
	
	Image.ImageRectOffset = Frame * Image.ImageRectSize
end


return SpriteSheet
