--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// Fix camera reset
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
end)

--// Prevent duplicate GUI
if player:WaitForChild("PlayerGui"):FindFirstChild("ResolutionGUI") then
	player.PlayerGui.ResolutionGUI:Destroy()
end

--// Globals
getgenv().Resolution = 0.65
getgenv().Enabled = true

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ResolutionGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

-- Title (drag handle)
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Camera Controller"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Minimize
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -30, 0, 0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(60,60,60)
minimize.TextColor3 = Color3.new(1,1,1)

-- Value label
local valueLabel = Instance.new("TextLabel", frame)
valueLabel.Position = UDim2.new(0, 0, 0, 35)
valueLabel.Size = UDim2.new(1, 0, 0, 20)
valueLabel.Text = "Value: 0.65"
valueLabel.TextColor3 = Color3.new(1,1,1)
valueLabel.BackgroundTransparency = 1

-- Slider
local slider = Instance.new("Frame", frame)
slider.Position = UDim2.new(0.1, 0, 0, 70)
slider.Size = UDim2.new(0.8, 0, 0, 10)
slider.BackgroundColor3 = Color3.fromRGB(60,60,60)

local knob = Instance.new("Frame", slider)
knob.Size = UDim2.new(0, 12, 0, 20)
knob.Position = UDim2.new(0.65, -6, -0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(255,255,255)

-- Toggle
local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0.2, 0, 0, 110)
toggle.Size = UDim2.new(0.6, 0, 0, 30)
toggle.Text = "Enabled"
toggle.BackgroundColor3 = Color3.fromRGB(50,150,50)
toggle.TextColor3 = Color3.new(1,1,1)

--// Dragging window
local draggingFrame = false
local dragOffset

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingFrame = true
		dragOffset = input.Position - frame.Position
	end
end)

title.InputEnded:Connect(function()
	draggingFrame = false
end)

UIS.InputChanged:Connect(function(input)
	if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		frame.Position = UDim2.new(
			0,
			input.Position.X - dragOffset.X.Offset,
			0,
			input.Position.Y - dragOffset.Y.Offset
		)
	end
end)

--// Slider logic
local dragging = false

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
	end
end)

knob.InputEnded:Connect(function()
	dragging = false
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local percent = math.clamp(
			(input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X,
			0, 1
		)

		knob.Position = UDim2.new(percent, -6, -0.5, 0)

		local value = math.floor((0.1 + percent * 1.5) * 100) / 100
		getgenv().Resolution = value
		valueLabel.Text = "Value: " .. value
	end
end)

--// Toggle logic
toggle.MouseButton1Click:Connect(function()
	getgenv().Enabled = not getgenv().Enabled
	toggle.Text = getgenv().Enabled and "Enabled" or "Disabled"
	toggle.BackgroundColor3 = getgenv().Enabled and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

--// Minimize logic
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, v in pairs(frame:GetChildren()) do
		if v ~= title and v ~= minimize then
			v.Visible = not minimized
		end
	end
	frame.Size = minimized and UDim2.new(0, 260, 0, 30) or UDim2.new(0, 260, 0, 160)
end)

--// Effect loop
RunService.RenderStepped:Connect(function()
	if getgenv().Enabled and camera then
		camera.CFrame = camera.CFrame * CFrame.new(
			0, 0, 0,
			1, 0, 0,
			0, getgenv().Resolution, 0,
			0, 0, 1
		)
	end
end)
