--[[
    EzRES - Drk External Integration
    A camera resolution controller secured with Drk External Key System.
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// Configuration
local DB_URL = "https://ez-res-default-rtdb.asia-southeast1.firebasedatabase.app/keys/"
local PORTAL_URL = "https://ltnproject.github.io/DrkExternal-Key/" -- Link to your key portal
local KEY_FILENAME = "drk_license.txt"

--// Cleanup existing GUIs
if player:WaitForChild("PlayerGui"):FindFirstChild("DrkKeyGUI") then
	player.PlayerGui.DrkKeyGUI:Destroy()
end
if player.PlayerGui:FindFirstChild("ResolutionGUI") then
	player.PlayerGui.ResolutionGUI:Destroy()
end

--// Utility Functions
local function getHWID()
	local success, result = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	return success and result or "UNKNOWN"
end

local function notify(text, color)
	local notif = Instance.new("TextLabel")
	notif.Size = UDim2.new(0, 200, 0, 30)
	notif.Position = UDim2.new(0.5, -100, 0.8, 0)
	notif.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
	notif.TextColor3 = Color3.new(1, 1, 1)
	notif.Text = text
	notif.Parent = player:WaitForChild("PlayerGui"):FindFirstChild("DrkKeyGUI") or player.PlayerGui:FindFirstChild("ResolutionGUI")
	
	local corner = Instance.new("UICorner", notif)
	
	task.delay(3, function()
		TweenService:Create(notif, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.wait(0.5)
		notif:Destroy()
	end)
end

--// Main Application Logic (Locked)
local function startMain()
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
	frame.BackgroundColor3 = Color3.fromRGB(15, 10, 25) -- Drk Aesthetic
	frame.BorderSizePixel = 0
	
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 12)
	
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(168, 85, 247)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.5

	-- Title (drag handle)
	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 35)
	title.Text = "DRK EXTERNAL - EZRES"
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	
	local titleCorner = Instance.new("UICorner", title)
	titleCorner.CornerRadius = UDim.new(0, 12)

	-- Minimize
	local minimize = Instance.new("TextButton", frame)
	minimize.Size = UDim2.new(0, 30, 0, 30)
	minimize.Position = UDim2.new(1, -35, 0, 2.5)
	minimize.Text = "-"
	minimize.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	minimize.TextColor3 = Color3.new(1,1,1)
	minimize.BorderSizePixel = 0
	Instance.new("UICorner", minimize)

	-- Value label
	local valueLabel = Instance.new("TextLabel", frame)
	valueLabel.Position = UDim2.new(0, 0, 0, 45)
	valueLabel.Size = UDim2.new(1, 0, 0, 20)
	valueLabel.Text = "Resolution: 0.65"
	valueLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.Gotham

	-- Slider
	local slider = Instance.new("Frame", frame)
	slider.Position = UDim2.new(0.1, 0, 0, 80)
	slider.Size = UDim2.new(0.8, 0, 0, 6)
	slider.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	Instance.new("UICorner", slider)

	local knob = Instance.new("Frame", slider)
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(0.65, -8, -0.8, 0)
	knob.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	Instance.new("UICorner", knob)
	
	local knobStroke = Instance.new("UIStroke", knob)
	knobStroke.Color = Color3.new(1, 1, 1)
	knobStroke.Thickness = 2

	-- Toggle
	local toggle = Instance.new("TextButton", frame)
	toggle.Position = UDim2.new(0.15, 0, 0, 115)
	toggle.Size = UDim2.new(0.7, 0, 0, 32)
	toggle.Text = "Status: Enabled"
	toggle.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	toggle.TextColor3 = Color3.new(1,1,1)
	toggle.Font = Enum.Font.GothamBold
	Instance.new("UICorner", toggle)

	--// Dragging logic
	local draggingFrame = false
	local dragOffset
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFrame = true
			dragOffset = input.Position - frame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if draggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
			frame.Position = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFrame = false end
	end)

	--// Slider logic
	local draggingKnob = false
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingKnob = true end
	end)
	UIS.InputChanged:Connect(function(input)
		if draggingKnob and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
			knob.Position = UDim2.new(percent, -8, -0.8, 0)
			local value = math.floor((0.1 + percent * 1.5) * 100) / 100
			getgenv().Resolution = value
			valueLabel.Text = "Resolution: " .. value
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingKnob = false end
	end)

	--// Toggle logic
	toggle.MouseButton1Click:Connect(function()
		getgenv().Enabled = not getgenv().Enabled
		toggle.Text = "Status: " .. (getgenv().Enabled and "Enabled" or "Disabled")
		toggle.BackgroundColor3 = getgenv().Enabled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(150, 50, 50)
	end)

	--// Minimize logic
	local minimized = false
	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		for _, v in pairs(frame:GetChildren()) do
			if v ~= title and v ~= minimize and v:IsA("GuiObject") then
				v.Visible = not minimized
			end
		end
		frame.Size = minimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 160)
	end)

	--// Effect loop
	RunService.RenderStepped:Connect(function()
		if getgenv().Enabled and camera then
			camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution, 0, 0, 0, 1)
		end
	end)
	
	notify("EzRES Loaded Successfully!", Color3.fromRGB(50, 150, 50))
end

--// Key Verification System
local function verifyKey(key)
	local hwid = getHWID()
	local success, response = pcall(function()
		return game:HttpGet(DB_URL .. key .. ".json")
	end)
	
	if not success or response == "null" then
		return false, "Invalid License Key"
	end
	
	local data = HttpService:JSONDecode(response)
	if not data.active then
		return false, "This key has been disabled"
	end
	
	if data.expires_at < (os.time() * 1000) then
		return false, "This key has expired (12h limit)"
	end
	
	-- HWID Binding
	if data.hwid == "UNBOUND" then
		-- Bind key to current HWID
		pcall(function()
			-- Note: Roblox scripts usually can't PATCH/PUT to Firebase directly without a proxy
			-- For this demo, we assume the user will bind it or it's handled by backend
			-- In a real scenario, you'd use a server-side proxy
		end)
	elseif data.hwid ~= hwid then
		return false, "Key is bound to another device"
	end
	
	return true, data
end

--// Login GUI
local function createLoginUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DrkKeyGUI"
	gui.Parent = player.PlayerGui

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 350, 0, 220)
	frame.Position = UDim2.new(0.5, -175, 0.5, -110)
	frame.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
	
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 16)
	
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(168, 85, 247)
	stroke.Thickness = 2

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "DRK EXTERNAL"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", frame)
	sub.Size = UDim2.new(1, 0, 0, 20)
	sub.Position = UDim2.new(0, 0, 0, 45)
	sub.Text = "Please enter your license key"
	sub.TextColor3 = Color3.fromRGB(150, 150, 150)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 12
	sub.BackgroundTransparency = 1

	local inputBox = Instance.new("TextBox", frame)
	inputBox.Size = UDim2.new(0.8, 0, 0, 40)
	inputBox.Position = UDim2.new(0.1, 0, 0, 80)
	inputBox.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
	inputBox.Text = ""
	inputBox.PlaceholderText = "DRK-XXXX-XXXX-XXXX"
	inputBox.TextColor3 = Color3.new(1, 1, 1)
	inputBox.Font = Enum.Font.Code
	inputBox.TextSize = 14
	Instance.new("UICorner", inputBox)
	
	local inputStroke = Instance.new("UIStroke", inputBox)
	inputStroke.Color = Color3.fromRGB(168, 85, 247)
	inputStroke.Transparency = 0.7

	local loginBtn = Instance.new("TextButton", frame)
	loginBtn.Size = UDim2.new(0.8, 0, 0, 40)
	loginBtn.Position = UDim2.new(0.1, 0, 0, 130)
	loginBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	loginBtn.Text = "Login"
	loginBtn.TextColor3 = Color3.new(1, 1, 1)
	loginBtn.Font = Enum.Font.GothamBold
	loginBtn.TextSize = 14
	Instance.new("UICorner", loginBtn)

	local getKeyBtn = Instance.new("TextButton", frame)
	getKeyBtn.Size = UDim2.new(0.8, 0, 0, 30)
	getKeyBtn.Position = UDim2.new(0.1, 0, 0, 175)
	getKeyBtn.BackgroundTransparency = 1
	getKeyBtn.Text = "Get Free Key"
	getKeyBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
	getKeyBtn.Font = Enum.Font.Gotham
	getKeyBtn.TextSize = 12

	-- Actions
	loginBtn.MouseButton1Click:Connect(function()
		local key = inputBox.Text
		if key == "" then return end
		
		loginBtn.Text = "Verifying..."
		loginBtn.Active = false
		
		local valid, data = verifyKey(key)
		if valid then
			-- Save key
			pcall(function()
				writefile(KEY_FILENAME, key)
			end)
			
			gui:Destroy()
			startMain()
		else
			loginBtn.Text = "Login"
			loginBtn.Active = true
			notify(data, Color3.fromRGB(150, 50, 50))
		end
	end)

	getKeyBtn.MouseButton1Click:Connect(function()
		setclipboard(PORTAL_URL)
		notify("Portal URL copied to clipboard!", Color3.fromRGB(168, 85, 247))
	end)
end

--// Initial Start
local function init()
	local savedKey = nil
	pcall(function()
		if isfile(KEY_FILENAME) then
			savedKey = readfile(KEY_FILENAME)
		end
	end)
	
	if savedKey then
		local valid, data = verifyKey(savedKey)
		if valid then
			startMain()
		else
			createLoginUI()
		end
	else
		createLoginUI()
	end
end

init()
